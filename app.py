# 导入 Flask 框架
from flask import Flask

# 创建 Flask 应用实例
app = Flask(__name__)

# 定义根路径的路由，返回欢迎信息
@app.route('/')
def hello():
    return "Hello from Jenkins CI/CD! Version 1.0\n"

# 如果直接运行此文件，则启动开发服务器（监听所有 IP，端口 5000）
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
