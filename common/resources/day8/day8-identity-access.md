# 🌍 Day 8 — Identity and Access Control (IAM Across Clouds)

## 🎯 Goal
Learn how AWS KMS, Azure Key Vault, and Google Cloud KMS integrate with IAM identities, and how to audit their usage with CloudTrail, Azure Monitor, and Cloud Audit Logs.

---

## 💡 Concept

Each cloud logs every KMS key operation (Encrypt, Decrypt, ReEncrypt, GenerateDataKey, etc.) through its native audit system.  
This lab shows you how to query those logs and visualize cross-cloud activity from IAM users, roles, and services.

---

## 🧩 Learning Objectives
By the end of this lab, you will:
- Configure IAM principals for each cloud.
- Apply least-privilege access to encryption keys.
- Enable key access auditing in AWS, Azure, and GCP.
- Aggregate logs into a unified compliance view.

---

## 🗝️ IAM Access Overview
| Cloud | Identity Type | Access Mechanism | Key Scope | Example Action |
|:--|:--|:--|:--|:--|
| **AWS** | IAM User / Role | Key Policy + Grant | CMK | `kms:Encrypt`, `kms:Decrypt` |
| **Azure** | Managed Identity / Service Principal | RBAC / Access Policy | Key Vault Key | `Microsoft.KeyVault/keys/decrypt/action` |
| **GCP** | Service Account | IAM Binding + Role | CryptoKey | `cloudkms.cryptoKeyVersions.useToDecrypt` |

---

## 🧭 Diagram — Cross-Cloud IAM Control Flow
```mermaid
## 🧠 Architecture Diagram

```mermaid
flowchart TB
  subgraph Audit
    A[AWS CloudTrail Logs] --> X[Central Audit Dashboard]
    B[Azure Monitor Logs] --> X
    C[GCP Audit Logs] --> X
  end

  subgraph Identity
    I1[AWS IAM Users/Roles]
    I2[Azure Entra ID Accounts]
    I3[GCP IAM Members]
  end

  I1 --> A
  I2 --> B
  I3 --> C
  X --> R[Review Findings / Alerts / SIEM]
```

---

🪣 Hands-On Steps
1️⃣ AWS: View Key Usage in CloudTrail
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=Encrypt \
  --region us-east-1 \
  --query 'Events[0:5].[EventTime,Username,EventName,Resources]'

2️⃣ Azure: Query KMS Access from Log Analytics
AzureDiagnostics
 | where ResourceProvider == "MICROSOFT.KEYVAULT"
 | where OperationName contains "Encrypt" or OperationName contains "Decrypt"
 | project TimeGenerated, Identity, OperationName, ResultType
 | top 10 by TimeGenerated desc

3️⃣ GCP: List KMS Access in Audit Logs
gcloud logging read \
  'protoPayload.serviceName="cloudkms.googleapis.com" AND protoPayload.methodName:"Decrypt"' \
  --limit=10 \
  --format="table(timestamp, protoPayload.authenticationInfo.principalEmail, protoPayload.methodName)"

4️⃣ (Optional) Aggregate Logs Cross-Cloud

Push all three sources into a central log store (SIEM or OpenSearch) with tags:

mc-lab=kms-day8  environment=dev  source=aws|azure|gcp

📈 Outcome

By the end of this lab you’ll be able to:

View who used which key and when in each cloud.

Detect unauthorized or unusual access patterns.

Centralize logs for cross-cloud KMS security monitoring.

🧹 Cleanup

Disable any temporary log streams or storage buckets created for this lab to avoid ongoing charges.

✅ End of Day 8 – Identity & Audit
