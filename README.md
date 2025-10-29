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
| 5 | ☁️ Multi-Cloud | Databases + Secrets Encryption | 🔄 | 🚧 Coming Next |
| 6 | ☁️ Multi-Cloud | Key Access Federation | 🔄 | 🚧 Coming Soon |
| 7 | ☁️ Multi-Cloud | Rotation Automation (Terraform) | 🔄 | 🚧 Coming Soon |
| 8 | ☁️ Multi-Cloud | BYOK / HSM Integration | 🔄 | 🚧 Coming Soon |
| 9 | ☁️ Multi-Cloud | Governance + Monitoring | 🔄 | 🚧 Coming Soon |
| 10 | ☁️ Multi-Cloud | Incident Response | 🔄 | 🚧 Coming Soon |

---

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
