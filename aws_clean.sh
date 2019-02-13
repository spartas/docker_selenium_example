#!/usr/bin/env bash

REGION="us-east-2"
IAM_ROLE_NAME="EC2_Container_Pull"
CONTAINER_IMG="docker_selenium_example"

echo "Removing Launch Template"
aws --region us-east-2 ec2 delete-launch-template --launch-template-name "${CONTAINER_IMG}_tmpl"

echo "Removing AMI"
IMGID=`aws --region us-east-2 ec2 describe-images --filter Name=name,Values=docker_selenium_example|jq -r '.["Images"][]["ImageId"]'`

for AMI_ID in $IMGID
do
  SNAP_ID=`aws --region "$REGION" ec2 describe-images --image-ids $AMI_ID | jq -r '.["Images"][]["BlockDeviceMappings"][]["Ebs"]["SnapshotId"]'`

  for TAG_SNAP in $SNAP_ID
  do
    aws --region "$REGION" ec2 create-tags --resources "$TAG_SNAP" --tags "Key=Name,Value=${CONTAINER_IMG}"
  done
done

sleep 5

if [ ! -z "$IMGID" ]
then
  echo "aws --region "$REGION" ec2 deregister-image --image-id $IMGID"
  aws --region "$REGION" ec2 deregister-image --image-id $IMGID
fi

echo "Removing Snapshots"
SNAPID=`aws --region us-east-2 ec2 describe-snapshots --filter Name=tag:Name,Values=docker_selenium_example|jq -r '.["Snapshots"][]["SnapshotId"]'`

if [ ! -z "$SNAPID" ]
then
  for SNAPSHOTID in $SNAPID
  do
    echo "aws --region "$REGION" ec2 delete-snapshot --snapshot-id $SNAPSHOTID"
    aws --region "$REGION" ec2 delete-snapshot --snapshot-id $SNAPSHOTID
  done
fi

echo "Removing instances"
IDS=`aws --region us-east-2 ec2 describe-instances --filter Name=tag:Name,Values=docker_selenium_example|jq -r '.["Reservations"][]["Instances"][]["InstanceId"]' |  tr "\n" " "`

for INSTANCEID in $IDS
do
  STR_IDS="${STR_IDS} ${INSTANCEID}"
done

echo "aws --region "$REGION" ec2 terminate-instances --instance-ids $STR_IDS"
aws --region "$REGION" ec2 terminate-instances --instance-ids $STR_IDS

echo "Removing role"
aws --region "$REGION" iam remove-role-from-instance-profile --role-name "$IAM_ROLE_NAME" --instance-profile-name "$IAM_ROLE_NAME"
aws --region "$REGION" iam delete-instance-profile --instance-profile-name "$IAM_ROLE_NAME"

aws --region "$REGION" iam delete-role-policy --role-name "$IAM_ROLE_NAME" --policy-name EC2_ECR 

aws --region "$REGION" iam delete-role --role-name "$IAM_ROLE_NAME"

