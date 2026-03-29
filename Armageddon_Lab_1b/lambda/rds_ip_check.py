import os
import json
import socket
import boto3

SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]
SSM_PARAM_NAME = os.environ.get("SSM_PARAM_NAME", "/lab/db/resolved_ip")
DB_ENDPOINT = os.environ["DB_ENDPOINT"]

ssm = boto3.client("ssm")
sns = boto3.client("sns")

def handler(event, context):
    # Resolve endpoint to an IP
    try:
        ip = socket.gethostbyname(DB_ENDPOINT)
    except Exception as e:
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject="LAB ALERT: RDS DNS resolution failed",
            Message=f"Could not resolve {DB_ENDPOINT}: {e}"
        )
        raise

    # Get previous IP (if any)
    prev = None
    try:
        resp = ssm.get_parameter(Name=SSM_PARAM_NAME)
        prev = resp["Parameter"]["Value"]
    except ssm.exceptions.ParameterNotFound:
        pass

    if prev != ip:
        msg = f"RDS endpoint IP changed.\nEndpoint: {DB_ENDPOINT}\nPrevious: {prev}\nCurrent: {ip}"
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject="LAB ALERT: RDS endpoint IP changed",
            Message=msg
        )

        # Store the new IP
        ssm.put_parameter(
            Name=SSM_PARAM_NAME,
            Value=ip,
            Type="String",
            Overwrite=True
        )

    return {"endpoint": DB_ENDPOINT, "ip": ip, "previous": prev}
