# Getting Started with Terraform and OCI (Oracle Cloud) Part 1: Creating Compute Instance & Network Resources
[![Terraform]()


This code:

* Define the OCI Provider for Terraform
* Create a compartment
* Create a Virtual Cloud Network (VCN)
* Create Private and Public Subnets
* Deploy an Internet Gateway
* Create Route Tables


## How To deploy the code:

1. Clone the repo
2. Update the terraform.tfvars with the variables for your environment
3. Execute **terraform init**
4. Execute **terraform apply**

To destroy the environment, execute **terraform destroy**

## Useful Commands

#### List all available shapes in compartment
```go
oci compute image list --compartment-id <compartment-id>
```

#### List compatible shapes for image
```go
oci compute shape list --compartment-id <compartment-id> --image-id <image_ocid>

