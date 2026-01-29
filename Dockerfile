# 使用官方 Python 3.10 轻量版作为基础镜像
FROM python:3.10-slim

# 设置工作目录为 /app
WORKDIR /app

# 将 requirements.txt 复制到容器中
COPY requirements.txt .

# 安装 Python 依赖（使用国内源可加速，此处用默认）
RUN pip install --no-cache-dir -r requirements.txt

# 将当前目录所有文件复制到容器的 /app 目录
COPY . .

# 暴露容器的 5000 端口（Flask 默认端口）
EXPOSE 5000

# 容器启动时运行的命令
CMD ["python", "app.py"]
