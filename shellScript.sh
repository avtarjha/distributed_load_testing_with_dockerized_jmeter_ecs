#!/bin/sh

cd /tmp

file="./run.properties"

if [ -f "$file" ]
then
  echo "$file found."

  while IFS='=' read -r key value
  do
    eval ${key}=${value}
  done < "$file"
else
  echo "$file not found."
fi

# Install aws cli on EC2 container
sudo yum install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -n awscliv2.zip
sudo ./aws/install

# Get CONTAINER_ID, MASTER'S IP ADDRESS AND ALL OTHER IP ADDRESSES
CONTAINER_ID=`docker ps -qf "name=^ecs-master"`
MASTER_IP=`echo $(ec2-metadata -o) | cut -d':' -f 2 | cut -d' ' -f 2`
ALL_IP=`aws ec2 describe-instances --filters "Name=instance.group-name,Values=${AWS_SECURITY_GROUP}" --query 'Reservations[*].Instances[*].[PrivateIpAddress]' --output text`

# FORMAT SLAVES' IP ADDRESS
ALL_IP="${ALL_IP/$MASTER_IP/}"
ALL_IP=`echo $ALL_IP | tr [:space:] ','`

if [[ $ALL_IP == ,* ]]
then
	ALL_IP=$(echo $ALL_IP | cut -c 2-)
fi

if [[ $ALL_IP == *, ]]
then
	ALL_IP=${ALL_IP:0:${#ALL_IP} - 1}
fi

echo $ALL_IP

# RUN TESTS
docker exec -t $CONTAINER_ID rm -R /opt/Sharedvolume/${JMX_FILE_NAME}
docker exec -t $CONTAINER_ID aws s3 cp ${S3_BUCKET_URL}/${JMX_FILE_NAME} /opt/Sharedvolume
docker exec -t $CONTAINER_ID jmeter -n -t /opt/Sharedvolume/${JMX_FILE_NAME} -Dserver.rmi.ssl.disable=true -R $ALL_IP -l /opt/Sharedvolume/${LOG_FILE_NAME}
aws s3 cp /opt/Sharedvolume/${LOG_FILE_NAME} ${S3_BUCKET_URL}