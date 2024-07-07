pipeline {
    agent any

    environment {
        AWS_CREDENTIALS = credentials('339712790288')
        ECR_REGISTRY = '339712790288.dkr.ecr.ap-northeast-2.amazonaws.com'
        ECR_REPOSITORY = 'woocommerce'
        IMAGE_TAG = 'latest'
        KUBECONFIG_CREDENTIALS_ID = 'bc64ae01-1aa6-4fc7-af5b-30c5982d471d'
        AWS_REGION = 'ap-northeast-2'
        ARGOCD_SERVER = 'a30ea858830404f2c818c4c1ee2d32ca-915993451.ap-northeast-2.elb.amazonaws.com'
        ARGOCD_USERNAME = 'admin'
        ARGOCD_PASSWORD = credentials('argocd')
        GIT_REPO = 'https://github.com/ciscocloud03-aws/woocommerce.git'
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
    args: ["dockerd", "-H", "tcp://0.0.0.0:2375", "-H",  "unix:///var/run/docker.sock"]
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
  - name: argocd
    image: argoproj/argocd:latest
    tty: true
    env:
    - name: ARGOCD_SERVER
      value: "a30ea858830404f2c818c4c1ee2d32ca-915993451.ap-northeast-2.elb.amazonaws.com"
    - name: ARGOCD_USERNAME
      value: admin
    - name: ARGOCD_PASSWORD
      value: "9PuhjAF16EZPdRP3"
                ''') {
                    node(POD_LABEL) {
                            container('docker') {
                                script {
                                    // AWS ECR 로그인
                                    sh "apk add --no-cache python3 py3-pip groff less bash curl git iptables && pip3 install awscli"
                                    sh "git clone https://github.com/ciscocloud03-aws/woocommerce.git /home/jenkins/agent/workspace/woocommerce"
                                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"

                                    // Docker 이미지 빌드 및 태그
                                    sh "docker build --no-cache -t ${ECR_REGISTRY}/${ECR_REPOSITORY}:${env.BUILD_NUMBER} ."
                                    sh "docker images"
                                    sh "docker tag ${ECR_REGISTRY}/${ECR_REPOSITORY}:${env.BUILD_NUMBER} ${ECR_REPOSITORY}:${IMAGE_TAG}"

                                    // 이미지 푸시
                                    sh "docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:${env.BUILD_NUMBER}"

                                }
                            }

                            container('argocd') {
                                script {
                                    sh "argocd login $ARGOCD_SERVER --username $ARGOCD_USERNAME --password $ARGOCD_PASSWORD --insecure"
                                    sh "argocd app sync woocommerce"
                                }
                            }

                            container('kubectl') {
                                script {
                                    sh """
                                    sed -i 's|image: ${param.ecrrepository}/woocommerce:.*|image: ${param.ecrrepository}/woocommerce:${env.BUILD_NUMBER}|g' woocommerce-deploy.yaml
                                    git config --global user.email "you@example.com"
                                    git config --global user.name "Your Name"
                                    git add woocommerce-deploy.yaml
                                    git commit -m "Update image to latest"
                                    git push origin main                                    
                                    """
                                  }
                                }
                    
                            container('argocd') {
                                script {
                                    sh "argocd app sync woocommerce"
                                }
                            }

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

