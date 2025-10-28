
---

## (Optional) Create Day 1 now — paste into nano

Run:
```bash
nano common/resources/day1-foundations.md
# Day 1 — KMS Foundations

## Learning objectives
- Understand symmetric vs. asymmetric keys
- Explain envelope encryption
- Know where keys live (HSM-backed) and how apps use them
- Read basic audit logs for key usage

## Analogy: The vault and worker keys
- Master key: locked in the vault (KMS). You never take it out.
- Data key: a temporary “worker key” to encrypt a single file/object.
- Envelope: encrypted data + encrypted data key stored together.

## Diagram
```mermaid
sequenceDiagram
    participant App
    participant KMS as Vault (KMS/HSM)
    participant Store as Storage
    App->>KMS: Generate Data Key
    KMS-->>App: {PlaintextDK, CiphertextDK}
    App->>App: Encrypt data with PlaintextDK
    App->>Store: Save {EncryptedData, CiphertextDK}
    App->>KMS: Decrypt CiphertextDK when needed
    App->>App: Decrypt data (short-lived key)
aws kms list-keys --max-items 5
az keyvault list --output table
gcloud kms keyrings list --location us-central1
git add README.md
git commit -m "README via nano — clean rebuild"
git push
