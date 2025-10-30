# Day 7 – Rotation Automation (Terraform)

> Strategy: **Rotate keys safely, update aliases, and keep apps unaware**.

```mermaid
flowchart LR
  A["Apps use alias (alias/mc-day7-data)"] --> B["KMS Key v1"]
    subgraph Rotation_Cycle
        B --> C["KMS Key v2 (auto-rotate)"]
        C --> D["Terraform alias switch"]
        D --> A
    end
    E["Monitoring: CloudTrail / Key Vault logs / GCP Audit"]
    E -.-> A
Patterns

AWS: enable_key_rotation = true (annual for symmetric keys) + alias pattern for manual rotation.

Azure: azurerm_key_vault_key_rotation_policy with schedules + auto-rotate action.

GCP: rotation_period + next_rotation_time on the CryptoKey.

Why aliasing? The alias stays stable while the backing key rotates (auto) or is swapped (manual). Apps never need to change configs.

yaml
Copy code
