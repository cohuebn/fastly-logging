#!/bin/bash

localstack_url='http://localhost:4566'
# Setup S3
aws --endpoint-url=$localstack_url s3 mb s3://test-bucket
aws --endpoint-url=$localstack_url s3 cp ./fake-log-file.txt s3://test-bucket/test/fastly-log.txt
# Setup CloudWatch
aws --endpoint-url=$localstack_url logs create-log-group --log-group-name test-log-group
# Run the Lambda with a test event
sam local invoke --template pull-from-s3-template.yml \
  --event fake-bucket-event.json \
  --docker-network fastly-logging-network \
  --env-vars local.env.json