# Day 7 – Rotation Automation (Terraform)

> Strategy: **Rotate keys safely, update aliases, and keep apps unaware**.

```mermaid
flowchart LR
  A[Apps use alias e.g. alias/mc-day7-data] --> B[KMS Key v1]
  subgraph Rotation Cycle
    B -->|Automatic Rotate/Policy| C[KMS Key v2]
    C -->|Terraform (alias switch)| A
  end
  note1>Logs & Alerts: CloudTrail / KV logs / GCP Audit]
Patterns

AWS: enable_key_rotation = true (annual for symmetric keys) + alias pattern for manual rotation.

Azure: azurerm_key_vault_key_rotation_policy with schedules + auto-rotate action.

GCP: rotation_period + next_rotation_time on the CryptoKey.

Why aliasing? The alias stays stable while the backing key rotates (auto) or is swapped (manual). Apps never need to change configs.

yaml
Copy code
