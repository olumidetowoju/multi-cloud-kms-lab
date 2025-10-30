# Day 7 – Rotation Automation (Terraform)

> **Strategy:** Rotate keys safely, update aliases, and keep apps unaware.

```mermaid
flowchart LR
    A["Apps use alias (alias/mc-day7-data)"] --> B["KMS Key v1"];
    subgraph Rotation_Cycle
        B --> C["KMS Key v2 (auto-rotate)"];
        C --> D["Terraform alias switch"];
        D --> A;
    end
    E["Monitoring: CloudTrail / Key Vault logs / GCP Audit"];
    E -.-> A;
```

Patterns

AWS: enable_key_rotation = true (annual for symmetric keys) + alias pattern for manual rotation.

Azure: key rotation policy (schedules) + auto-rotate action.

GCP: rotation_period (platform sets nextRotationTime automatically).

Why aliasing? The alias stays stable while the backing key rotates (auto) or is swapped (manual). Apps never need to change configs.

yaml
Copy code

🧭 Goal

Establish automated key-rotation policies across AWS KMS, Azure Key Vault, and GCP Cloud KMS, ensuring that:

All encryption keys rotate within defined compliance cycles (e.g. 90 / 180 / 365 days).

Applications remain unaware of rotations because they use stable aliases.

All rotation and access events are logged centrally for audits.

⚙️ Core Concepts
Concept	Description
Key Versioning	Each rotation produces a new key version while the old version remains for decryption.
Alias Indirection	Apps use aliases (e.g. alias/mc-day7-data) rather than raw Key IDs; the alias simply points to the newest version.
Rotation Policy	Defines rotation intervals (e.g. 90 days) and triggers (auto or manual).
Audit Trail	Every rotation event is written to the provider’s audit log (CloudTrail / Key Vault / GCP Audit).
🧩 Terraform Highlights

AWS KMS

resource "aws_kms_key" "mc_day7" {
  description         = "Multi-cloud Day7 Data Key"
  enable_key_rotation = true            # Annual (365 days)
  tags = { Lab = "multi-cloud-kms" }
}


Azure Key Vault

resource "azurerm_key_vault_key" "mc_day7" {
  name         = "mc-day7-key"
  key_vault_id = azurerm_key_vault.main.id
  key_type     = "RSA"
  key_size     = 2048

  rotation_policy {
    expire_after = "P180D"
    lifetime_actions {
      action  { type = "Rotate" }
      trigger { time_before_expiry = "P30D" }
    }
  }
}


GCP Cloud KMS

resource "google_kms_crypto_key" "mc_day7" {
  name            = "mc-day7-key"
  key_ring        = google_kms_key_ring.main.id
  rotation_period = "7776000s"   # ≈ 90 days
}

🧮 Validation Checks
Cloud	CLI Command	Expected Result
AWS	aws kms get-key-rotation-status --key-id alias/mc-day7-data	"KeyRotationEnabled": true
Azure	az keyvault key rotation-policy show --vault-name <vault> --name mc-day7-key	Shows Rotate + Notify actions
GCP	gcloud kms keys describe mc-day7-key --keyring mc-day7-ring --format='json(rotationPeriod,nextRotationTime)'	Displays rotationPeriod + nextRotationTime
📊 Monitoring and Audit Pipeline

AWS: CloudTrail → EventBridge → SNS Alert (RotateKey events).

Azure: Key Vault Diagnostics → Log Analytics → Alert Rule.

GCP: Cloud Audit Logs → Cloud Monitoring → Email or Slack notifier.

Example Terraform outputs for a unified view:

output "next_rotation_dates" {
  value = {
    aws   = aws_kms_key.mc_day7.next_rotation_date
    azure = azurerm_key_vault_key.mc_day7.rotation_policy[0].expire_after
    gcp   = google_kms_crypto_key.mc_day7.rotation_period
  }
}

🔁 Cross-Cloud Automation Workflow

Plan / Apply: run terraform apply -auto-approve monthly (GitHub Actions / Azure DevOps).

Rotate: each provider enforces its own rotation schedule.

Alias Update: Terraform’s state ensures aliases repoint automatically.

Verify: CI pipeline performs a test encrypt/decrypt under the new version.

Report: logs aggregated to a SIEM (e.g. Elastic, Sentinel, Chronicle).

📘 Best Practices

Keep rotation intervals consistent (align Azure and GCP to AWS annual standard if possible).

Store rotation metadata in Terraform state or an external Secrets manager.

Never hard-code Key IDs in apps — use aliases or environment variables.

Combine auto rotation with manual alias swaps for testing fallback procedures.

Regularly audit IAM permissions to ensure only CICD and security accounts can rotate keys.

🧹 Cleanup
# Optional clean-up when testing:
terraform destroy -auto-approve


Keys with pending deletion retain encrypted data until the retention window expires (7–30 days depending on provider).
