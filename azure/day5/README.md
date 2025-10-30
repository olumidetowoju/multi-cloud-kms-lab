# 🟩 Azure Day 5 — PostgreSQL Flexible Server + Key Vault CMK + Secrets

**Goal:** Use an **Azure Key Vault RSA key (CMK)** for server-side encryption of **Azure Database for PostgreSQL – Flexible Server**, store the **admin password** in **Key Vault Secrets**, and use a **Managed Identity** so the service can wrap/unwrap DEKs without embedding credentials.

---

## 🧠 Concept

- **Key Vault (Keys)** – Holds the **customer-managed key** used by the database engine (CMEK/CMK).
- **PostgreSQL Flexible Server (PGFS)** – The managed database service.
- **Managed Identity (UAMI)** – Lets PGFS call Key Vault for key operations without secrets.
- **Key Vault (Secrets)** – Stores admin credential separately from the data plane.

---

## 🧱 Architecture Diagram
```mermaid
flowchart TB
  subgraph Azure
    KV["Key Vault (Keys + Secrets)"]
    KEY["CMK: mc-day5-pg (RSA)"]
    SEC["Secret: pg-admin"]
    PG["PostgreSQL Flexible Server"]
    UAMI["User-Assigned Managed Identity"]
  end

  DEV["App / Operator"] -->|TLS| PG
  PG -- wrap/unwrap --> KEY
  PG -. uses .-> UAMI
  DEV -->|read/write| SEC
  KV --- KEY
  KV --- SEC
🚀 Quickstart (Terraform)
Folder: azure/day5/iac/terraform

What it deploys

Resource Group, Key Vault, RSA Key mc-day5-pg

UAMI for PG to access the CMK

PostgreSQL Flexible Server with CMK encryption

Key Vault Secret pg-admin for admin password

Run:

bash
Copy code
cd ~/multi-cloud-kms-lab/azure/day5/iac/terraform
terraform init
terraform apply -auto-approve
Outputs to note:

server_fqdn – PostgreSQL FQDN

admin_user – admin username

key_vault_uri – vault URI

key_id – full path to the CMK

✅ Verify
1) Key Vault policies / RBAC

bash
Copy code
KV=$(terraform output -raw key_vault_name)
az keyvault show --name "$KV" --query properties.vaultUri -o tsv
az keyvault key list --vault-name "$KV" -o table
2) Database reachability (TLS)

bash
Copy code
FQDN=$(terraform output -raw server_fqdn)
USER=$(terraform output -raw admin_user)

# fetch admin password from Key Vault
PW=$(az keyvault secret show --vault-name "$KV" -n pg-admin --query value -o tsv)

# requires psql
PGPASSWORD="$PW" psql "host=$FQDN port=5432 dbname=postgres user=$USER sslmode=require" -c '\l'
3) Encryption is CMK-backed
From the Azure Portal (or AZ CLI show commands), the server shows Key Vault as the encryption key source, pointing to your key_id.

🧹 Cleanup (avoid charges)
bash
Copy code
cd ~/multi-cloud-kms-lab/azure/day5/iac/terraform
terraform destroy -auto-approve
If destroy is blocked by Key Vault delete protections, clear soft delete/purge-protect or remove dependent resources first, then re-run destroy.

📁 Where Things Live
Terraform: azure/day5/iac/terraform

This README: azure/day5/README.md

Multi-cloud overview (Day 5): common/day5-databases/README.md

🔎 Troubleshooting
403 on Key/Secret ops: Ensure your signed-in principal has Key Vault permissions (or RBAC roles) for keys (get, wrapKey, unwrapKey, getrotationpolicy) and secrets (get/set/delete).

Region offer restriction: If eastus is restricted for PG, switch to eastus2 or another region in main.tf.

psql missing: sudo apt-get update && sudo apt-get install -y postgresql-client
