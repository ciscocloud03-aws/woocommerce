pipeline {
    agent any

    environment {
        ECR_REGISTRY = '339712790288.dkr.ecr.ap-northeast-2.amazonaws.com'
        ECR_REPOSITORY = 'woocommerce'
        IMAGE_TAG = 'latest'
        KUBECONFIG_CREDENTIALS_ID = '64f03af0-1d4c-4bff-9cd6-bab0481dd2f9'
        AWS_REGION = 'ap-northeast-2'
    }

    stages {
        stage('Checkout') {
            steps {
                // Git 리포지토리에서 소스 코드를 체크아웃
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // AWS ECR 로그인
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"

                    // Docker 이미지 빌드
                    sh "docker build -t ${ECR_REPOSITORY}:${IMAGE_TAG} ."
                    
                    // 이미지에 태그 추가
                    sh "docker tag ${ECR_REPOSITORY}:${env.BUILD_NUMBER} ${ECR_REGISTRY}/${ECR_REPOSITORY}:${env.BUILD_NUMBER}"
                    
                    // 이미지 푸시
                    sh "docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    withCredentials([file(credentialsId: KUBECONFIG_CREDENTIALS_ID, variable: 'KUBECONFIG')]) {
                        // Kubernetes 마니페스트를 적용하여 EKS 클러스터에 배포
                        sh 'kubectl apply -f woocommerce-deploy.yaml -f woocommerce-service.yaml'
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment was successful!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}
