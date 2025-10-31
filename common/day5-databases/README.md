# 🌍 Day 5 — Databases & Secrets Encryption (Multi-Cloud)

> **Objective:** Learn how databases across AWS, Azure, and GCP use **Customer-Managed Keys (CMK)** and **Secret Managers** for secure, compliant storage.

---

## 📊 Progress Overview

| Cloud | Service | Encryption | Status | Link |
|:------|:---------|:------------|:-------|:------|
| ![AWS Badge](https://img.shields.io/badge/AWS-orange?logo=amazon-aws&logoColor=white) | **[RDS PostgreSQL + Secrets Manager (Terraform & CloudFormation)](../../aws/day5/README.md)** |
| ![Azure Badge](https://img.shields.io/badge/Azure-blue?logo=microsoft-azure&logoColor=white) | **[PostgreSQL Flexible Server + Key Vault (Terraform & ARM)](../../azure/day5/README.md)** |
| ![GCP Badge](https://img.shields.io/badge/GCP-gray?logo=google-cloud&logoColor=white) | **[Cloud SQL PostgreSQL + Cloud KMS (Terraform)](../../gcp/day5/README.md)** |

---

## 🧠 Learning Goals
- Understand **database-level encryption** with Customer-Managed Keys (CMK)
- Implement **key rotation** and **role-based access**
- Store secrets securely with **AWS Secrets Manager**, **Azure Key Vault**, or **GCP Secret Manager**
- Automate provisioning and teardown via **Terraform**, **CloudFormation**, or **ARM**

---

## 🧱 Architecture Overview

```mermaid
flowchart LR
    subgraph AWS
        RDS[(RDS PostgreSQL)]
        AWSKMS[(AWS KMS CMK)]
        SecretMgr[(Secrets Manager)]
        RDS --> AWSKMS
        RDS --> SecretMgr
    end

    subgraph Azure
        PGFS[(PostgreSQL Flexible Server)]
        KV[(Key Vault Key)]
        MI[(Managed Identity)]
        PGFS --> KV
        PGFS --> MI
    end

    subgraph GCP
        SQL[(Cloud SQL PostgreSQL)]
        GCKMS[(Cloud KMS CMK)]
        GSM[(Secret Manager)]
        SQL --> GCKMS
        SQL --> GSM
    end

    AWS --- Azure --- GCP
```
🧩 Lab Directories
Folder	Purpose
aws/day5/	AWS RDS PostgreSQL encrypted with AWS KMS
azure/day5/	Azure PostgreSQL Flexible Server encrypted with Key Vault CMK
gcp/day5/	GCP Cloud SQL PostgreSQL encrypted with Cloud KMS CMEK
common/day5-databases/	Shared docs, notes, and comparisons

✅ Cleanup Policy
Always destroy the lab after completion to avoid billing:

bash
Copy code
terraform destroy -auto-approve
Next Step:
➡ Once GCP Day 5 is complete, we’ll add the final badge and link for full completion.
