pipeline {
    agent any

    environment {
        // 🔹 Docker Hub Configuration
        DOCKER_USER = "dhinesh5799"                                 // Docker Hub username
        DOCKER_CREDS = credentials('fdfdb2bd-8384-4bd7-bc62-bd7663e85283') // Docker Hub credentials ID
        DEV_REPO = "dhinesh5799/react-app-dev"                      // Dev repository (public)
        PROD_REPO = "dhinesh5799/react-app-prod"                    // Prod repository (private)

        // 🔹 App Server (EC2)
        APP_SERVER = "ubuntu@3.110.138.62"                          // Application EC2 IP
    }

    stages {

        // Stage 1: Checkout the code from GitHub
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        // Stage 2: Build the Docker image
        stage('Build Docker Image') {
            steps {
                echo "🛠️ Building Docker image..."
                sh 'docker build -t build-image .'
            }
        }

        // Stage 3: Push image to Docker Hub (based on branch)
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

        // Stage 4: Test SSH Connection to Application Server
        stage('Test SSH Connection') {
            steps {
                echo "🔗 Testing SSH connection to App Server..."
                sshagent(['app-server']) {
                    sh "ssh -o StrictHostKeyChecking=no $APP_SERVER 'hostname && whoami'"
                }
            }
        }

        // Stage 5: Deploy to Application EC2 (only for master branch)
        stage('Deploy to Application Server') {
            when { branch 'master' }
            steps {
                echo "🚀 Deploying application to EC2 server..."
                sshagent(['app-server']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no $APP_SERVER '
                            echo "🧹 Cleaning up old containers..."
                            docker pull $PROD_REPO:latest &&
                            docker stop react-app || true &&
                            docker rm react-app || true &&
                            echo "🚀 Running new container..."
                            docker run -d -p 80:80 --name react-app $PROD_REPO:latest &&
                            echo "✅ Deployment complete!"
                        '
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Check logs for details."
        }
    }
}
