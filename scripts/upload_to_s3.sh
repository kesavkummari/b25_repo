#!/bin/bash

# Variables
S3_BUCKET="digital-ads"
FILE_PATH="/Users/ck/gitrepos-demo/b25_repo/file.txt"
S3_DESTINATION="s3://$S3_BUCKET/dev/file.txt"

# Upload file to S3 bucket
echo "Uploading $FILE_PATH to $S3_DESTINATION..."
aws s3 cp "$FILE_PATH" "$S3_DESTINATION"

# Check if the upload was successful
if [ $? -eq 0 ]; then
    echo "File successfully uploaded to S3."
else
    echo "Error uploading file to S3."
fi

echo "Welcome To DevOps World"