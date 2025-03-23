FROM nginx:stable-alpine

# 安裝 Node.js 和 npm
RUN apk add --update nodejs npm

# 設置工作目錄
WORKDIR /app

# 複製 package.json 和 package-lock.json
COPY my-project/package*.json ./

# 安裝專案依賴
RUN npm install

# 複製專案文件到工作目錄
COPY my-project/ ./

# 為生產環境構建應用程式
RUN npm run build

# 將構建產物複製到 Nginx 的網頁目錄
RUN cp -r dist/* /usr/share/nginx/html/

# 暴露 80 端口
EXPOSE 80

# 運行 Nginx
CMD ["nginx", "-g", "daemon off;"]