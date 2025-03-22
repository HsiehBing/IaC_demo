# 開始 Lab 之前, 你需要 ...

## 登入AWS console，並開啟上方Cloudshell

# Docker Lab 1 - Hello World!

> 這個 Lab 會使用到一些基本的 Docker 指令

## Start!

1. 打開 Command Line
2. 執行指令

```
$ docker run hello-world
```

## Lab 解析
1. 代表本機沒有 `hello-world:latest` 這個 image，Docker Engine 自動從 Docker Hub 拉取
```
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
e6590344b1a5: Pull complete 
Digest: sha256:7e1a4e2d11e2ac7a8c3f768d4166c2defeb09d2a750b010412b6ea13de1efb19
Status: Downloaded newer image for hello-world:latest
```
2. 查看本機有哪些 Image ，可以發現剛剛拉下的 `hello-world:latest`
```
$ docker images
REPOSITORY    TAG       IMAGE ID       CREATED       SIZE
hello-world   latest    74cc54e27dc4   8 weeks ago   10.1kB
```
3. 看到這個訊息，代表有成功執行，因為這個 Container 只有跑幾行指令做文字輸出
```
...
Hello from Docker!
This message shows that your installation appears to be working correctly.
...
```

## 其他常用指令
- 查看本機的 Docker container
```
$ docker ps -a
```
- 移除 docker container
```
$ docker rm ${CONTAINER_ID}
```
- 刪除 docker image
```
$ docker rmi ${IMAGE_NAME}:${IMAGE_TAG}
```
- 查看 docker 相關資訊
```
$ docker info
```

