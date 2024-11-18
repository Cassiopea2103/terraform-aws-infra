

<!-- PROJECT LOGO -->

<br />
<div align="center">
  <a href="https://github.com/Cassiopea2103/terraform-aws-infra">
    <img src="https://res.cloudinary.com/codersociety/image/fetch/f_webp,ar_16:9,c_fill,w_1596/https://cdn.codersociety.com/uploads/terafformaws.png" alt="Logo" width="180" height="100">
  </a>

  <h3 align="center">AWS provisionning with Terraform</h3>

  <p align="center">
    Using Terraform to provide resources on AWS cloud environment 
    <br />
    <a href="https://www.linkedin.com/in/cassiopea21/"><strong>Let's connect on Linkedin</strong></a>
    <br />
    <br />
  </p>
</div>


<!-- TABLE OF CONTENTS -->
<details>
  <summary>TABLE OF CONTENTS</summary>
  <ol>
    <li>
      <a href="#about-the-project">Overview of the project</a>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#features">Features</a></li>
        <li><a href="#tech-stack">Tech stack</a></li>
        <li><a href="#files-content">Files content</a></li>
      </ul>
    </li>
    <li><a href="#deployment">Deployment</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

This project ( lab ) is designed to deploy infrastructure on AWS using Terraform. It creates a VPC, a subnet, and an EC2 instance running Ubuntu with Nginx pre-installed. Additionally, it sets up a GitHub Actions pipeline for continuous integration and deployment (CI/CD), allowing automatic provisioning and management of the infrastructure.

