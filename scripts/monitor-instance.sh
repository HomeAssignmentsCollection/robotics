#!/bin/bash

# Monitor Test Instance Script
# This script monitors the dashboard test instance

INSTANCE_ID="i-0dcb64cedc6a11bd9"
REGION="eu-north-1"

echo "🔍 Monitoring Test Instance: $INSTANCE_ID"
echo "📍 Region: $REGION"
echo "⏰ Time: $(date)"
echo ""

# Get instance status
echo "📊 Instance Status:"
aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --region $REGION \
    --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,Placement.AvailabilityZone,PrivateIpAddress,PublicIpAddress]' \
    --output table

echo ""
echo "🏷️ Instance Tags:"
aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --region $REGION \
    --query 'Reservations[*].Instances[*].Tags[*].[Key,Value]' \
    --output table

echo ""
echo "🌐 Network Information:"
aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --region $REGION \
    --query 'Reservations[*].Instances[*].[InstanceId,PrivateIpAddress,PublicIpAddress,SubnetId,VpcId]' \
    --output table

echo ""
echo "🔒 Security Groups:"
aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --region $REGION \
    --query 'Reservations[*].Instances[*].SecurityGroups[*].[GroupId,GroupName]' \
    --output table

echo ""
echo "✅ Instance is ready for dashboard verification!"
echo "🌍 Check AWS Console: https://menteebot-observability.signin.aws.amazon.com/console"
echo "📍 Region: eu-north-1"
echo "🏷️ Name: dashboard-test-instance" 