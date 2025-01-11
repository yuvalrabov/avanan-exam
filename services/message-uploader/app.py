import boto3
import time
import os

# Initialize AWS clients
sqs_client = boto3.client('sqs', region_name='eu-north-1')
s3_client = boto3.client('s3', region_name='eu-north-1')

# Environment variables
SQS_QUEUE_URL = os.getenv('SQS_QUEUE_URL')
S3_BUCKET_NAME = os.getenv('S3_BUCKET_NAME')
POLL_INTERVAL = int(os.getenv('POLL_INTERVAL', 60))  # Default to 60 seconds


def process_messages():
    response = sqs_client.receive_message(
        QueueUrl=SQS_QUEUE_URL,
        MaxNumberOfMessages=10,
        WaitTimeSeconds=10
    )

    messages = response.get('Messages', [])
    if not messages:
        print("No messages received.")
        return

    for message in messages:
        body = message['Body']
        message_id = message['MessageId']

        try:
            # Upload the message body to S3
            s3_client.put_object(
                Bucket=S3_BUCKET_NAME,
                Key=f"messages/{message_id}.txt",
                Body=body
            )
            print(f"Uploaded message {message_id} to S3.")

            # Delete the message from the SQS queue
            sqs_client.delete_message(
                QueueUrl=SQS_QUEUE_URL,
                ReceiptHandle=message['ReceiptHandle']
            )
            print(f"Deleted message {message_id} from SQS.")
        except Exception as e:
            print(f"Failed to process message {message_id}: {e}")
        #testing digest


if __name__ == "__main__":
    print("Starting to upload messages from SQS to S3...")
    while True:
        process_messages()
        time.sleep(POLL_INTERVAL)