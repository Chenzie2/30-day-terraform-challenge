
# 30 Day Terraform Challenge

My personal journey through the 30 Day Terraform Challenge organized by AWS AI/ML UserGroup Kenya, Meru HashiCorp User Group, and EveOps — going from zero cloud experience to certification ready in 30 structured days.

## The Goal

Build real infrastructure on AWS using Terraform, document everything, and come out the other side with hands-on experience, a portfolio, and a certification to show for it.

## What I'm Building

Each day has its own folder with working Terraform code, comments explaining every decision, and lessons learned the hard way.

| Day | Topic | What I Built |
|-----|-------|--------------|
| Day 1 | Introduction to IaC | Environment setup, AWS CLI, first Terraform config |
| Day 2 | Terraform Basics | Providers, resources, state |
| Day 3 | First Server | EC2 instance with Apache served live on the internet |
| Day 4 | High Availability | Configurable web server with ASG, ALB, input variables and data sources |

## Stack

Terraform, AWS, VS Code, Ubuntu

## Key Concepts Covered So Far

Infrastructure as Code, declarative configuration, input variables, data sources, Auto Scaling Groups, Application Load Balancers, DRY principle, terraform init/plan/apply/destroy

## How to Use This Repo

Each day folder is self contained. Navigate into any day folder and run:
```bash
terraform init
terraform plan
terraform apply
```

Make sure you have AWS credentials configured via `aws configure` before running anything.

## Author

Grace Zawadi; Software Engineer 
[LinkedIn](https://www.linkedin.com/in/gracezawadi) | [Medium](https://medium.com/@gracezawadi24)

#30DayTerraformChallenge #AWSUserGroupKenya #EveOps #Terraform #AWS