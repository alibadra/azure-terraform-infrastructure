# Azure Terraform Infrastructure

Modular Terraform code for Microsoft Azure, focused on Windows Server workloads. Covers VNet, Windows VMs, Azure AD, SQL Server Managed Instance, and monitoring.

## Modules

| Module | Resources |
|--------|-----------|
| `vnet` | VNet, subnets, NSG, peering, Bastion |
| `vm-windows` | Windows VM, managed disk, extensions, auto-shutdown |
| `azure-ad` | Azure AD groups, app registrations, service principals |
| `sql-server` | Azure SQL / SQL Managed Instance with private endpoint |

## Quick Start

```bash
# Prerequisites: Azure CLI authenticated, Terraform >= 1.7
az login
cd environments/prod

terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## Features

- Windows Server 2022 VMs with domain join extension
- Azure Bastion for secure RDP (no public IPs)
- NSG rules following least-privilege
- Log Analytics workspace + Azure Monitor alerts
- Azure AD groups synced with RBAC assignments
- SQL with private endpoint (no public access)
