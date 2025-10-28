# Multi-Cloud KMS Lab (AWS | Azure | GCP)

> Learn, build, and compare cloud-native key management from zero to advanced — with diagrams, analogies, and hands-on IaC — using AWS KMS, Azure Key Vault (Keys), and Google Cloud KMS.

---

## 🔗 Quick Launch

- ▶ **Start Day 1:** [KMS Foundations](common/resources/day1-foundations.md)
- 🟦 **AWS Beginner (Day 2):** [S3 & EBS with KMS](aws/beginner/README.md)
- 🟩 **Azure Beginner (Day 3):** [Blob + Key Vault](azure/beginner/README.md)
- 🟨 **GCP Beginner (Day 4):** [Cloud Storage + KMS](gcp/beginner/README.md)

> If a link shows a folder or 404, that lab is just not committed **yet**—we’ll add it next.

---

## 📚 Directory (clickable)

### Days (1–10)
1. **[Day 1 — Foundations](common/resources/day1-foundations.md)**  
2. **[Day 2 — AWS Beginner: S3 & EBS + KMS](aws/beginner/README.md)**  
3. **[Day 3 — Azure Beginner: Blob + Key Vault](azure/beginner/README.md)**  
4. **[Day 4 — GCP Beginner: Cloud Storage + KMS](gcp/beginner/README.md)**  
5. **[Day 5 — Databases & Secrets (AWS/Azure/GCP)](aws/intermediate/README.md)** *(coming soon)*  
6. **[Day 6 — Cross-Account/Subscription/Project Access](gcp/intermediate/README.md)** *(coming soon)*  
7. **[Day 7 — Rotation Automation (Cross-Cloud)](cross-cloud/day7-key-rotation-automation/README.md)**  
8. **[Day 8 — BYOK & External Key Manager](cross-cloud/day8-byok-ekm/README.md)**  
9. **[Day 9 — Audit & Forensics](cross-cloud/day9-audit/README.md)**  
10. **[Day 10 — Architecture & Governance](cross-cloud/day10-architecture/README.md)**  

### Cloud Tracks
- **AWS:** [Beginner](aws/beginner/) • [Intermediate](aws/intermediate/) • [Advanced](aws/advanced/)  
- **Azure:** [Beginner](azure/beginner/) • [Intermediate](azure/intermediate/) • [Advanced](azure/advanced/)  
- **GCP:** [Beginner](gcp/beginner/) • [Intermediate](gcp/intermediate/) • [Advanced](gcp/advanced/)  

### Diagrams (anchors)
- 🔐 [Envelope Encryption](#envelope-encryption-diagram)  
- 🏛️ [Multi-Cloud Governance](#multi-cloud-governance-diagram)  

---

## 🧭 How to Use This Repo

1) Pick your **Day** from the list above.  
2) Open the lab file (always nano-first).  
3) Follow the **CLI + IaC** steps, validate, and run the cleanup.  
4) Commit your notes as you go.

```bash
# examples
nano aws/beginner/README.md
nano azure/beginner/README.md
nano gcp/beginner/README.md
🧩 Concept: KMS in Plain Words
KMS is your vault. Apps never carry the master key; they ask the vault to lock/unlock data keys and everything is audited.

✅ Prereqs (Quick Check)
bash
Copy code
aws sts get-caller-identity
az account show --query "{tenant:tenantId, subscription:id}"
gcloud config list --format='value(core.project)'
terraform -version
🔐 Envelope Encryption Diagram
Envelope Encryption Diagram
mermaid
Copy code
sequenceDiagram
    participant App
    participant KMS as Vault (KMS/HSM)
    participant Store as Storage
    App->>KMS: Generate Data Key
    KMS-->>App: {PlaintextDK, CiphertextDK}
    App->>Store: Save {EncryptedData + CiphertextDK}
    App->>KMS: Decrypt CiphertextDK when needed
    App->>App: Decrypt Data (short-lived key)
🏛️ Multi-Cloud Governance Diagram
Multi-Cloud Governance Diagram
mermaid
Copy code
flowchart LR
  subgraph AWS
    A[KMS CMK] --> AR[IAM Roles/Policies]
  end
  subgraph Azure
    B[Key Vault Keys] --> BR[Entra ID RBAC]
  end
  subgraph GCP
    C[Cloud KMS Keys] --> CR[Service Accounts]
  end
  A --- G(((Central Logs)))
  B --- G
  C --- G
  classDef default fill:#f7f9ff,stroke:#6b7cff,stroke-width:1px
🧹 Cleanup & Safety
Least privilege on all identities

Enable logging before usage

Use customer-managed keys for control

Always include teardown commands

✉️ Feedback / TODOs
 Add Day 2 fully (AWS Beginner)

 Add Day 3 fully (Azure Beginner)

 Add Day 4 fully (GCP Beginner)

 Add database encryption labs (Day 5)

 Add cross-account/project labs (Day 6)
