import json
import boto3
URL_PREFIX = 'WIP: https://example.com/job_id/{}/rom.zip'

JOB_NAME =
JOB_QUEUE =
JOB_DEFINITION =
batch = boto3.client('batch')
def hello(event, context):
    device_code_name = event['queryStringParameters']['Name']
    response = client.submit_job(
        jobName=JOB_NAME,
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

    body = {
        "message": "Your build will be available soon!",
        "input": URL_PREFIX.format(device_code_name),
        "job" : json.dumps(body)
    }

    response = {
        "statusCode": 200,
        "body": json.dumps(response)
    }

    return response

    # Use this code if you don't use the http event with the LAMBDA-PROXY
    # integration
    """
    return {
        "message": "Go Serverless v1.0! Your function executed successfully!",
        "event": event
    }
    """
