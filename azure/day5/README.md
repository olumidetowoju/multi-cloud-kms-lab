# 🟦 Day 5 (Azure) — PostgreSQL Flexible Server + Key Vault (CMK)

## 🎯 Objectives
- Deploy a **PostgreSQL Flexible Server** using a user-assigned managed identity.
- Encrypt storage using a **Customer-Managed Key (CMK)** in **Azure Key Vault**.
- Store admin credentials securely.
- Practice safe teardown for **zero billing** after labs.

---

## 🧩 Terraform Configuration
Path:
azure/day5/iac/terraform/main.tf

bash
Copy code

Run:
```bash
cd azure/day5/iac/terraform
terraform init
terraform apply -auto-approve
🧹 Cleanup (Billing Safe)
bash
Copy code
cd azure/day5/iac/terraform
terraform destroy -auto-approve
📚 Linked Sections
🔗 Common Day 5 Index

🔗 Terraform IaC Folder
