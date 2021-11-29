# Terraform

- Terraform [installed](https://learn.hashicorp.com/terraform/getting-started/install.html)

Instal Arch.

```bash
sudo pacman -S terraform
```

Copy vars.

```bash
cp terraform.tfvars.example terraform.tfvars
```

Add var `**/terraform.tfvars`.

```bash
nano terraform.tfvars
```

Initialize Terraform.

```bash
terraform init
```

Preview.

```bash
terraform plan
```

Deploy.

```bash
terraform apply
#
terraform apply -auto-approve
```

Destroy/del.

```bash
terraform destroy -auto-approve
```
