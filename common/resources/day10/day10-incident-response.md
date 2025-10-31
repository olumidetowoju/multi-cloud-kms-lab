# 🚨 Day 10 — Incident Response (Multi-Cloud KMS)

**Goal:** Execute a **safe, reversible, and auditable** incident response (IR) plan across **AWS KMS**, **Azure Key Vault**, and **GCP Cloud KMS** when suspicious key usage is detected.

---

## ⚠️ Safety First
- Perform in **non-production** accounts/subscriptions/projects.
- Prefer **disable / deny / rotate** over destructive actions first.
- Preserve **forensics** (logs, configs, IAM bindings) before changes.

---

## 🧠 Scenario
Your SIEM flags an unusual spike in `Decrypt` events overnight. You must **contain**, **eradicate**, **recover**, and **document** across all three clouds.

---

## 🗺️ High-Level Flow

```mermaid
sequenceDiagram
  autonumber
  participant SIEM as SIEM/Alerts
  participant IR as Incident Responder
  participant AWS as AWS KMS
  participant AZ as Azure KV
  participant GCP as GCP KMS

  SIEM->>IR: Alert: Spike in Decrypt events
  IR->>AWS: Query CloudTrail; Identify Key + Principal
  IR->>AZ: Query Azure Monitor; Identify Key + Identity
  IR->>GCP: Query Audit Logs; Identify Key + SA
  IR->>AWS: Contain: Disable key or attach deny policy
  IR->>AZ: Contain: Disable key version / set deny role
  IR->>GCP: Contain: Disable CryptoKeyVersion
  IR->>AWS: Eradicate: Revoke grants, rotate/create new key
  IR->>AZ: Eradicate: Rotate new key version, update bindings
  IR->>GCP: Eradicate: Create new version, setPrimary
  IR->>IR: Recover: Re-point apps to new keys, verify
  IR->>SIEM: Document & close with lessons learned
```

---

🔍 Triage — Find Who/What/When
AWS (CloudTrail Insights)
bash
Copy code
# Last 20 KMS events (us-east-1)
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventSource,AttributeValue=kms.amazonaws.com \
  --max-results 20 --region us-east-1 \
  --query 'Events[].{Time:EventTime,Name:EventName,User:Username,Key:Resources[0].ResourceName}'
Azure (Log Analytics KQL)
kusto
Copy code
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.KEYVAULT"
| where OperationName has_any ("Decrypt","Encrypt","Wrap","Unwrap")
| project TimeGenerated, OperationName, CallerIPAddress, ResultType, Identity
| top 50 by TimeGenerated desc
GCP (Cloud Audit Logs)
bash
Copy code
gcloud logging read \
  'resource.type="cloudkms_cryptokey" AND protoPayload.methodName:("Decrypt" OR "AsymmetricDecrypt")' \
  --limit=50 \
  --format="table(timestamp, protoPayload.authenticationInfo.principalEmail, protoPayload.resourceName, protoPayload.methodName)"
🧯 Contain — Stop the Bleed (Reversible)
AWS (fast containment options)
bash
Copy code
# OPTION A: Disable a KMS key (reversible)
aws kms disable-key --key-id <KEY_ID> --region us-east-1

# OPTION B: Add a deny condition for suspicious principal (key policy layer)
aws kms put-key-policy --key-id <KEY_ID> --policy-name default \
  --policy file://deny-principal.json --region us-east-1
deny-principal.json (example)

denies all KMS actions for a single principal; keep other statements intact in your real policy.

json
Copy code
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "DenySuspiciousPrincipal",
    "Effect": "Deny",
    "Principal": "*",
    "Action": "kms:*",
    "Resource": "*",
    "Condition": {
      "StringEquals": {
        "aws:PrincipalArn": "arn:aws:iam::<ACCOUNT_ID>:role/suspicious-role"
      }
    }
  }]
}
Azure (containment)
bash
Copy code
# Disable specific key version (reversible)
az keyvault key set-attributes \
  --vault-name <VAULT_NAME> --name <KEY_NAME> \
  --version <KEY_VERSION> --enabled false
GCP (containment)
bash
Copy code
# Disable a CryptoKeyVersion (reversible)
gcloud kms keys versions disable <VERSION_ID> \
  --key <KEY_NAME> --keyring <RING> --location us-central1
🧹 Eradicate — Remove Access Vectors
AWS
bash
Copy code
# Revoke any active grants on the key
aws kms list-grants --key-id <KEY_ID> --region us-east-1 \
  --query 'Grants[].GrantId' --output text | tr '\t' '\n' | while read G; do
    aws kms revoke-grant --key-id <KEY_ID> --grant-id "$G" --region us-east-1
  done

# Rotate/Create fresh key and move alias
NEW=$(aws kms create-key --query KeyMetadata.KeyId --output text --region us-east-1)
aws kms update-alias --alias-name alias/PROD-DATA --target-key-id "$NEW" --region us-east-1
Azure
bash
Copy code
# Create new key version and use it going forward
az keyvault key rotate --vault-name <VAULT_NAME> --name <KEY_NAME>

# Tighten access: remove legacy app or compromised principal
az keyvault set-policy --name <VAULT_NAME> --object-id <OBJECT_ID> --key-permissions delete
az keyvault delete-policy --name <VAULT_NAME> --object-id <OBJECT_ID>
GCP
bash
Copy code
# Create a new version and make it primary
gcloud kms keys versions create \
  --key <KEY_NAME> --keyring <RING> --location us-central1

gcloud kms keys set-primary-version <KEY_NAME> <NEW_VERSION_NUMBER> \
  --keyring <RING> --location us-central1

# Remove compromised principal
gcloud kms keys remove-iam-policy-binding <KEY_NAME> \
  --keyring <RING> --location us-central1 \
  --member="serviceAccount:suspicious@<PROJECT_ID>.iam.gserviceaccount.com" \
  --role="roles/cloudkms.cryptoKeyEncrypterDecrypter"
🔁 Recover — Repoint, Re-encrypt, Verify
Update applications to use the new key/alias/version.

Re-encrypt high-value data stores (S3 objects, Azure Storage, Cloud SQL/RDS snapshots) as needed.

Smoke tests: run an encrypt/decrypt on each platform to verify success.

AWS S3 example (re-encrypt object)

bash
Copy code
aws s3 cp s3://<BUCKET>/<KEY> /tmp/obj
aws s3 cp /tmp/obj s3://<BUCKET>/<KEY> --sse aws:kms --sse-kms-key-id alias/PROD-DATA
🧾 Forensics & Post-Incident
Preserve Evidence
AWS: Export CloudTrail to S3, snapshot KMS key policy JSON.

Azure: Export AzureDiagnostics from Log Analytics to Storage.

GCP: Export Audit Logs to BigQuery (partitioned by day).

Reporting Queries
CloudWatch Logs Insights

sql
Copy code
fields @timestamp, eventName, userIdentity.arn, sourceIPAddress
| filter eventSource="kms.amazonaws.com"
| stats count() by eventName, userIdentity.arn
Log Analytics (KQL)

kusto
Copy code
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.KEYVAULT"
| summarize ops=count() by OperationName, bin(TimeGenerated, 1h)
GCP Log Explorer

bash
Copy code
resource.type="cloudkms_cryptokey"
protoPayload.methodName:"Decrypt"
🧹 Cleanup (Lab)
Re-enable previously disabled keys (if only a drill).

Remove deny statements and extra IAM bindings you added for the test.

Delete temporary log sinks/streams and storage if not needed.

✅ Outcome
You now have a repeatable multi-cloud IR runbook: triage → contain → eradicate → recover → document — tailored for KMS key misuse.
