// pipeline {
//     agent any

//     environment {
//         ECR_REGISTRY = '339712790288.dkr.ecr.ap-northeast-2.amazonaws.com'
//         ECR_REPOSITORY = 'woocommerce'
//         IMAGE_TAG = 'latest'
//         KUBECONFIG_CREDENTIALS_ID = '64f03af0-1d4c-4bff-9cd6-bab0481dd2f9'
//         AWS_REGION = 'ap-northeast-2'
//     }

//     stages {
//         stage('Checkout') {
//             steps {
//                 // Git 리포지토리에서 소스 코드를 체크아웃
//                 checkout scm
//             }
//         }

//         stage('Build Docker Image') {
//             steps {
//                 script {
//                     // AWS ECR 로그인
//                     sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"

//                     // Docker 이미지 빌드
//                     sh "docker build -t ${ECR_REPOSITORY}:${IMAGE_TAG} ."
                    
//                     // 이미지에 태그 추가
//                     sh "docker tag ${ECR_REPOSITORY}:${env.BUILD_NUMBER} ${ECR_REGISTRY}/${ECR_REPOSITORY}:${env.BUILD_NUMBER}"
                    
//                     // 이미지 푸시
//                     sh "docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
//                 }
//             }
//         }

//         stage('Deploy to EKS') {
//             steps {
//                 script {
//                     withCredentials([file(credentialsId: KUBECONFIG_CREDENTIALS_ID, variable: 'KUBECONFIG')]) {
//                         // Kubernetes 마니페스트를 적용하여 EKS 클러스터에 배포
//                         sh 'kubectl apply -f woocommerce-deploy.yaml -f woocommerce-service.yaml'
//                     }
//                 }
//             }
//         }
//     }

//     post {
//         success {
//             echo 'Deployment was successful!'
//         }
//         failure {
//             echo 'Deployment failed!'
//         }
//     }
// }

pipeline {
  agent any
//  tools {
//    maven 'my_maven'
//  }

  parameters {
    string(name: 'gitlabName', defaultValue: 'smth-hyj')
    string(name: 'gitlabEmail', defaultValue: 'smth.hyj@gmail.com')
    string(name: 'gitlabWebaddress', defaultValue: 'https://github.com/ciscocloud03-aws/woocommerce.git')
    string(name: 'gitlabCredential', defaultValue: 'github_pw', description: '')
    string(name: 'githelmaddress', defaultValue: '', description: 'git helm repository') //defaultvalue 변경 예정
    string(name: 'githelmshortddress', defaultValue: '', description: 'git helm repository')    
    string(name: 'ecrrepositoryCredential', defaultValue: 'woocommerce')
    string(name: 'ecrrepository', defaultValue: 'https://339712790288.dkr.ecr.ap-northeast-2.amazonaws.com')
    string(name: 'namespace', defaultValue: 'woo')
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
    stage('Dokcer pod deploy') {
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
              image: docker
              readinessProbe:
                exec:
                  command: [sh, -c, "ls -l /var/run/docker.sock"]
              volumeMounts:
              - name: docker-socket
                mountPath: /var/run
            - name: docker-daemon
              image: docker:dind
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
            - name: 
        ''') {
          node(POD_LABEL) {

            container('docker') {
              script {
                checkout scm
              }
            }

            contianer('docker-daemon') {
                script {
                  sh '''
                  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                  unzip awscliv2.zip
                  sudo ./aws/install
                  '''
                }
            }
            

            script{
                stage('Push Docker image') {
                  def app = docker.build("smthhyj/woocommerce") // Docker 이미지를 빌드합니다.
                  docker.withRegistry('339712790288.dkr.ecr.ap-northeast-2.amazonaws.com', 'woocommerce') {
                  app.push("${env.BUILD_NUMBER}") // 이미지를 특정 태그로 푸시합니다.
                  app.push("latest") // 이미지를 최신 버전으로 푸시합니다.
                   }
                  }
                }
               }
              }
            }
          }
        }
      }

    stage('5ka Manifest Repository change') {
        steps {
            git credentialsId: "${params.gitlabCredential}",
                url: "${params.githelmaddress}",
                branch: 'main'
        }
        post {
                failure {
                echo '5ka Repository change failure !'
                }
                success {
                echo '5ka Repository change success !'
                }
        }
    }

    stage('manifest Update') {
        steps {
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
