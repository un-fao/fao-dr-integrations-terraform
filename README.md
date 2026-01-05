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
