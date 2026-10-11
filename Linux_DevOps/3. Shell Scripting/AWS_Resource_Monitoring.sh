#!/bin/bash

##################################################
# Author: Prudhvi Yashwanth Reddy Kikkuru
# Date: 11th October 2025
# Description: This script Monitors AWS Resources and logs users
# Version: 1.0
##################################################

set -euo pipefail
#set -x # Uncomment for debugging

# ==== Configuration File ====
DATE=$(date +"%d-%b-%Y_%H:%M:%S")
LOG_DIR="/var/log/aws-monitor"
LOG_FILE="$LOG_DIR/tracker_$DATE.log"

#=== Ensure log directory exists ===
mkdir -p "$LOG_DIR"

# === Check if AWS CLI installed ===
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Install it before running this script." | tee -a "$LOG_FILE" >&2
    exit 1
fi

# === Check IAM Role or Credentials ===
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials or IAM role not configured." | tee -a "$LOG_FILE" >&2
    exit 1
fi

# === Start Logging ===
{
    echo "=== AWS Resource Usage Report ==="
    echo "Generated on: $(date)"
    echo "========================================================"

    # === S3 Buckets ===
    echo -e "\n[S3 Buckets]"
    aws s3 ls

    # === EC2 Instances ===
    echo -e "\n[EC2 Instances]"
    aws ec2 describe-instances \
        --query "Reservations[*].Instances[*].[InstanceId, InstanceType, State.Name,PublicIpAddress,LaunchTime]"\
        --output table

    # === Lambda Functions ===
    echo -e "\n[Lambda Functions]"
    aws lambda list-functions \
        --query "Functions[*].[FunctionName,Runtime,LastModified]"\
        --output table

    # === IAM Users ===
    echo -e "\n[IAM Users]"
    aws iam list-users \
        --query "Users[*].[UserName,CreateDate]" \
        --output table

    # === Completion ===
    echo -e "\n✅ Report saved to $LOG_FILE"
} | tee -a "$LOG_FILE"
