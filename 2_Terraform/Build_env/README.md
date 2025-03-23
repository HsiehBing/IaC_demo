# 設定terraform 環境
- 建議在Cloudshell中進行實作
- 若使用default起來的環境容量僅有1G，需要改用root權限，因此需要先建立user的Access Key 以及 Secret Key

# 在Cloudshell安裝terraform

Install ```yum-config-manager``` to manage your repositories.
```
$ sudo yum install -y yum-utils
```
Use ```yum-config-manager``` to add the official HashiCorp Linux repository.
```
$ sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
```
Install Terraform from the new repository.
```
$ sudo yum -y install terraform
```

# 建立backend
- 建立資料夾

- 賦予shell執行權限
```shell
-  chmod +x create_backend.sh destroy_backend.sh create_backend_and_change_region.sh
```
- 將 名稱、日期、以及Region依序輸入
```
./2_Terraform/Build_env/create_backend_and_change_region.sh {name} {date} {region}
# ./2_Terraform/Build_env/create_backend_and_change_region.sh bing 20250323 us-east-1
```
- 建立時會建立S3, Dynamodb, ec2-key
- 當建立ec2 key 時會顯示金鑰，請輸入q離開頁面
```
...
Uo8XzxPHJ39CUBEhiZ9m0LcvnPAk2HIH9a6MhXHwFW9Mqctus1sWg/x2Y5vPr3A7
hIcYGQKBgHYv3jZFvwUw1mfZYDHMcrhvsMFaELRJkWb+hDLu8KJCBUSaQQ1bZOXW
:
# 看到此頁面請輸入q
```
# 透過Terraform 建立環境
## 建立服務
- VPC
  - public & private subnet
  - IGW
  - route table
- EC2
  - Ubuntu22.04
  - user_data
- IAM role
  - IAM role for Ec2(AdministratorAccess)
## 建立步驟

- 初始化
```
terraform init
```
- 查看參數是否有錯誤
```
terraform validate
```
- dry run
```
terraform plan
```
- 部署
```
terraform apply
```
## 環境檢查
- 建立完後應該可以在VPC, EC2 看到對應使用者名稱的服務
- 可以透過Session Manager的方式訪問EC2，此EC2已透過user data安裝以下套件
  - aws cli
  - kubectl
  - eksctl
  - docker

## 環境清除
**請至console Terminal 操作，操作時需要注意Region**
- Terraform 建立服務刪除
```
terraform destroy
```
- Backend 刪除
```
# ./2_Terraform/Build_env/destroy_backend.sh bing 20250323 us-east-1
```
