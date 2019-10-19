// https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html
variable "aws_access_key" {
}

// https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html
variable "aws_secret_access_key" {
}

// https://docs.aws.amazon.com/general/latest/gr/acct-identifiers.html#targetText=The%20AWS%20account%20ID%20is,resources%20in%20other%20AWS%20accounts.
variable "aws_account_number" {
}

// https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html
variable key_name {
}

// https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html
variable "region" {
}

// The prefix (and tag) to use for all provisioned AWS infrastructure
variable "env" {
}

// https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html#targetText=These%20locations%20are%20composed%20of,and%20data%20in%20multiple%20locations.
variable "az_count" {
}
