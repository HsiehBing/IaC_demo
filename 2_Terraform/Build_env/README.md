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

- 賦予```backend.sh```執行權限
```shell
-  chmod +x create_backend.sh destroy_backend.sh 
```
- 將 名稱、日期、以及Region依序輸入
```
./2_Terraform/Build_env/backend.sh 
```
