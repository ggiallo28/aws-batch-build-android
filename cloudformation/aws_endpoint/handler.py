import json
import os
import boto3
batch = boto3.client('batch')
logs = boto3.client('logs', region_name='us-west-2')

BUCKET=os.environ['BUCKET']
JOB_QUEUE = os.environ['JOB_QUEUE']
JOB_DEFINITION = os.environ['JOB_DEFINITION']
LOG_GROUP_NAME = os.environ['LOG_GROUP_NAME']

is_device = json.loads(os.environ['DEVICES'])
is_mode = json.loads(os.environ['MODE'])
is_boolean = {
    "true" : True,
    "false" : False,
    "True" : True,
    "False" : False
}

def check_input_parameters(event, context):
    status = {
        "statusCode" : 200,
        "message" : ""
    }

    try:
        device_code_name = event['queryStringParameters']['DeviceCodeName']
        device_code_name = is_device[device_code_name]
    except:
        status["statusCode"] = 422
        status["message"] += "DeviceCodeName=<?> is required. "

    try:
        force_build = event['queryStringParameters']['Force'] if 'Force' in event['queryStringParameters'] else "false"
        force_build = is_boolean[force_build]
    except:
        status["statusCode"] = 422
        status["message"] += "Force=<?> parameter should be True | False. "

    try:
        mode = event['queryStringParameters']['Mode'] if 'Mode' in event['queryStringParameters'] else "user"
        mode = is_mode[mode]
    except:
        status["statusCode"] = 422
        status["message"] += "Mode=<?> parameter should be userdebug | user."

    return status, device_code_name, force_build, mode

def check_running_jobs(device_code_name, force_build, ALL=False):
    # List running Job
    list_jobs = []
    for s in ['SUBMITTED','PENDING','RUNNABLE','STARTING','RUNNING']:
        job_summary_list = batch.list_jobs(jobQueue=JOB_QUEUE,jobStatus=s)['jobSummaryList']
        if len(job_summary_list) > 0:
            for jsl in job_summary_list:
                if jsl['jobName'] == device_code_name or ALL:
                    list_jobs.append(jsl)
    # If force_build is True Terminate all Running Jobs
    if force_build:
        for job in list_jobs:
            response = batch.terminate_job(jobId=job['jobId'],reason='Duplicate Job, Lambda Termination')
        list_jobs = []
    return list_jobs

def get_logs(event):
    jobid = event['queryStringParameters']['JobId']
    logid = batch.describe_jobs(jobs=[jobid])
    try:
        logid = logid['jobs'][0]['attempts'][-1]['container']['logStreamName']
    except:
        logid = logid['jobs'][0]['container']['logStreamName']
        
    try:
        response = logs.get_log_events(
            logGroupName=LOG_GROUP_NAME,
            logStreamName=logid,
            startFromHead=False
        )
        message = ""
        print(message)
        for e in response['events']:
            message += str(e["timestamp"]) + ": " + e["message"] + "\n"
        
        return {
            "statusCode": 200,
            "body": message
        }
    except:
        list_jobs = check_running_jobs("", False, ALL=True)
        message = "Job List:\n "
        for job in list_jobs:
            message += "jobId: " + job['jobId'] + " " 
            message += "jobName: " + job['jobName'] + " "
            message += "createdAt: " + str(job['createdAt']) + " "
            message += "status: " + job['status'] + "\n"
        return {
            "statusCode": 404,
            "body": message
        }


def hello(event, context):
    if 'JobId' in event['queryStringParameters']: # Se è specificato il JobId preleva i log
        return get_logs(event)     
    else: # Se NON è specificato il JobId esegui in Job
        status, device_code_name, force_build, mode = check_input_parameters(event, context)
        if status["statusCode"] != 200:
            return {
                "statusCode": status["statusCode"],
                "body": json.dumps({
                    "message": status["message"]
                })
            }

        list_jobs = check_running_jobs(device_code_name, force_build)

        if len(list_jobs) == 0: # Non ci sono Job in Esecuzione avviane uno nuovo.
            response = batch.submit_job(
                jobName=device_code_name,
                jobQueue=JOB_QUEUE,
                jobDefinition=JOB_DEFINITION,
                containerOverrides={
                    'command': [
                        './../entrypoint.sh', device_code_name, mode, BUCKET
                    ]
                },
                timeout={
                    'attemptDurationSeconds': 18000
                }
            )
            jobId = response['jobId']
        else: # Ci sono Job in esecuzione, e la build non è forzata: mantieni l'ultimo.
            for job in list_jobs[:-1]:
                response = batch.terminate_job(jobId=job['jobId'],reason='Duplicate Job, Lambda Termination')
            jobId = list_jobs[-1]['jobId']

        message = "Your build will be available soon\n"
        message += "Link: {}/{}/{}/job={}/rom.tar.gz\n".format(os.environ['URL_PREFIX'],BUCKET,device_code_name,jobId)
        message += "Logs: {}://{}{}?JobId={}".format(event["headers"]["X-Forwarded-Proto"], event["headers"]["Host"], event["requestContext"]["path"],jobId) 
        return {
            "statusCode": 200,
            "body": message
        }
