# Multi-Cloud KMS Lab (AWS | Azure | GCP)

> **Tagline:** Learn, build, and compare cloud-native key management from zero to advanced — with diagrams, analogies, and hands-on IaC — using AWS KMS, Azure Key Vault (Keys), and Google Cloud KMS.

---

## 🧠 Why This Course?

Think of **KMS** as the **vault** inside a fortress.  
Applications never handle the master key — they **request encryption services** from the vault.

✅ Keys protected in HSMs  
✅ Access logged for compliance  
✅ Zero-trust encryption enabled

---

## 🚀 Course Structure (10 Days)

| Day | Focus | Tracks |
|---:|---|---|
| 1 | Foundations → Encryption basics | All clouds |
| 2 | AWS Beginner | S3, EBS |
| 3 | Azure Beginner | Blob |
| 4 | GCP Beginner | Cloud Storage |
| 5 | Databases | RDS, SQL, BigQuery |
| 6 | Cross-cloud Access | Federation |
| 7 | Rotation Automation | Terraform & CLI |
| 8 | BYOK / External Keys | HSM / Import |
| 9 | Audit & Forensics | Logs & SIEM |
| 10 | Architecture Review | Exam + Diagrams |

> Every section uses **nano**, CLI, and optional IaC.

---

## 🧩 Core Concept: Envelope Encryption

**Analogy:**  
Data is a package.  
The **data key** locks that one package.  
The **master key** in KMS locks the data key (you never see the master key).

Even if a thief steals the package, they **cannot decrypt without asking KMS**.

### Diagram (Mermaid)
```mermaid
sequenceDiagram
    participant App
    participant KMS as Vault (KMS/HSM)
    participant Store as Storage
    App->>KMS: Request Data Key
    KMS-->>App: {PlaintextDK, CiphertextDK}
    App->>Store: Save {EncryptedData + CiphertextDK}
    App->>KMS: Decrypt CiphertextDK when needed
    App->>App: Decrypt Data Key (short-lived)
## 🧠 Why This Course?

Think of **KMS** as the **vault** in a high-security building.  
Applications are visitors who need valuables (encryption) — but **KMS never gives out the master key**.  
Instead, it provides temporary “worker keys” to encrypt data and them destroys them fast.

✅ Keys stay protected  
✅ Access logged  
✅ Zero-trust encryption

---

## ✅ What You Will Learn

| Skill Category | Beginner | Intermediate | Advanced |
|---------------|:-------:|:------------:|:--------:|
| Key lifecycle | ✅ | ✅ | ✅ |
| Envelope encryption | ✅ | ✅ | ✅ |
| Policies & IAM | ✅ | ✅ | ✅ |
| Service integration | | ✅ | ✅ |
| Cross-cloud governance | | | ✅ |
| BYOK/HSM | | | ✅ |
| Audit automation | | ✅ | ✅ |

---

## 📅 Course Map (10 Days)

| Day | Focus |
|---:|-------|
| 1 | Foundations — Crypto, Envelope Encryption, IAM |
| 2 | AWS Beginner — S3 & EBS Encryption w/ CMK |
| 3 | Azure Beginner — Blob Encryption w/ Key Vault |
| 4 | GCP Beginner — Cloud Storage Encryption |
| 5 | Databases & Secrets Encryption |
| 6 | Cross-Account / Cross-Subscription / Cross-Project Access |
| 7 | Auto Key Rotation (Terraform & CLI) |
| 8 | BYOK — Importing & External Keys |
| 9 | Logging & Forensics — CloudTrail / Monitor / Audit Logs |
| 10 | Multi-Cloud Architecture + Hands-on Exam |

---

## 🏗️ Repository Layout


