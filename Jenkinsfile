pipeline {
    agent any

    environment {
        AWS_CREDENTIALS = credentials('aws')
        ECR_REGISTRY = '339712790288.dkr.ecr.ap-northeast-2.amazonaws.com'
        ECR_REPOSITORY = 'woocommerce'
        IMAGE_TAG = 'latest'
        KUBECONFIG_CREDENTIALS_ID = credentials('c2002a5b-1b67-40ab-8207-ec15b59534c0')
        AWS_REGION = 'ap-northeast-2'
        GITLABCREDENTIAL = credentials('github_pw')
        GITLABCREDENTIAL_PSW = credentials('github')
    }

    parameters {
        string(name: 'gitlabName', defaultValue: 'smth-hyj')
        string(name: 'gitlabEmail', defaultValue: 'smth.hyj@gmail.com')
        string(name: 'gitlabWebaddress', defaultValue: 'https://github.com/ciscocloud03-aws/woocommerce.git')
        string(name: 'githelmaddress', defaultValue: '', description: 'git helm repository')
        string(name: 'githelmshortddress', defaultValue: '', description: 'git helm repository')    
        string(name: 'ecrrepositoryCredential', defaultValue: 'woocommerce')
        string(name: 'gitlabCredetial', defaultValue: 'github_pw')        
        string(name: 'ecrrepository', defaultValue: 'https://339712790288.dkr.ecr.ap-northeast-2.amazonaws.com')
        string(name: 'namespace', defaultValue: 'devops-tools')
    }

    stages {
        stage('Checkout Gitlab') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId:  "${params.gitlabCredetial}", url: "${params.gitlabWebaddress}"]]])
                echo "gitlabName: ${params.gitlabName}"
                echo "gitlabEmail: ${params.gitlabEmail}"
                echo "gitlabWebaddress: ${params.gitlabWebaddress}"
                echo "githelmaddress: ${params.githelmaddress}"
                echo "githelmshortddress: ${params.githelmshortddress}"
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
      image: docker:27.0.3
      readinessProbe:
        exec:
          command: [ "sh", "-c", "ls -l /run/docker.sock" ]
        initialDelaySeconds: 30
        periodSeconds: 10
        failureThreshold: 10
      command: [ "sh", "-c" ]
      args:
        - dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock
      securityContext:
        privileged: true
      volumeMounts:
        - name: docker-socket
          mountPath: /var/run
    - name: kubectl
      image: bitnami/kubectl:1.26.0
      command: [ "sleep" ]
      args: [ "99d" ]
                    ''') {
                    node(POD_LABEL) {
                            container('docker') {
                                script {
                                    // AWS ECR 로그인
                                    sh "apk add --no-cache groff less bash curl git iptables python3 py3-pip && \
                                    python3 -m venv .venv && . .venv/bin/activate && \
                                    pip install awscli --upgrade && which aws && deactivate "
                                    sh "git clone https://github.com/ciscocloud03-aws/woocommerce.git /home/jenkins/agent/woocommerce"
                                    sh "/home/jenkins/agent/workspace/woocommerce/.venv/bin/aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"

                                    // Docker 이미지 빌드 및 태그
                                    sh "cd /home/jenkins/agent/woocommerce && docker build --no-cache -t ${ECR_REGISTRY}/${ECR_REPOSITORY}:${env.BUILD_NUMBER} ."
                                    sh "docker images"
                                    sh "docker tag ${ECR_REGISTRY}/${ECR_REPOSITORY}:${env.BUILD_NUMBER} ${ECR_REPOSITORY}:${IMAGE_TAG}"

                                    // 이미지 푸시
                                    sh "docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:${env.BUILD_NUMBER} "

                                }
                            }
                    }
                }
            }
        }
      
    
  
         stage('Update 5ka Manifest Repository') {
             steps {
                 git credentialsId: 'github_pw',
                     url: "${params.gitlabWebaddress}",
                     branch: 'main'
                 script {
                     withCredentials([usernamePassword(credentialsId: 'github_pw', passwordVariable:"password", usernameVariable: "username")]) {
                         sh "git config --global user.email smth.hyj@gmail.com"
                         sh "git config --global user.name $username"
                         sh "git remote set-url origin https://${username}:${password}@github.com/ciscocloud03-aws/woo-manifest.git"
                         sh "rm -rf /var/jenkins_home/workspace/woocommerce/woo-manifest && git clone https://${username}:${password}@github.com/ciscocloud03-aws/woo-manifest.git /var/jenkins_home/workspace/woocommerce/woo-manifest"
                         sh "sed -i 's@image: .*@image: 339712790288.dkr.ecr.ap-northeast-2.amazonaws.com/woocommerce:${env.BUILD_NUMBER}@g' /var/jenkins_home/workspace/woocommerce/woo-manifest/woo-deploy.yaml"
                         sh "cd /var/jenkins_home/workspace/woocommerce/woo-manifest && cat woo-deploy.yaml && git add -A"
                         sh "git status" // 상태 확인
                         sh "git commit -m '[UPDATE] 5ka ${GIT_COMMIT} image versioning'"
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
