# 🌐 Day 6 – Cross-Cloud Federation (DEK Re-wrap)

**Goal:** Show how a payload encrypted in **AWS** can be securely shared to **Azure** and **GCP** by **re-wrapping the Data Encryption Key (DEK)** across clouds — with least-privileged roles, full audit logs, and copy-paste CLI.

---

## 🧠 Analogy
Think of the data as a locked box and the DEK as the small key for that box. Each cloud has a **big padlock (KMS CMK)**. We:
1) Lock the box with the small key (DEK)  
2) Lock that small key under AWS’s padlock (wrap DEK with AWS KMS)  
3) When sharing, we briefly unlock the small key with AWS (authorized action), then immediately **re-lock** the same small key under Azure or GCP’s padlock. The box never opens; we just change which padlock protects the small key.

---

## 🔎 Diagram — Re-wrap Flow
```mermaid
sequenceDiagram
  participant App
  participant AWS as AWS KMS (alias/mc-day6)
  participant AZ as Azure Key Vault (mc-day6-key)
  participant GCP as GCP KMS (mc-day6-key)
  App->>AWS: GenerateDataKey ⇒ {Plain, Ciphertext}
  App->>App: Encrypt payload with Plain (AES-256-CBC)
  App->>AWS: Store Ciphertext(DEK) → dek.aws.bin
  App->>AZ: Decrypt via AWS ⇒ Plain → RSA-OAEP-256 → dek.az.bin
  App->>GCP: Decrypt via AWS ⇒ Plain → CMEK encrypt → dek.gcp.bin
  Note over App: data.enc + dek.aws.bin + dek.az.bin + dek.gcp.bin
🗺️ What you’ll build
AWS: KMS Key A + role mc-day6-app with minimal Encrypt/Decrypt on Key A

Azure: Key Vault + Key B + service principal with wrapKey/unwrapKey

GCP: Cloud KMS Key C + service account with Encrypter/Decrypter

CLI re-wrap scripts to move a DEK across clouds (no payload decryption)

📦 Outputs
aws_key_arn, azure_key_id, gcp_key_id

aws_role_arn, azure_app_id, gcp_sa_email

Re-wrapped artifacts: dek.aws.bin, dek.az.bin, dek.gcp.bin, data.enc

🧹 Cleanup (billing-safe)
Each cloud root has a terraform destroy block at the end. Run those when done.
