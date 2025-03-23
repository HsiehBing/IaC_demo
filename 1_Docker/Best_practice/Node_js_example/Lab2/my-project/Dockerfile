# build stage
FROM node:lts-alpine as build-stage
WORKDIR /app
COPY my-project/package*.json ./
RUN npm install
COPY my-project/ ./
RUN npm run build
# deployment-stage
FROM nginx:stable-alpine as deployment-stage
COPY --from=build-stage /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]