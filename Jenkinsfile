// 声明这是一个 Declarative Pipeline（声明式流水线）
pipeline {
    // 定义流水线运行在哪个 agent（执行节点）上
    // 'any' 表示可以在任意可用的 Jenkins 节点上运行
    agent any

    // 定义环境变量，可在整个流水线中使用
    environment {
        // 从 Jenkins 凭据中读取 Docker Hub 用户名（需提前配置）
        DOCKER_HUB_USERNAME = credentials('docker-hub-username')
        // 从 Jenkins 凭据中读取 Docker Hub 密码（需提前配置）
        DOCKER_HUB_PASSWORD = credentials('docker-hub-password')
        // 镜像名称：格式为 <用户名>/<仓库名>:<标签>
        IMAGE_NAME = "chaojiwudidaxianyu/blog-app1: ${env.BUILD_NUMBER}"
        // 应用在宿主机上暴露的端口
        HOST_PORT = "8080"
    }

    // 定义流水线的各个阶段（Stages）
    stages {
        // 第一阶段：拉取代码（通常由 Jenkins 自动完成，此处显式写出）
        stage('Checkout') {
            steps {
                // 清理工作区（删除上次构建残留文件）
                cleanWs()
                // 从 GitHub 拉取最新代码（Jenkins Job 配置中已关联仓库）
                checkout scm
                // 打印当前 Git 提交信息（用于日志追踪）
                sh 'echo "Building commit:  $ (git rev-parse HEAD)"'
            }
        }

        // 第二阶段：构建 Docker 镜像
        stage('Build Docker Image') {
            steps {
                // 登录 Docker Hub（使用环境变量中的凭据）
                sh """
                    echo " $ {DOCKER_HUB_PASSWORD}" | docker login -u " $ {DOCKER_HUB_USERNAME}" --password-stdin
                """
                // 构建镜像，使用上面定义的 IMAGE_NAME 作为标签
                sh "docker build -t  $ {IMAGE_NAME} ."
                // 可选：本地测试镜像是否能正常启动（非必须）
                // sh "docker run -d --name test-container -p 9999:5000  $ {IMAGE_NAME} && sleep 5 && docker stop test-container && docker rm test-container"
            }
        }

        // 第三阶段：推送镜像到 Docker Hub
        stage('Push Docker Image') {
            steps {
                // 推送构建好的镜像到 Docker Hub
                sh "docker push  $ {IMAGE_NAME}"
                // 注销 Docker 登录（安全最佳实践）
                sh "docker logout"
            }
        }

        // 第四阶段：部署到目标服务器（假设 Jenkins 与目标服务器是同一台）
        stage('Deploy to Server') {
            steps {
                // 停止并删除旧容器（如果存在）
                sh 'docker stop my-flask-app || true'
                sh 'docker rm my-flask-app || true'
                // 拉取最新镜像（确保是最新的）
                sh "docker pull  $ {IMAGE_NAME}"
                // 启动新容器，映射端口 8080 -> 容器 5000
                sh """
                    docker run -d \
                      --name my-flask-app \
                      -p  $ {HOST_PORT}:5000 \
                       $ {IMAGE_NAME}
                """
                // 等待 5 秒让容器启动
                sh 'sleep 5'
                // 验证服务是否响应（健康检查）
                sh 'curl -f http://localhost: $ {HOST_PORT} || exit 1'
            }
        }
    }

    // 流水线结束后执行的操作（无论成功或失败）
    post {
        // 如果构建失败，发送通知（可扩展为邮件/钉钉等）
        failure {
            echo 'Pipeline failed! Please check logs.'
        }
        // 如果成功，打印成功信息
        success {
            echo "✅ Deployment successful! App is running on port  $ {HOST_PORT}"
        }
        // 总是清理临时镜像（可选）
        always {
            sh 'docker image prune -f'
        }
    }
}
