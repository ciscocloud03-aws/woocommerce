pipeline {
    agent any

    environment {
        ECR_REGISTRY = '339712790288.dkr.ecr.ap-northeast-2.amazonaws.com'
        ECR_REPOSITORY = 'woocommerce'
        IMAGE_TAG = 'latest'
        KUBECONFIG_CREDENTIALS_ID = '64f03af0-1d4c-4bff-9cd6-bab0481dd2f9'
        AWS_REGION = 'ap-northeast-2'
    }

    parameters {
        string(name: 'gitlabName', defaultValue: 'smth-hyj')
        string(name: 'gitlabEmail', defaultValue: 'smth.hyj@gmail.com')
        string(name: 'gitlabWebaddress', defaultValue: 'https://github.com/ciscocloud03-aws/woocommerce.git')
        string(name: 'gitlabCredential', defaultValue: 'github_pw', description: '')
        string(name: 'githelmaddress', defaultValue: '', description: 'git helm repository')
        string(name: 'githelmshortddress', defaultValue: '', description: 'git helm repository')    
        string(name: 'ecrrepositoryCredential', defaultValue: 'woocommerce')
        string(name: 'ecrrepository', defaultValue: 'https://339712790288.dkr.ecr.ap-northeast-2.amazonaws.com')
        string(name: 'namespace', defaultValue: 'devops-tools')
    }

    stages {
        stage('Checkout Gitlab') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId:  "${params.gitlabCredential}", url: "${params.gitlabWebaddress}"]]])
                echo "gitlabName: ${params.gitlabName}"
                echo "gitlabEmail: ${params.gitlabEmail}"
                echo "gitlabWebaddress: ${params.gitlabWebaddress}"
                echo "githelmaddress: ${params.githelmaddress}"
                echo "githelmshortddress: ${params.githelmshortddress}"
                echo "gitlabCredential: ${params.gitlabCredential}"
                echo "ecrrepositoryCredential: ${params.ecrrepositoryCredential}"
                echo "ecrrepository: ${params.ecrrepository}"
                echo "namespace: ${params.namespace}"
            }
        }

        stage('Docker Pod Deploy') {
            steps {
                podTemplate(yaml: '''
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins-admin
  volumes:
  - name: docker-socket
    emptyDir: {}
  containers:
  - name: docker
    image: docker:20.10.7
    readinessProbe:
      exec:
        command: [sh, -c, "ls -l /var/run/docker.sock"]
    args: ["dockerd", "-H", "tcp://0.0.0.0:2375"]
    securityContext:
      privileged: true
    volumeMounts:
    - name: docker-socket
      mountPath: /var/run
  - name: docker-daemon
    image: docker:20.10.7-dind
    securityContext:
      privileged: true
    volumeMounts:
    - name: docker-socket
      mountPath: /var/run
  - name: kubectl
    image: bitnami/kubectl:1.26.0
    command: 
    - sleep
    args: 
    - 99d
                ''') {
                    node(POD_LABEL) {
                            container('docker') {
                                script {
                                    // AWS ECR 로그인
                                    sh "apk add --no-cache python3 py3-pip groff less bash curl git iptables && pip3 install awscli"
                                }
                            }
                            container('docker-daemon') {
                                script {
                                    sh "apk add --no-cache python3 py3-pip groff less bash curl git && pip3 install awscli"
                                    sh "git clone https://github.com/ciscocloud03-aws/woocommerce.git /home/jenkins/agent/workspace/woocommerce"
                                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"

                                    // Docker 이미지 빌드 및 태그
                                    sh "docker build --no-cache -t ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG} ."
                                    sh "docker tag ${ECR_REPOSITORY}:${env.BUILD_NUMBER} ${ECR_REGISTRY}/${ECR_REPOSITORY}:${env.BUILD_NUMBER}"

                                    // 이미지 푸시
                                    sh "docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"                                    
                                }
                            }
                            container('kubectl') {
                                script {
                                    withCredentials([file(credentialsId: KUBECONFIG_CREDENTIALS_ID, variable: 'KUBECONFIG')]) {
                                        // Kubernetes 마니페스트 적용
                                        sh 'kubectl apply -f woocommerce-deploy.yaml -f woocommerce-service.yaml'
                                    
                                }
                            }
                        }
                    }
                }
            }
        }

        stage('Update 5ka Manifest Repository') {
            steps {
                git credentialsId: "${params.gitlabCredential}",
                    url: "${params.githelmaddress}",
                    branch: 'main'
                script {
                    withCredentials([usernamePassword(credentialsId: "${params.gitlabCredential}", passwordVariable: 'password', usernameVariable: 'username')]) {
                        sh "git init"
                        sh "git checkout main"
                        sh "sed -i 's@version:.*@version: ${env.BUILD_NUMBER}@g' ./values.yaml"
                        sh "sed -i 's@repository:.*@repository: nexus.ihp001.dev@g' ./values.yaml"
                        sh "git add ."
                        sh "git config --global user.email ${params.gitlabName}"
                        sh "git config --global user.name ${params.gitlabEmail}"
                        sh "git commit -m '[UPDATE] 5ka ${GIT_COMMIT} image versioning'"
                        sh "git remote set-url origin ${params.githelmshortddress}"
                        sh "git push -f origin main"
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

