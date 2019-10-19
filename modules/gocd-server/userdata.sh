#!/bin/bash -xe

# Add Bitbucket and Github to the known hosts
mkdir /var/go/.ssh
ssh-keyscan -t rsa -H github.com >> /var/go/.ssh/known_hosts
ssh-keyscan -t rsa -H bitbucket.org >> /var/go/.ssh/known_hosts

# Pull the GitHub SSH keys from the AWS Paramater Store
echo sudo aws ssm get-parameter --region "${region}" --name "${ssh_key_path}" --output text --query "Parameter"."Value"
aws ssm get-parameter --region "${region}" --name "${ssh_key_path}" --output text --query "Parameter"."Value" >> /var/go/.ssh/id_rsa

# Ensure the keys are accessable to the go user
chown go /var/go/.ssh/id_rsa
chown go /var/go/.ssh/known_hosts
chmod 600 /var/go/.ssh/id_rsa

# Start the GOCD server
sudo /etc/init.d/go-server start