# FAO DR Integrations Terraform

This repository contains the Terraform configuration for managing Application Integrations in the FAO Disaster Recovery (DR) environment.

Currently, it manages:
- **`send-email-notifications`**: An integration used to send custom email notifications (used by backup scripts and workflows).

## Directory Structure

```
.
├── terraform/              # Terraform configuration
│   ├── main.tf             # Application Integration resources
│   ├── variables.tf        # Variable definitions
│   ├── backend.tf          # GCS backend configuration
│   ├── providers.tf        # Google provider configuration
│   └── versions.tf         # Terraform and provider version constraints
└── README.md
```

## Automated Deployment

The integration can be deployed automatically using the GitHub Action workflow or manually via the provided script.

### Using the Deployment Script
The script handles creating the regional client (via Terraform), creating the integration resource, uploading the version, and publishing it.

```bash
cd terraform
./scripts/deploy_integration.sh <PROJECT_ID> europe-west1 send-email-notifications ./integration.json
```

### GitHub Actions
A workflow is available in `.github/workflows/deploy-integration.yml`. It requires the following secrets:
- `GCP_PROJECT_ID`: The GCP Project ID.
- `GCP_WIF_PROVIDER`: Workload Identity Provider string.
- `GCP_WIF_SA_EMAIL`: Service Account email for authentication.
- `GCP_TF_STATE_BUCKET`: GCS bucket for Terraform state.

### Configuration
- `terraform/main.tf`: Defines the regional client and triggers the deployment script.
- `terraform/integration.json`: The sanitized JSON configuration for the integration.
- `terraform/send-email-notifications-v3.json`: The original backup/export.

## Usage

### Local Development

1.  Initialize Terraform:
    ```bash
    cd terraform
    terraform init
    ```

2.  Plan changes:
    ```bash
    terraform plan
    ```

3.  Apply changes:
    ```bash
    terraform apply
    ```
