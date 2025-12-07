pipeline {
    agent any

    environment {
        // 🔹 Docker Hub Configuration
        DOCKER_USER = "dhinesh5799"
        DOCKER_CREDS = credentials('fdfdb2bd-8384-4bd7-bc62-bd7663e85283')  // Jenkins DockerHub credential ID
        DEV_REPO = "dhinesh5799/react-app-dev"
        PROD_REPO = "dhinesh5799/react-app-prod"

        // 🔹 App Server (EC2)
        APP_SERVER = "ubuntu@3.110.138.62"   // Change to your App EC2 IP
    }

    stages {

        stage('Checkout') {
            steps {
                echo "📥 Checking out source code from GitHub..."
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🛠️ Building Docker image from ./build directory..."
                sh 'docker build -t build-image -f ./build/Dockerfile ./build'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    echo "📦 Logging in to Docker Hub..."
                    sh "echo $DOCKER_CREDS_PSW | docker login -u $DOCKER_CREDS_USR --password-stdin"

                    if (env.BRANCH_NAME == "dev") {
                        echo "🚀 Pushing image to DEV repo..."
                        sh "docker tag build-image $DEV_REPO:latest"
                        sh "docker push $DEV_REPO:latest"
                    }

                    if (env.BRANCH_NAME == "master") {
                        echo "🚀 Pushing image to PROD repo..."
                        sh "docker tag build-image $PROD_REPO:latest"
                        sh "docker push $PROD_REPO:latest"
                    }
                }
            }
        }

        stage('Deploy to Application Server') {
            when { branch 'master' }
            steps {
                echo "🚀 Deploying application to EC2..."
                sshagent(['app-server']) {  // Jenkins SSH credential ID
                    sh """
                        ssh -o StrictHostKeyChecking=no $APP_SERVER '
                            echo "🧹 Cleaning up old containers..."
                            docker stop react-app || true &&
                            docker rm react-app || true &&
                            docker pull $PROD_REPO:latest &&
                            echo "🚀 Running new container..." &&
                            docker run -d -p 80:80 --name react-app $PROD_REPO:latest &&
                            echo "✅ Deployment successful!"
                        '
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully for branch: ${env.BRANCH_NAME}"
        }
        failure {
            echo "❌ Pipeline failed. Check logs for details."
        }
    }
}
