僅用來作為 `entrypoint.sh` 的參考範例

## 建置 Image
```
docker build -t demo-app .
```

## 執行服務主程式
+ K8s 可統一透過一樣的 `ENTRYPOINT` 和 `CMD` 執行主程式
```
# 等同於 docker run -d --name demo-app -p 5000:5000 demo-app run
docker run -d --name demo-app -p 5000:5000 demo-app
curl http://localhost:5000
docker logs demo-app
docker stop demo-app
docker logs demo-app
docker rm demo-app
```

## 執行單元測試並產出測試報告
+ CI/CD 可統一透過 `test` 執行單元測試
+ CI/CD 可統一於 `/reports` 獲取測試報告
```
docker run --rm -v $(pwd)/reports:/reports demo-app test
```

## 進入互動模式
+ `--entrypoint` 後面所接指令需依據 base image 進行調整
```
docker run -it --rm --entrypoint /bin/bash demo-app
```
