# Install required libraries: flask, boto3
from flask import Flask, request, jsonify
import boto3
import os
import json

app = Flask(__name__)

# AWS Clients
sqs_client = boto3.client('sqs', region_name=os.getenv('AWS_REGION', 'eu-north-1'))
ssm_client = boto3.client('ssm', region_name=os.getenv('AWS_REGION', 'eu-north-1'))

# Environment variables
QUEUE_URL = os.getenv('SQS_QUEUE_URL')
PARAMETER_NAME = os.getenv('PARAMETER_NAME')

# Load token from SSM Parameter Store
def get_token_from_ssm():
    try:
        parameter = ssm_client.get_parameter(Name=PARAMETER_NAME, WithDecryption=True)
        return parameter['Parameter']['Value']
    except Exception as e:
        app.logger.error(f"Failed to retrieve parameter: {e}")
        return None

TOKEN = get_token_from_ssm()

@app.route('/process', methods=['POST'])
def process_request():
    try:
        # Get JSON payload
        payload = request.get_json()
        if not payload:
            return jsonify({"error": "Invalid or missing JSON payload"}), 400

        # Validate token
        provided_token = payload.get('token')
        if provided_token != TOKEN:
            return jsonify({"error": "Invalid token"}), 403

        # Validate "data" object
        data = payload.get('data')
        required_fields = ["email_subject", "email_sender", "email_timestream", "email_content"]
        if not data or not all(field in data for field in required_fields):
            return jsonify({"error": "Invalid or incomplete data fields"}), 400

        # Publish to SQS
        sqs_client.send_message(QueueUrl=QUEUE_URL, MessageBody=json.dumps(data))
        return jsonify({"message": "Request processed successfully"}), 200

    except Exception as e:
        app.logger.error(f"Error processing request: {e}")
        return jsonify({"error": "Internal server error"}), 500
    # test 2 se

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.getenv('PORT', 5000)))
