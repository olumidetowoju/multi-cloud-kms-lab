# 🟦 Day 5 (AWS) — RDS PostgreSQL + KMS + **IAM Database Authentication**
Tag: `mc-lab=kms-day5` • Region: `us-east-1`

## Objectives
- Provision **RDS PostgreSQL** encrypted with **KMS CMK**
- Use **IAM DB Auth** (no static passwords)
- Store bootstrap admin password in **Secrets Manager** (for emergency)
- Enforce TLS, validate encryption, and cleanup

## Diagram
```mermaid
flowchart TB
  KMS[(CMK)]
  RDS[(RDS PostgreSQL)]
  SM[(Secrets Manager)]
  Client[psql client]
  Client -- IAM token --> RDS
  RDS --> KMS
  SM --> Client
