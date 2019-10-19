# terraform_aws_infra

Provisions a new "infrastructure" VPC, configures the networking and creates instances of the GOCD server and agent.

The VPC is split in to public and private subnets with a bastion host for SSH access to the EC2 instances.  Incoming traffic to the server is routed through an NLB for SSL termination using a certificate from AWS SSM.

You'll find additional userdata.sh startup scripts to configure IP address and pull a GitHub SSH certificate from the AWS Paramater Store as the agent boots-up for the first time.

## TF_VARS

You'll need to specify some variables for Terraform, either in the terraform.tfvars file or via environment variables as a part of a CI/CD pipeline.

aws_access_key<br/>
aws_secret_access_key<br/>
aws_account_number<br/>

key_name (The name of the AWS key to use)<br/>
env (The prefix (and tag) to for all AWS infrastructure)<br/>
region (The AWS region for the target account)<br/>
az_count (The required number of availability zones)

## Deploying

```bash
cd entrypoint
terraform init
terrform apply
```
