pipeline {
    agent any

    environment {
        // 正确使用复合凭据 (类型应为 Username with password)
        DOCKER_HUB_CREDS = credentials('docker-hub-creds')
        IMAGE_NAME = "chaojiwudixianyu/blog-app1:${env.BUILD_NUMBER}"
        HOST_PORT = "8081"
    }

    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                checkout scm
                // 修正的Git提交命令
                sh 'echo "Building commit: $(git rev-parse HEAD)"'
            }
        }

        stage('Build Docker Image') {
            steps {
                // 使用复合凭据的正确方式
                sh '''
                    echo "$DOCKER_HUB_CREDS_PSW" | 
                    docker login -u "$DOCKER_HUB_CREDS_USR" --password-stdin
                '''
                // 修正构建命令
                sh "docker build -t ${IMAGE_NAME} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                // 修正推送命令
                sh "docker push ${IMAGE_NAME}"
                sh "docker logout"
            }
        }

        stage('Deploy to Server') {
            steps {
                sh 'docker stop my-flask-app || true'
                sh 'docker rm my-flask-app || true'
                sh "docker pull ${IMAGE_NAME}"
                sh "docker run -d --name my-flask-app -p ${HOST_PORT}:5000 ${IMAGE_NAME}"
                sh 'sleep 5'
                // 修正健康检查命令
                sh "curl -f http://localhost:${HOST_PORT} || exit 1"
            }
        }
    }

    post {
        failure {
            echo 'Pipeline failed! Please check logs.'
        }
        success {
            // 优化输出格式
            echo "✅ Deployment successful! App is running on http://localhost:${HOST_PORT}"
        }
        always {
            sh 'docker image prune -f'
        }
    }
}

