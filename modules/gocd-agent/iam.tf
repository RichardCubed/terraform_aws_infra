# The GOCD agents uses the following policy to access SSH keys (GitHub for example) stored
# in KMS / Paramater Store.  All keys in KMS are namespaced by environment.  For example 
# "/infra/gocd/*" 
resource "aws_iam_policy" "policy" {
  name = "${var.env}-gocd-agent"
  path = "/"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Action": [
            "ssm:GetParameter"
        ],
        "Resource": "arn:aws:ssm:${var.region}:${var.aws_account_number}:parameter/${var.env}/*"
    }]
}
EOF
}

# We'll need an IAM role for the GOCD agent so we can apply the required IAM access
# policies.
resource "aws_iam_role" "role" {
  name = "${var.env}-gocd-agent"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# We use policy attachments to "attach" the required IAM policies to our agent's IAM role. 
resource "aws_iam_policy_attachment" "attach_1" {
  name = "${var.env}-gocd-agent"
  roles = ["${aws_iam_role.role.name}"]
  policy_arn = "${aws_iam_policy.policy.arn}"
}

# GOCD agents will also need to be able to push and pull container images to and from ECR.
# We'll use the AWS managed power user policy for this.
resource "aws_iam_policy_attachment" "attach_2" {
  name = "${var.env}-gocd-agent"
  roles = ["${aws_iam_role.role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# The final step is to assign our new IAM role to an EC2 instance profile.  This
# can them be applied to our GOCD agent instances.
resource "aws_iam_instance_profile" "profile" {
  name = "${var.env}-gocd-agent"
  role = "${aws_iam_role.role.name}"
}