# 說明
Lab2 提供更輕量化的建構，除Dockerfile外其餘的安裝設定均相同，可用來比賽兩種配置下的差異。
以下結構與Lab1相同。

# 資料結構
```
my-project/
│
├── public/                # 靜態文件目錄
│   ├── index.html        # 主 HTML 頁面
│   ├── css/
│   │   └── style.css     # 樣式表
│   └── js/
│       └── app.js        # 前端 JavaScript
│
├── src/
│   └── index.js          # Node.js 應用程式入口
│
├── package.json          # 專案依賴和腳本
└── Dockerfile            # Docker 構建文件
```

# 本地開發
```bash
# 安裝依賴
npm install

# 開啟開發伺服器
npm run dev
```
訪問 http://localhost:3000 查看應用程式。

# 使用 Docker 構建和運行
```bash
# 構建 Docker 映像
docker build -t my-nodejs-app .

# 運行容器
docker run -p 80:80 my-nodejs-app
```
訪問 http://localhost 查看應用程式。

