#!/bin/bash -xe

# Add Bitbucket and Github to the known hosts
mkdir /var/go/.ssh
ssh-keyscan -t rsa -H github.com >> /var/go/.ssh/known_hosts
ssh-keyscan -t rsa -H bitbucket.org >> /var/go/.ssh/known_hosts

# Pull the GitHub SSH keys from the AWS Paramater Store
aws ssm get-parameter --region "${region}" --name "${ssh_key_path}" --output text --query "Parameter"."Value" >> /var/go/.ssh/id_rsa
chown go /var/go/.ssh/id_rsa
chown go /var/go/.ssh/known_hosts
chmod 600 /var/go/.ssh/id_rsa

# Update the agent with the server's IP addres
cat << EOF > /etc/default/go-agent
GO_SERVER_URL=https://${gocd_server_ip}:8154/go
AGENT_WORK_DIR=/var/lib/go-agent
EOF

# Start the GOCD agent
sudo /etc/init.d/go-agent start