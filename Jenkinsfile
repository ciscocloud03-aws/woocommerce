pipeline {
  agent any
//  tools {
//    maven 'my_maven'
//  }

  parameters {
    string(name: 'gitlabName', defaultValue: 'smth-hyj')
    string(name: 'gitlabEmail', defaultValue: 'smth.hyj@gmail.com')
    string(name: 'gitlabWebaddress', defaultValue: 'https://github.com/ciscocloud03-aws/woocommerce.git')
    string(name: 'gitlabCredential', defaultValue: 'github_pw', description: 'github_pw')
    string(name: 'githelmaddress', defaultValue: '', description: 'git helm repository') //defaultvalue 변경 예정
    string(name: 'githelmshortddress', defaultValue: '', description: 'git helm repository')    
    string(name: 'ecrrepositoryCredential', defaultValue: 'ecrjenkins')
    string(name: 'ecrrepository', defaultValue: 'https://339712790288.dkr.ecr.ap-northeast-2.amazonaws.com')
    string(name: 'namespace', defaultValue: 'jen')
    
  }
  stages {
    stage('Checkout Gitlab') {
      steps {
        checkout changelog: false,
         scm: scmGit(branches: [[name: 'yejin']],
                     userRemoteConfigs: [
                         [ credentialsId: "${params.gitlabCredential}",
                           url: 'https://github.com/ciscocloud03-aws/woocommerce.git']
                         ])
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
                  command: [sh, -c, "ls -S /var/run/docker.sock"]
              args: ["dockerd", "-H", "tcp://0.0.0.0:2377"]
              securityContext:
                privileged: true
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
              - 11d
        ''') {
          node(POD_LABEL) {
              git url: 'https://github.com/ciscocloud03-aws/woocommerce.git', branch: 'yejin'

              // // Maven 빌드 실행
              // container('maven') {
              //     sh "mvn clean install" 
              // }

              // Docker 작업 실행
              container('docker') {
                  checkout scm
                  // Docker 이미지 빌드 및 푸시
                  script {
                      def app = docker.build("smthhyj/woocommerce")
                      docker.withRegistry('339712790288.dkr.ecr.ap-northeast-2.amazonaws.com', 'ecrjenkins') {
                          app.push("${env.BUILD_NUMBER}") // 특정 태그로 푸시
                          app.push("latest") // 최신 버전으로 푸시
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
                branch: 'yejin'
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
            sh "git checkout yejin"
            sh "sed -i 's@version:.*@version: ${env.BUILD_NUMBER}@g' ./values.yaml"
            sh "sed -i 's@repository:.*@repository: nexus.ihp001.dev@g' ./values.yaml"
            sh "git add ."
            sh "git config --global user.email ${params.gitlabName}"
            sh "git config --global user.name ${params.gitlabEmail}"
            sh "git commit -m '[UPDATE] 5ka ${GIT_COMMIT} image versioning'"
            sh "git remote set-url origin ${params.githelmshortddress}"
            sh "git push -f origin yejin"
            }
        }
    }
