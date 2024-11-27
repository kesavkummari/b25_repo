#!/bin/bash

# Ensure AWS CLI is installed and configured
if ! command -v aws &> /dev/null
then
    echo "AWS CLI not found. Please install and configure it."
    exit 1
fi

# Check for unencrypted S3 buckets
check_s3_encryption() {
    echo "Checking for unencrypted S3 buckets..."
    unencrypted_buckets=$(aws s3api list-buckets --query 'Buckets[*].Name' --output text | while read bucket; do
        encryption=$(aws s3api get-bucket-encryption --bucket "$bucket" 2>&1)
        if [[ "$encryption" == *"ServerSideEncryptionConfigurationNotFoundError"* ]]; then
            echo "$bucket is not encrypted."
        fi
    done)
    if [ -z "$unencrypted_buckets" ]; then
        echo "All S3 buckets are encrypted."
    else
        echo "$unencrypted_buckets"
    fi
}

# Check for public access security groups
check_public_security_groups() {
    echo "Checking for security groups with public access (0.0.0.0/0)..."
    security_groups=$(aws ec2 describe-security-groups --query 'SecurityGroups[*].[GroupId,GroupName,IpPermissions]' --output json | jq '.[] | select(.IpPermissions[].IpRanges[].CidrIp == "0.0.0.0/0")')
    if [ -z "$security_groups" ]; then
        echo "No security groups with public access."
    else
        echo "The following security groups have public access (0.0.0.0/0):"
        echo "$security_groups" | jq '.GroupId, .GroupName'
    fi
}

# Check for overly permissive IAM policies (wildcard access)
check_iam_policies() {
    echo "Checking for overly permissive IAM policies..."
    iam_policies=$(aws iam list-policies --scope Local --query 'Policies[*].Arn' --output text | while read policy_arn; do
        policy_document=$(aws iam get-policy-version --policy-arn "$policy_arn" --version-id $(aws iam get-policy --policy-arn "$policy_arn" --query 'Policy.DefaultVersionId' --output text) --query 'PolicyVersion.Document' --output json)
        if echo "$policy_document" | jq -e '.Statement[] | select(.Effect == "Allow" and .Action == "*" and .Resource == "*")' > /dev/null; then
            echo "$policy_arn is overly permissive (wildcard actions or resources)."
        fi
    done)
    if [ -z "$iam_policies" ]; then
        echo "No overly permissive IAM policies found."
    else
        echo "$iam_policies"
    fi
}

# Check if root account has MFA enabled
check_root_mfa() {
    echo "Checking if root account has MFA enabled..."
    root_account=$(aws iam list-account-aliases --query 'AccountAliases[0]' --output text)
    mfa_devices=$(aws iam list-mfa-devices --user-name root --output json)
    if [ -z "$mfa_devices" ]; then
        echo "Root account does not have MFA enabled!"
    else
        echo "Root account has MFA enabled."
    fi
}

# Check for EC2 instances without IAM roles
check_ec2_iam_roles() {
    echo "Checking for EC2 instances without IAM roles..."
    ec2_instances=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,IamInstanceProfile]' --output json | jq '.[][] | select(.IamInstanceProfile == null) | .InstanceId')
    if [ -z "$ec2_instances" ]; then
        echo "All EC2 instances have IAM roles."
    else
        echo "The following EC2 instances do not have IAM roles assigned:"
        echo "$ec2_instances"
    fi
}

# Run all checks
check_s3_encryption
check_public_security_groups
check_iam_policies
check_root_mfa
check_ec2_iam_roles

echo "Security validation complete."
