# docker\_selenium\_example

## Requirements
 * [Docker]

## Changelog
 * 20190708 - Update alpine to v3.10.0
 * 20190513 - Update alpine to v3.9.4; Use `Makefile` for testing
 * 20190422 - Update alpine to v3.9.3
 * 20190311 - Update alpine to v3.9.2

## Run the example
`make test`

### AWS Deployment (aws\_deploy.sh)
 * [AWS Command-line interface]
 * [jq]

aws\_deploy.sh will set up the necessary role permissions, push the docker 
image to AWS Container registry service. It will then launch an EC2 
instance, which will install docker, download the built docker image, 
configure itself to run docker at boot, and run the example python script.

Finally, it will create an AMI (and snaphot) of the running instance, 
create a launch template, and delete the running instance.

A fresh instance can be run at any time by running the launch template.

#### Deploy to AWS

In the AWS console, create a new CLI user (with Programmatic Access) with 
the following policy:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateImage",
                "ec2:CreateLaunchTemplate",
                "ec2:CreateLaunchTemplateVersion",
                "ec2:CreateTags",
                "ec2:DeleteLaunchTemplate",
                "ec2:DeleteSnapshot",
                "ec2:DeregisterImage",
                "ec2:DescribeImages",
                "ec2:DescribeInstances",
                "ec2:DescribeSnapshots",
                "ec2:DescribeVolumes",
                "ec2:RunInstances",
                "ec2:TerminateInstances",
                "ecr:BatchCheckLayerAvailability",
                "ecr:CompleteLayerUpload",
                "ecr:CreateRepository",
                "ecr:DescribeRepositories",
                "ecr:GetAuthorizationToken",
                "ecr:InitiateLayerUpload",
                "ecr:PutImage",
                "ecr:TagResource",
                "ecr:UploadLayerPart",
                "iam:AddRoleToInstanceProfile",
                "iam:CreateInstanceProfile",
                "iam:CreateRole",
                "iam:DeleteInstanceProfile",
                "iam:DeleteRole",
                "iam:DeleteRolePolicy",
                "iam:PassRole",
                "iam:PutRolePolicy",
                "iam:RemoveRoleFromInstanceProfile"
            ],
            "Resource": "*"
        }
    ]
}
```

1. Run `aws configure` to set up the user on the command line with the 
listed Access key ID and Secret access key.
2. Run `./aws_deploy` to deploy to AWS.

[Docker]: https://www.docker.com
[AWS Command-line interface]: https://aws.amazon.com/cli/
[jq]: https://stedolan.github.io/jq/
