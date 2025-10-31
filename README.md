# 🔐 Multi-Cloud KMS Lab — AWS | Azure | GCP

> Learn, build, automate, and compare Key Management across the top 3 clouds — from beginner → advanced — with encryption applied to real cloud assets: Storage, Databases, Secrets, IAM, BYOK, Rotation & Monitoring.

---

## ✅ Course Progress

| Day | Cloud | Topic | Status | Link |
|---:|:------|-------|:-----:|------|
| 1 | ☁️ Multi-Cloud | Encryption Fundamentals | ✅ | [Day 1 – Foundations](common/resources/day1-foundations.md) |
| 2 | 🟦 AWS | Beginner – S3 + EBS + KMS CMK | ✅ | [Day 2 – AWS Beginner](aws/beginner/README.md) |
| 3 | 🟩 Azure | Beginner – Blob + Key Vault CMK | ✅ | [Day 3 – Azure Beginner](azure/beginner/README.md) |
| 4 | 🟨 GCP | Beginner – Storage + Cloud KMS CMEK | ✅ | [Day 4 – GCP Beginner](gcp/beginner/README.md) |
| 5 | 🌐 **Multi-Cloud** | Databases & Secrets Encryption | ✅ | [Day 5 – Multi-Cloud Databases](common/day5-databases/README.md) |
| 6 | 🌐 Multi-Cloud | Key Access Federation (DEK Re-wrap: AWS→Azure→GCP) | ✅ | [Day 6 – Cross-Cloud Federation](cross-cloud/day6/README.md) |
| 7 | 🌐 Multi-Cloud | Rotation Automation (Terraform) | ✅ | [Day 7 – Rotation Automation](common/resources/day7-rotation.md) |
| 8 | 🌐 Multi-Cloud | IAM Access + Audit & Monitoring | ✅ | [Day 8 – Identity & Audit](common/resources/day8/day8-identity-access.md) |
| 9 | 🌐 Multi-Cloud | Governance + Monitoring | ✅ | [Day 9 – Governance & Monitoring](common/resources/day9/day9-governance-monitoring.md) |
| 10 | 🌐 Multi-Cloud | Incident Response | ✅ | [Day 10 – Incident Response](common/resources/day10/day10-incident-response.md) |

---

## 🧩 Day 5 – Databases Encryption with CMEK (AWS | Azure | GCP)

> **Goal:** Apply customer-managed encryption keys to database services across all major clouds.

| Cloud | Service | Encryption | IaC Example | Status |
|-------|----------|-------------|--------------|---------|
| ☁️ AWS | RDS (PostgreSQL) | AWS KMS + IAM Auth | [Terraform & CloudFormation](aws/day5/iac) | ✅ |
| ☁️ Azure | PostgreSQL Flexible Server | Azure Key Vault (CMK) | [Terraform & ARM](azure/day5/iac) | ✅ |
| ☁️ GCP | Cloud SQL (PostgreSQL) | Cloud KMS (CMEK) + Secret Manager | [Terraform](gcp/day5/iac) | ✅ |

### 🌐 Visual Overview
```mermaid
flowchart LR
  subgraph AWS
    A1[RDS (PostgreSQL)] --> K1[AWS KMS Key]
  end

  subgraph Azure
    A2[PostgreSQL Flexible Server] --> K2[Azure Key Vault Key]
  end

  subgraph GCP
    A3[Cloud SQL (PostgreSQL)] --> K3[GCP Cloud KMS Key]
  end

  K1 -->|Encrypts| D1[(Database Data)]
  K2 -->|Encrypts| D1
  K3 -->|Encrypts| D1
```

---

  K1 & K2 & K3 --> M[🧭 Multi-Cloud Key Governance (CMK/CMEK)]
Progress: 🟩🟩🟩🟩🟩⬜⬜⬜⬜⬜ (5 of 10 days complete)

## 🧠 Visual Concept – Envelope Encryption

```mermaid
sequenceDiagram
    participant App
    participant KMS as KMS (HSM)
    participant Store as Data Store
    App ->> KMS: Generate Data Key
    KMS -->> App: Plaintext DK + Ciphertext DK
    App ->> Store: Encrypt data w/ Plaintext DK + store Ciphertext DK
    App ->> KMS: Decrypt Ciphertext DK (when needed)
    App ->> Store: Decrypt data in-memory only
📂 Repo Structure
text
Copy code
multi-cloud-kms-lab/
├── README.md  ← You Are Here ✅
├── aws/
│   ├── beginner/
│   │   ├── README.md ✅ Day 2
│   │   └── iac/terraform + cloudformation
├── azure/
│   ├── beginner/
│   │   ├── README.md ✅ Day 3
│   │   └── iac/arm + terraform
├── gcp/
│   ├── beginner/
│   │   ├── README.md ✅ Day 4
│   │   └── iac/terraform + dm (optional)
└── common/
    └── resources/day1-foundations.md ✅ Day 1
🚀 Continue to Day 5 → Databases & Secrets Encryption
