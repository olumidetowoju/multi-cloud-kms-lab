# 🔐 Multi-Cloud KMS Lab  
**AWS | Azure | GCP Encryption Mastery**  
Hands-on labs with enterprise architecture patterns

---

## 🎯 Badges

![AWS Badge](https://img.shields.io/badge/AWS-KMS-orange?logo=amazon-aws)
![Azure Badge](https://img.shields.io/badge/Azure-Key_Vault-blue?logo=microsoft-azure)
![GCP Badge](https://img.shields.io/badge/GCP-KMS-yellow?logo=google-cloud)
![IaC Badge](https://img.shields.io/badge/IaC-Terraform%20%7C%20CloudFormation%20%7C%20ARM%20%7C%20GDM-9cf?logo=terraform)
![Editor Badge](https://img.shields.io/badge/Editor-nano-green?logo=gnu)
![Learning Style](https://img.shields.io/badge/Textbook-Hands--On-success)

---

## ✅ Student Progress Tracker

| Day | Topic | Status |
|---:|-------|:------:|
| 1 | Foundations | ✅ |
| 2 | AWS Beginner | 🔄 In Progress |
| 3 | Azure Beginner | ⏳ Pending |
| 4 | GCP Beginner | ⏳ Pending |
| 5 | Databases & Secrets | ⏳ Pending |
| 6 | Cross-cloud Access | ⏳ Pending |
| 7 | Rotation Automation | ⏳ Pending |
| 8 | BYOK & HSM | ⏳ Pending |
| 9 | Audit & Forensics | ⏳ Pending |
| 10 | Architecture Review + Exam | ⏳ Pending |

> Progress automatically updated through commits ✅

---

## 📚 Table of Contents

- ▶ **[Day 1 — Foundations](common/resources/day1-foundations.md)**
- ▶ **[Day 2 — AWS Beginner: S3 + EBS + KMS](aws/beginner/README.md)**
- ▶ **Day 3 — Azure Beginner: Blob + Key Vault** (Coming Soon)
- ▶ **Day 4 — GCP Beginner: Cloud Storage + KMS** (Coming Soon)
- ▶ **Days 5–10 — Multi-Cloud Advancing Topics** (Coming Soon)

---

## 🧩 Core Concept: Why KMS?

KMS is the **vault** inside a cloud fortress that handles encryption so your applications never touch the master key.

---

## 📌 Envelope Encryption (High-Level)

```mermaid
flowchart LR
A[Plaintext Data] -->|Encrypt with DK| B[Encrypted Data]
B --> C[Ciphertext Data Key]
C -->|Unlock via KMS| A
🔐 KMS = Vault Authority
📦 Data Key = Worker Lock
🛑 App never sees the Master Key

🧠 Learning Format
Textbook style lessons 📘

Hands-on cloud labs 🧪

Automation (Terraform + Native IaC) ⚙️

Validation + Cleanup ✅

Interview-style knowledge checks 🧠

📌 Begin now → Day 1: Foundations
📌 Next → Day 2: AWS Beginner
