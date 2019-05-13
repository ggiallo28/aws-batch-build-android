import json
import boto3
batch = boto3.client('batch')
URL_PREFIX = 'https://example.com/{}/{}/rom.zip'

JOB_QUEUE = 'batch-android-build-job-queue'
JOB_DEFINITION = 'batch-android-build-job-definition'

is_device = {
    "potter" : "potter"
}

is_boolean = {
    "true" : True,
    "false" : False,
    "True" : True,
    "False" : False
}

is_mode = {
    "userdebug" : "userdebug",
    "user" : "user"
}

def hello(event, context):
    try:
        device_code_name = event['queryStringParameters']['DeviceCodeName']
        device_code_name = is_device[device_code_name]
    except:
        return {
            "statusCode": 200,
            "message": "?DeviceCodeName=<?> is required.",
        }

    try:
        force_build = event['queryStringParameters']['Force'] if 'Force' in event['queryStringParameters'] else "false"
        force_build = is_boolean[force_build]
    except:
        return {
            "statusCode": 200,
            "message": "Force parameter should be True | False.",
        }

    try:
        mode = event['queryStringParameters']['Mode'] if 'Mode' in event['queryStringParameters'] else "user"
        mode = is_mode[mode]
    except:
        return {
            "statusCode": 200,
            "message": "Mode parameter should be userdebug | user.",
        }

    list_jobs = []
    for s in ['SUBMITTED','PENDING','RUNNABLE','STARTING','RUNNING']:
        job_summary_list = batch.list_jobs(jobQueue=JOB_QUEUE,jobStatus=s)['jobSummaryList']
        if len(job_summary_list) > 0:
            for jsl in job_summary_list:
                if jsl['jobName'] == device_code_name:
                    list_jobs.append(jsl)

    if force_build:
        for job in list_jobs:
            response = batch.terminate_job(
                jobId=job['jobId'],
                reason='Duplicate Job, Lambda Termination'
            )
        list_jobs = []

    if len(list_jobs) == 0:
        response = batch.submit_job(
            jobName=device_code_name,
            jobQueue=JOB_QUEUE,
            jobDefinition=JOB_DEFINITION,
            containerOverrides={
                'command': [
                    './../entrypoint.sh',
                ]
            },
            timeout={
                'attemptDurationSeconds': 18000
            }
        )
        jobId = response['jobId']
    else:
        for job in list_jobs[:-1]:
            response = batch.terminate_job(
                jobId=job['jobId'],
                reason='Duplicate Job, Lambda Termination'
            )
        jobId = list_jobs[-1]['jobId']

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Your build will be available soon!",
            "input": URL_PREFIX.format(device_code_name,jobId)
            })
        }

    # Use this code if you don't use the http event with the LAMBDA-PROXY
    # integration
    """
    return {
        "message": "Go Serverless v1.0! Your function executed successfully!",
        "event": event
    }
    """
