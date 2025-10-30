# ☁️ AWS Day 5 – Database Encryption with RDS + KMS + Secrets Manager

**Goal:** Use AWS KMS CMK to encrypt Amazon RDS (PostgreSQL) data at rest and integrate AWS Secrets Manager for secure credential storage.

---

## 🧠 Concept
In this lab you’ll combine three AWS security layers:
- **KMS CMK** → encrypts the RDS storage volume and snapshots.  
- **RDS (PostgreSQL)** → the managed database service.  
- **Secrets Manager** → safely stores the database admin password and rotation metadata.

---

## 🧱 Architecture Diagram
```mermaid
flowchart TB
  subgraph AWS
    KMS[(KMS CMK)]
    RDS[(RDS PostgreSQL)]
    SM[(Secrets Manager)]
  end

  App[Client App] --> SM :::secret
  SM --> RDS :::db
  RDS --> KMS :::kms
  style KMS fill:#f3f0ff,stroke:#906cff
  style SM fill:#f9f7d0,stroke:#bca600
  style RDS fill:#e2f0ff,stroke:#0078d4
```
pgsql
Copy code

---

## 🧰 Terraform Infrastructure
Directory: `~/multi-cloud-kms-lab/aws/day5-databases/iac/terraform`

### main.tf (Simplified)
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_kms_key" "db" {
  description = "Day 5 RDS Encryption Key"
  enable_key_rotation = true
}

resource "aws_db_instance" "postgres" {
  allocated_storage   = 20
  engine              = "postgres"
  engine_version      = "16.3"
  instance_class      = "db.t3.micro"
  name               = "day5db"
  username           = "postgres"
  password           = random_password.db.result
  kms_key_id         = aws_kms_key.db.arn
  storage_encrypted   = true
  skip_final_snapshot = true
  deletion_protection = false
}

resource "random_password" "db" {
  length        = 16
  special        = true
}

resource "aws_secretsmanager_secret" "db" {
  name = "day5-db-admin"
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id          = aws_secretsmanager_secret.db.id
  secret_string       = jsonencode({
    username = aws_db_instance.postgres.username
    password = random_password.db.result
    endpoint = aws_db_instance.postgres.address
  })
}

output "rds_endpoint" { value = aws_db_instance.postgres.address }
output "kms_key_arn" { value = aws_kms_key.db.arn }
yaml
Copy code

---

## 🚀 Commands
```bash
cd ~/multi-cloud-kms-lab/aws/day5-databases/iac/terraform
terraform init
terraform apply -auto-approve
Retrieve the generated password from Secrets Manager:

bash
Copy code
aws secretsmanager get-secret-value --secret-id day5-db-admin \
  --query 'SecretString' --output text | jq .
Connect to your RDS instance:

bash
Copy code
psql -h $(terraform output -raw rds_endpoint) -U postgres -d postgres -W
📘 Notes
KMS encryption covers data at rest and backups.

Secrets Manager rotations can be automated via Lambda.

The CMK rotates annually when enable_key_rotation = true.

✅ Next Step
Continue to: Day 6 – Cross-Cloud Federation (DEK Re-wrap)