Here is what the architecture looks like :   
![00 architecture](https://github.com/user-attachments/assets/8289347d-9969-4203-807c-f03b3d51926f)


_`For simplicity , and to stay in line with the lab standards , we will get rid of the Gateway provisonning as well as any additinal resource like routing tables`_



## Getting started 
### Prerequisites

The following tools will be needed :

-   [Git](https://git-scm.com/)
-    [AWS CLI](https://aws.amazon.com/cli/)
-   [Terraform](https://www.terraform.io)
-   [GitHub account](https://github.com/)

Additionally, in the very first steps , we need to configure our __AWS__ credentials:
With _AWS CLI_ , we can do so with the command :
```bash
aws configure
```  
This will prompt us to enter AWS credentials  : 
* AWS Access Key ID
* AWS Secret Access Key
* Default region name
* Default output format

To get these credentials , we need to set prior a cloud environment . 
For that , we use a free sandbox provided by [LMS WHIZLABS](https://business.whizlabs.com/)

![0 cloud-sandbox-setup](https://github.com/user-attachments/assets/f5a1b6bb-1c1a-4ce4-b456-46c76cee3118)
 

After the sandbox is set up , we get our AWS credentials ...
![1 sandbox-credentials](https://github.com/user-attachments/assets/8b67271b-1aa3-420c-9151-09c5f0a02c9d)


### Features 
-   **VPC Creation**: Automatically provisions a Virtual Private Cloud (VPC) on AWS.
-   **Subnet Setup**: Creates a public subnet within the VPC for hosting resources.
-   **EC2 instance**: Deploys an EC2 instance running Ubuntu 22.04 LTS with Nginx pre-installed.
-   **GitHub actions pipeline**: Automated CI/CD pipeline to deploy and manage infrastructure changes.


### Tech Stack 

* [![Terraform][Terraform]][Terraform-url] 
* [![AWS][AWS]][AWS-url] 
* [![AWS CLI][AWS-cli]][AWS-cli-url] 
* [![Git][Git]][Git-url] 
* [![GitHub Actions][GitHub-actions]][GitHub-actions-url]


### Files content 

The project structure is as follows : 
```plaintext
AWS-TERRAFORM-LAB:.
│   .gitignore
│   .terraform.lock.hcl
│   main.tf
│   outputs.tf
│   terraform.tfstate
│
├───.github
│   └───workflows
│           terraform.yml
│
└───.terraform/
```
 <br/>

Here is a breakdown of  the files : 

**`main.tf`**: The primary Terraform configuration file containing the VPC, subnet, EC2 instance, and security group definitions.
```yaml
# provider setup :
provider  "aws" {
	region  =  "us-east-1"
}

# VPC and subnet
resource  "aws_vpc"  "main_vpc" {
	cidr_block  =  "10.0.0.0/16"
	tags  =  {
		Name  =  "LAB-VPC-GITHUB_ACTIONS"
	}
}

resource  "aws_subnet"  "main_subnet" {
	vpc_id  =  aws_vpc.main_vpc.id
	cidr_block  =  "10.0.1.0/24"
	map_public_ip_on_launch  =  true
	availability_zone  =  "us-east-1a"
	tags  =  {
		Name  =  "LAB-SUBNET-GITHUB_ACTIONS"
	}
}


# EC2 instance
resource  "aws_instance"  "ubuntu_nginx" {
	ami  =  "ami-005fc0f236362e99f"  #ubuntu 22.04 LTS
	instance_type  =  "t2.micro"
	subnet_id  =  aws_subnet.main_subnet.id
	tags  =  {
		Name  =  "Ubuntu-NGINX-EC2-GITHUB_ACTIONS"
	}
	# pre-install nginx on the EC2 instance :
	user_data  =  <<-EOF
	#!/bin/bash
	apt update -y
	apt install nginx -y
	systemctl start nginx
	systemctl enable nginx
	EOF
}
```

 <br/>
 <br/>

**`outputs.tf`**: Contains output values, such as the public IP address of the deployed EC2 instance.
```yaml 
output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "subnet_id" {
  value = aws_subnet.main_subnet.id
}

output "instance_public_ip" {
  value = aws_instance.ubuntu_nginx.public_ip
}
```
 <br/>
 <br/>


**`terraform.yml`**: GitHub Actions configuration file for setting up the CI/CD pipeline.
```yaml
name: Terraform infrastructure deployment

on:
  push:
    branches:
      - master

jobs:
  terraform:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout Code
      uses: actions/checkout@v3

    - name: Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v3
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: 1.5.0

    - name: Terraform init
      run: terraform init

    - name: Terraform plan
      run: terraform plan

    - name: Terraform apply
      run: terraform apply -auto-approve
  ```

 <br/>
 <br/>


## Deployment

For deploying the resources to AWS , all we need to do is to push the code to Github . The pipeline will automatically provision resources to our cloud environment .
However , we must before allow Github to retrieve AWS credentials in the repository environment . 
For that , we set the repository secret variables 
![8 gh-secrets](https://github.com/user-attachments/assets/7c139ff3-fe55-43e5-b563-c6f3208d9b3b)  
  
![9 gh-repo-secret](https://github.com/user-attachments/assets/bcbd3d11-d9f0-4050-b4f1-43390321e3b9)


Once done , we proceed to push the code to our github repo , which then triggers automatically the Github Actions pipeline to deploy the resources to AWS . 

![10 automation-gh-actions-pending](https://github.com/user-attachments/assets/c49c0eab-0017-4e23-a0ba-da02a4712d6c)
  
![11 automation-gh-actinos-successful](https://github.com/user-attachments/assets/0d869d70-4b47-4b99-b38c-2486a41719f3)


We can then see the details of the pipeline job for all the steps... 
![12 automation-gh-action-details](https://github.com/user-attachments/assets/2a54a24d-5af4-4ae9-93b3-ced78a512a22)



### Checking resources provisionning : 
On our AWS console , we navigate respsectively to sections for VPC , Subnets & EC2 services to check if resources were created by our automated pipeline .   
<br/>
**VPC**
![13 automated-deployment-vpc](https://github.com/user-attachments/assets/c94f619b-806d-4be2-abbb-6075ddabfe64)

**Subnet** 
![14 automated-deployment-subnet](https://github.com/user-attachments/assets/b43ba1ad-6ac2-47fd-99a0-c00e48b63a67)

**EC2 instance** 
![15 automated-deployment-ec2](https://github.com/user-attachments/assets/dcab2e07-1e74-40db-8778-1152a265bef2)

  

<!-- MARKDOWN LINKS & IMAGES -->
[Terraform]: https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white 
[Terraform-url]: https://www.terraform.io/ 
[AWS]: https://img.shields.io/badge/Amazon_AWS-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white 
[AWS-url]: https://aws.amazon.com/ 
[AWS-cli]: https://img.shields.io/badge/AWS%20CLI-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white 
[AWS-cli-url]: https://aws.amazon.com/cli/
[Git]: https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white 
[Git-url]: https://git-scm.com/ 
[GitHub-actions]: https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white 
[GitHub-actions-url]: https://github.com/features/actions

