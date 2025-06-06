FROM node:18 AS builder

# 设置工作目录
WORKDIR /app

# 复制 package.json 和 package-lock.json（如有）
COPY package.json package-lock.json* ./

# 安装依赖
RUN npm install

# 复制源码
COPY . .

# 构建生产包
RUN npm run build

# 第二阶段：使用 Nginx 提供静态文件
FROM nginx:alpine


# 删除默认的 nginx 静态站点配置
RUN rm -rf /usr/share/nginx/html/*

# 复制自定义的 nginx.conf
COPY deploy/nginx.conf /etc/nginx/nginx.conf

# 将第一阶段构建的 dist 目录复制到 Nginx 默认静态根目录
COPY --from=builder /app/dist /usr/share/nginx/html

# 暴露 80 端口
EXPOSE 80

# 启动 Nginx（使用前台模式）
CMD ["nginx", "-g", "daemon off;"]
