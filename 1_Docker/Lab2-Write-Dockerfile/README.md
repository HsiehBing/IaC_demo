# Docker Lab 2 - Write a Dockerfile

> 這個 Lab 會讓大家了解如何寫 Dockerfile，並運行出一個 Python Flask 的前端網頁
- [Dockerfile 官方手冊](https://docs.docker.com/reference/dockerfile/)
- [Docker 指令集](https://docs.docker.com/reference/cli/docker/)

## 目錄解析
- templates/index.html: 前端靜態網頁
- app.py: Flask web server
- Dockerfile: 定義 Docker Image
- requirements.txt: 定義需要的 Python 套件

## Start!

1. 建立 Docker Image
```
$ docker build --file ./Dockerfile --tag docker-lab2:1.0 .
```
2. 啟動 Docker Container
```
$ docker run --detach --publish 8001:8001 --name docker-lab2 docker-lab2:1.0
```
3. 打開 Browser，看看有沒有正常運行[網頁](http://localhost:8001)
4. 查看 Docker container 有沒有正常啟動
```
$ docker ps -a
```

## 玩點新花樣

> 來試試下面幾個題目挑戰看看吧！

1. 將 python 版本換成 3.7
2. 查詢啟動後的 Log
3. 在不重新 Build Image 的情況下，改動前端網頁內容，並成功運行
4. 做出一個 `本機版的 2048 遊戲` [2048 Source Code](https://github.com/gabrielecirulli/2048?tab=readme-ov-file)    