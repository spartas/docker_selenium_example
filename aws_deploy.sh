#!/usr/bin/env bash
set -Eeuo pipefail

# Requirements: aws command line interface, docker, jq
# A CLI user with appropriate permissions to execute this script

# Parameters
# AWS region, ECR repository

# Services
#   IAM, EC2, ECR

DATE=$(date +%Y%m%d)

REGION="us-east-2"
CONTAINER_IMG="docker_selenium_example"
INSTANCE_TYPE="t3.nano"
IAM_ROLE_NAME="EC2_Container_Pull"
DEST_AMI_DESC="${CONTAINER_IMG} built from Amazon 2 Linux image on ${DATE}"

# If blank, we will create the repository URL. Otherwise, we will use the specified URL
URL_ECR_REPO=""

### Body
SOURCE_AMI_NAME="amzn-ami-hvm-2018.03.0.20181129-x86_64-gp2"

# 1. Push selenium_docker to AWS ECR
$(aws ecr get-login --no-include-email --region "$REGION")

if [ -z "$URL_ECR_REPO" ];
then
URL_ECR_REPO=`aws --region "$REGION" ecr describe-repositories | jq -cr '.repositories[] | select(.repositoryName == "'${CONTAINER_IMG}'") | .repositoryUri' `

  if [ -z "$URL_ECR_REPO" ];
  then
    URL_ECR_REPO=`aws --region "$REGION" ecr create-repository --repository-name "$CONTAINER_IMG" | jq -r '.["repository"]["repositoryUri"]'`
  fi
fi

docker build -t "$CONTAINER_IMG" .
docker tag "${CONTAINER_IMG}:latest" "$URL_ECR_REPO/${CONTAINER_IMG}:latest"
docker push "$URL_ECR_REPO:latest"

sed -e "s|{ECR_URL}|${URL_ECR_REPO}|" cloud/aws/user_data.sh > cloud/aws/user_data_mod.sh
sed -i.bak -e "s|{CONTAINER_IMG_NAME}|${CONTAINER_IMG}|" cloud/aws/user_data_mod.sh && rm -- cloud/aws/user_data_mod.sh.bak

# 2.0 Create an IAM role for the instance(s) to be able to pull from ECR
aws --region "$REGION" iam create-role --role-name "$IAM_ROLE_NAME" --assume-role-policy-document file://cloud/aws/ec2_ecr_role_policy.json
aws --region "$REGION" iam put-role-policy --role-name "$IAM_ROLE_NAME" --policy-name EC2_ECR --policy-document file://cloud/aws/ec2_container_pull.json
IAM_IP_ARN=`aws --region "$REGION" iam create-instance-profile --instance-profile-name "$IAM_ROLE_NAME" | jq -r '.["InstanceProfile"]["Arn"]'`
aws --region "$REGION" iam add-role-to-instance-profile --instance-profile-name "$IAM_ROLE_NAME" --role-name "$IAM_ROLE_NAME"

# Wait for 30s before running the instance
echo "Waiting 10 seconds for the IAM instance profile to become available…"
sleep 10s

# 2.1. Create an AWS instance and pull the docker image onto the instance
SOURCE_AMI=`aws --region "$REGION" ec2 describe-images --filters "Name=name,Values=$SOURCE_AMI_NAME" | jq -r '.["Images"][]["ImageId"]'`
JSON_INSTANCE=`aws --region "$REGION" ec2 run-instances  --image-id "$SOURCE_AMI" --instance-type "$INSTANCE_TYPE" --count 1 --key-name ami --iam-instance-profile "Arn=${IAM_IP_ARN}" --user-data file://cloud/aws/user_data_mod.sh --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${CONTAINER_IMG}}]"`
INSTANCE_ID=`echo "$JSON_INSTANCE" | jq -r '.["Instances"][0]["InstanceId"]'`

VOLUME_ID=`aws --region "$REGION" ec2 describe-volumes --filters Name=attachment.instance-id,Values="$INSTANCE_ID" | jq -r '.["Volumes"][0]["VolumeId"]'`

echo "Instance ID: $INSTANCE_ID; Volume ID: $VOLUME_ID"

rm cloud/aws/user_data_mod.sh

echo "Waiting 90 seconds for the EC2 instance to fully become available…"
sleep 90s

# 3. Create an AMI from the running instance 
DEST_AMI_ID=`aws --region "$REGION" ec2 create-image --description "$DEST_AMI_DESC" --instance-id "$INSTANCE_ID" --name "$CONTAINER_IMG" | jq -r '.["ImageId"]'`

echo "Waiting 45 seconds for the image and snapshots to be created…"
sleep 45s

# 4. Get the snapshot id from the image and tag the snapshot
SNAP_ID=`aws --region "$REGION" ec2 describe-images --image-ids $DEST_AMI_ID | jq -r '.["Images"][]["BlockDeviceMappings"][]["Ebs"]["SnapshotId"]'`

CMD="aws --region "$REGION" ec2 create-tags --resources "$SNAP_ID" --tags "Key=Name,Value=${CONTAINER_IMG}""
`$CMD`

# 5. Create the launch template
STR_IAM_IP=`printf "\"IamInstanceProfile\":{\"Arn\":\"%s\",\"Name\":\"%s\"}" "$IAM_IP_ARN" "$IAM_ROLE_NAME"`
STR_INSTANCE_TYPE=`printf "\"InstanceType\":\"%s\"" "$INSTANCE_TYPE"`
STR_IMAGE_ID=`printf "\"ImageId\":\"%s\"" "$DEST_AMI_ID"`

STR_JSON_TMPL_DATA=`printf "{%s,%s,%s}" "$STR_IAM_IP" "$STR_INSTANCE_TYPE" "$STR_IMAGE_ID"`

CMD="aws --region $REGION ec2 create-launch-template --launch-template-name ${CONTAINER_IMG}_tmpl --version-description \"v1\" --launch-template-data $STR_JSON_TMPL_DATA"
$CMD

echo "Waiting…"
sleep 10

# 6. Terminate the instance
echo "Cleaning up"
echo "Terminating instance"
aws --region "$REGION" ec2 terminate-instances --instance-ids "$INSTANCE_ID" >/dev/null

exit 0
