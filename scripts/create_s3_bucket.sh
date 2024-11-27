#!/bin/bash

# Variables
BUCKET_NAME="digital-ads"
AWS_REGION="us-east-1"  # Change to your preferred region

# Create the S3 bucket
echo "Creating S3 bucket: $BUCKET_NAME in region: $AWS_REGION..."
aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint="$AWS_REGION"

# Check if the bucket was successfully created
if [ $? -eq 0 ]; then
    echo "Bucket $BUCKET_NAME created successfully."
else
    echo "Error creating bucket $BUCKET_NAME."
fi

echo "Welcome To Cloud Binary" > /var/www/html/index.html
