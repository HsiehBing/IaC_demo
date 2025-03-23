# 說明
主要是提供Docker, Terraform以及EKS的基礎訓練。

# Docker
## Best_practice
- 提供在Python以及Java底下建立Dockerfile時可以如何有效建立

## Lab1-Hello-World
- 自行部署一個docker hello world

## Lab2-Write-Dockerfile
- 建立一個Docker web介面

# Terraform
以實作方式帶領設定Terraform

## Build_env
- 建立terraform backend機制: S3, dynamodb, ec2-key
- 建立VPC, EC2 以及使用user-data建立kubectl, eksctl, docker 以提供後續使用

## Lab4_ECR_demo
- 以ECR為例，說明模組化的好處，以each的方式快速建立多個ECR
- 介紹在不同terraform main使用同一個backend時機制

## Lab5_structure_demo
- 介紹Terraform結構化內容，如何分env, module

# EKS
以Terraform建置EKS環境，介紹k8s以及EKS基礎觀念

## Terraform build env
- 透過Terraform 建立環境，並展示在不同需求時的設定差異
### Node group
- 展示Node group設定
### Fargate
- 展示Fargate設定
### AutoMode
- 展示AutoMode設定

## EKS basic concept
- 針對k8s進行基本介紹
### pod
- pod介紹
### deployment
- deployment, replicaset, daemonset介紹
### service
- nodePort, ClusterIP, Load Balancer介紹
- 安裝load balancer controler
### addition plug in
- State metric
- Prometheus node exporter
- external dns
- load balancer controller


