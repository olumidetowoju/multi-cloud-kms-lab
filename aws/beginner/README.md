# 🔐 Day 2 — AWS Beginner: S3 & EBS Encryption with KMS  
Multi-Cloud KMS Lab | Region: us-east-1

---

## 🎯 Learning Objectives
- Create and manage a **symmetric CMK** (Customer-Managed Key)
- Encrypt S3 objects using **SSE-KMS**
- Create a snapshot from an EC2 root volume and **copy it encrypted** with your CMK
- Inspect logs with **CloudTrail**
- **Cleanup everything** to avoid billing

---

## 🧭 Architecture Overview
```mermaid
flowchart TB
    subgraph KMS
        K1["CMK: alias/mc-day2-beginner"]
    end
    subgraph Compute
        EC2["t2.micro (temp)"]
        EBS["Root EBS Volume"]
    end
    S3["S3 Bucket (SSE-KMS)"]
    SNAP["Encrypted Snapshot Copy"]

    EC2 --> EBS
    EBS -- Snapshot --> SNAP
    S3 -- SSE-KMS --> K1
    SNAP --> K1
Tagging: all resources use mc-lab=kms-day2 to enable one-shot cleanup.

✅ Prereqs
AWS CLI authenticated as your lab user

Default region: us-east-1

Installed: aws, jq (optional), and permissions for KMS/S3/EC2/CloudTrail

Quick check:

bash
Copy code
aws sts get-caller-identity
🧪 CLI Lab — Step by Step
Use these as live commands or as a reference. We already validated them during the hands-on walk-through.

1) Create KMS CMK + Alias
bash
Copy code
export AWS_REGION="us-east-1"

KEY_ID=$(aws kms create-key \
  --description "KMS Day2 Beginner" \
  --tags TagKey=mc-lab,TagValue=kms-day2 \
  --query KeyMetadata.KeyId \
  --output text --region "$AWS_REGION")

aws kms create-alias \
  --alias-name alias/mc-day2-beginner \
  --target-key-id "$KEY_ID" \
  --region "$AWS_REGION"

aws kms describe-key --key-id "$KEY_ID" \
  --query 'KeyMetadata.{Enabled:Enabled,Arn:Arn}' --region "$AWS_REGION"
2) S3 — SSE-KMS object encryption
bash
Copy code
BUCKET="kms-day2-$(date +%s)"
aws s3api create-bucket --bucket "$BUCKET" --region "$AWS_REGION"

echo "Hello KMS" > demo.txt
aws s3 cp demo.txt "s3://$BUCKET/demo.txt" \
  --sse aws:kms --sse-kms-key-id "alias/mc-day2-beginner" --region "$AWS_REGION"

aws s3api head-object --bucket "$BUCKET" --key demo.txt \
  --query '{SSE:ServerSideEncryption,KMSKey:SSEKMSKeyId}' --region "$AWS_REGION"
3) EC2 → Snapshot → Encrypted Copy
bash
Copy code
AMI=$(aws ssm get-parameters \
  --names /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
  --query 'Parameters[0].Value' --output text --region "$AWS_REGION")

INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI" --instance-type t2.micro \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=mc-lab,Value=kms-day2}]' \
  --query 'Instances[0].InstanceId' --output text --region "$AWS_REGION")

aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" --region "$AWS_REGION"

ROOT_VOL=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.VolumeId' \
  --output text --region "$AWS_REGION")

SRC_SNAP=$(aws ec2 create-snapshot --volume-id "$ROOT_VOL" \
  --description "kms-day2-temp-unencrypted" \
  --query SnapshotId --output text --region "$AWS_REGION")

aws ec2 create-tags --resources "$SRC_SNAP" --tags Key=mc-lab,Value=kms-day2 --region "$AWS_REGION"

ENC_SNAP=$(aws ec2 copy-snapshot --source-region "$AWS_REGION" \
  --source-snapshot-id "$SRC_SNAP" --encrypted --kms-key-id "alias/mc-day2-beginner" \
  --description "kms-day2-encrypted-copy" \
  --query SnapshotId --output text --region "$AWS_REGION")

aws ec2 wait snapshot-completed --snapshot-ids "$ENC_SNAP" --region "$AWS_REGION"

aws ec2 describe-snapshots --snapshot-ids "$ENC_SNAP" \
  --query 'Snapshots[0].Encrypted' --output text --region "$AWS_REGION"
# expect: True
4) CloudTrail evidence (optional)
bash
Copy code
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventSource,AttributeValue=kms.amazonaws.com \
  --max-results 10 --region "$AWS_REGION" \
  --query 'Events[].EventName'
🧹 Cleanup (No Billing Risk)
bash
Copy code
# if shell restarted, recover vars:
# KEY_ID=$(aws kms describe-key --key-id alias/mc-day2-beginner --query 'KeyMetadata.KeyId' --output text --region us-east-1)
# set the bucket name you created earlier:
# BUCKET=<your-bucket-name>

aws s3 rm "s3://$BUCKET" --recursive --region us-east-1 || true
aws s3 rb "s3://$BUCKET" --region us-east-1 || true

aws ec2 terminate-instances --instance-ids "$INSTANCE_ID" --region us-east-1 || true
aws ec2 wait instance-terminated --instance-ids "$INSTANCE_ID" --region us-east-1 || true

aws ec2 delete-snapshot --snapshot-id "$ENC_SNAP" --region us-east-1 || true
aws ec2 delete-snapshot --snapshot-id "$SRC_SNAP" --region us-east-1 || true

aws kms schedule-key-deletion --key-id "$KEY_ID" --pending-window-in-days 7 --region us-east-1 || true
Tag audit (should be empty after a minute):

bash
Copy code
aws resourcegroupstaggingapi get-resources \
  --tag-filters Key=mc-lab,Values=kms-day2 \
  --query 'ResourceTagMappingList[].ResourceARN' --region us-east-1
⚙️ Terraform Automation (Optional)
Files:

swift
Copy code
aws/beginner/iac/terraform/main.tf
hcl
Copy code
terraform {
  required_version = ">= 1.5.0"
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
}
provider "aws" { region = var.region }

variable "region"        { default = "us-east-1" }
variable "bucket_prefix" { default = "kms-day2-tf" }
variable "alias"         { default = "mc-day2-beginner" }

resource "aws_kms_key" "cmk" {
  description             = "KMS Day2 Beginner (Terraform)"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags = { mc-lab = "kms-day2" }
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${var.alias}"
  target_key_id = aws_kms_key.cmk.key_id
}

resource "random_id" "rand" { byte_length = 4 }

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_prefix}-${random_id.rand.hex}"
  tags   = { mc-lab = "kms-day2" }
}

resource "aws_s3_object" "obj" {
  bucket       = aws_s3_bucket.bucket.id
  key          = "demo.txt"
  content      = "Hello KMS (Terraform)"
  server_side_encryption = "aws:kms"
  kms_key_id   = aws_kms_alias.alias.arn
}

output "bucket"  { value = aws_s3_bucket.bucket.id }
output "key_arn" { value = aws_kms_key.cmk.arn }
Run:

bash
Copy code
cd aws/beginner/iac/terraform
terraform init
terraform apply -auto-approve
# destroy when done
terraform destroy -auto-approve
🧱 CloudFormation (Optional)
File:

swift
Copy code
aws/beginner/iac/cloudformation/template.yaml
yaml
Copy code
AWSTemplateFormatVersion: '2010-09-09'
Description: KMS Day2 Beginner (CFN) - CMK + Alias + S3 Bucket
Resources:
  KmsKey:
    Type: AWS::KMS::Key
    Properties:
      Description: "KMS Day2 Beginner (CFN)"
      EnableKeyRotation: true
      KeyPolicy:
        Version: '2012-10-17'
        Statement:
          - Sid: AllowAccountRoot
            Effect: Allow
            Principal:
              AWS: !Sub arn:aws:iam::${AWS::AccountId}:root
            Action: 'kms:*'
            Resource: '*'
      Tags:
        - Key: mc-lab
          Value: kms-day2

  KmsAlias:
    Type: AWS::KMS::Alias
    Properties:
      AliasName: alias/mc-day2-beginner
      TargetKeyId: !Ref KmsKey

  Bucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub "kms-day2-cfn-${AWS::AccountId}-${AWS::Region}-${AWS::StackName}"

Outputs:
  KeyId:   { Value: !Ref KmsKey }
  KeyArn:  { Value: !GetAtt KmsKey.Arn }
  Bucket:  { Value: !Ref Bucket }
Deploy:

bash
Copy code
cd aws/beginner/iac/cloudformation
aws cloudformation deploy \
  --template-file template.yaml \
  --stack-name kms-day2-beginner-cfn \
  --capabilities CAPABILITY_NAMED_IAM \
  --region us-east-1
Upload an encrypted object with the alias:

bash
Copy code
CFN_BUCKET=$(aws cloudformation describe-stacks --stack-name kms-day2-beginner-cfn \
  --query 'Stacks[0].Outputs[?OutputKey==`Bucket`].OutputValue' --output text --region us-east-1)

echo "CFN hello" > cfn-demo.txt
aws s3 cp cfn-demo.txt "s3://$CFN_BUCKET/cfn-demo.txt" \
  --sse aws:kms --sse-kms-key-id alias/mc-day2-beginner --region us-east-1
Delete stack (bucket must be empty first):

bash
Copy code
aws s3 rm "s3://$CFN_BUCKET" --recursive --region us-east-1
aws cloudformation delete-stack --stack-name kms-day2-beginner-cfn --region us-east-1
aws cloudformation wait stack-delete-complete --stack-name kms-day2-beginner-cfn --region us-east-1
🧠 Knowledge Check
Why is SSE-KMS preferable to SSE-S3 for regulated workloads?

What happens if your CMK is disabled before reads?

How do tags help with governance and cleanup?

⏭ Next
Proceed to Day 3 — Azure Beginner: Blob + Key Vault.
