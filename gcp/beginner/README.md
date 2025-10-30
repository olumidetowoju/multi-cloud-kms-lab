# 🌍 GCP Day 4 — Beginner Lab: Cloud KMS Fundamentals

### 🎯 Goal  
Understand how to create and use **Google Cloud Key Management Service (KMS)** keys for basic encryption and decryption.

---

### 🧠 Concepts Covered
- **Key Rings & Keys** — group keys logically for environment separation.
- **IAM Roles** — control who can use or manage keys.
- **Cloud Shell / gcloud CLI** — manage keys and encrypt data.

---

### 🧰 Hands-On Steps

```bash
# 1. Create a key ring
gcloud kms keyrings create day4-ring --location=us-central1

# 2. Create a symmetric key
gcloud kms keys create day4-key \
  --keyring=day4-ring \
  --location=us-central1 \
  --purpose=encryption

# 3. Encrypt a sample file
echo "Hello GCP KMS!" > sample.txt
gcloud kms encrypt \
  --key day4-key --keyring day4-ring \
  --location=us-central1 \
  --plaintext-file sample.txt \
  --ciphertext-file sample.enc

# 4. Decrypt it
gcloud kms decrypt \
  --key day4-key --keyring day4-ring \
  --location=us-central1 \
  --ciphertext-file sample.enc \
  --plaintext-file decrypted.txt
cat decrypted.txt

## 🧭 Architecture Diagram
```mermaid
flowchart LR
  A[App / Cloud Shell] --> B[Cloud KMS KeyRing: day4-ring]
  B --> C[KMS Key: day4-key (symmetric)]
  C --> D[Encrypt / Decrypt Data]
```

Tagging: mc-lab=kms-day4 (labels/annotations where applicable)

🧹 Cleanup
gcloud kms keys disable day4-key --keyring=day4-ring --location=us-central1
gcloud kms keyrings delete day4-ring --location=us-central1

✅ Outcome

By the end of this lab, you will:

Understand how GCP KMS manages keys.

Be able to encrypt/decrypt data using your own symmetric key.

Know how to clean up to avoid resource costs.

