pipeline {
  environment {
    registry = "ryasmeen/docker_web"
    registryCredential = 'docker-hub-credentials'
    dockerImage = ''
    HOSTA = "192.168.1.234"
    HOSTB = "192.168.1.241"
    CHECK_URL_DEV = "http://192.168.1.234:8001"
    CMD_DEV = "curl --write-out %{http_code} --silent --output /dev/null ${CHECK_URL_DEV}"
    CHECK_URL_UAT = "http://192.168.1.241:8001"
    CMD_UAT = "curl --write-out %{http_code} --silent --output /dev/null ${CHECK_URL_UAT}"
    CHECK_URL_AZURE = "http://docker-azure-jenkins-demo.centralus.azurecontainer.io/"
    CMD_AZURE = "curl --write-out %{http_code} --silent --output /dev/null ${CHECK_URL_AZURE}"
    webAppResourceGroup = 'rehana_app_services'
    webAppResourcePlan = 'ryasmeen-app-service-plan'
    webAppName = 'docker-azure-jenkins-demo'
    imageName = 'docker_web'
    imageWithTag = '1.0'
  }
  agent any
  stages {
    stage('Cloning Git Repo') {
      steps {
        git 'https://github.com/ryasmeen/docker_web.git'
      }
    }
    stage('Building image') {
      steps{
        script {
          dockerImage = docker.build registry + ":1.0"
        }
      }
    }
     stage('Push - Deploy Image') {
      steps {
        script {
          docker.withRegistry( '', registryCredential ) {
            dockerImage.push()
          }
        }
      }
    }
        stage ('Deploy To Dev') {
                steps {
                        script {
                                sshagent (credentials: ['caas-master-ssh-key']) {
                                        sh 'ssh -o StrictHostKeyChecking=no -l ryasmeen ${HOSTA} uptime'
                                        sh 'ssh -o StrictHostKeyChecking=no -l ryasmeen ${HOSTA} sudo docker rm -f ${webAppName}'
                                        sh 'ssh -o StrictHostKeyChecking=no -l ryasmeen ${HOSTA} sudo docker run -d --name ${webAppName} -it -p 8001:80 ${registry}:${imageWithTag}'
                                }
            }
        }
    }

/*         stage('Test Dev') {
                steps {
                        script{
                                sh "${CMD_DEV} > commandResult"
                                env.status = readFile('commandResult').trim()
                                sh "echo ${env.status}"
                                if (env.status == '200') {
                                                currentBuild.result = "SUCCESS"
                                }
                                else {
                                                currentBuild.result = "FAILURE"
                                }
                        }
                }
        } */

    stage ('Test Dev') {
                steps {
                        script{
                                sh './testA.sh'
            }
        }
    }

          

    stage ('Deploy To UAT') {
                steps {
                        script {
                                sshagent (credentials: ['podman-master-ssh-key']) {
                                        sh 'ssh -o StrictHostKeyChecking=no -l amohamm2 ${HOSTB} uptime'
                                        sh 'ssh -o StrictHostKeyChecking=no -l amohamm2 ${HOSTB} sudo docker rm -f ${webAppName}'
                                        sh 'ssh -o StrictHostKeyChecking=no -l amohamm2 ${HOSTB} sudo docker run -d --name ${webAppName} -it -p 8001:80 ${registry}:${imageWithTag}'
                                }
            }
        }
    }

       /*  stage('Test UAT') {
                steps {
                        script{
                                sh "${CMD_UAT} > commandResult"
                                env.status = readFile('commandResult').trim()
                                sh "echo ${env.status}"
                                if (env.status == '200') {
                                                currentBuild.result = "SUCCESS"
                                }
                                else {
                                                currentBuild.result = "FAILURE"
                                }
                        }
                }
        } */

    stage ('Test UAT') {
                steps {
                        script{
                                sh './testB.sh'
            }
        }
    }


        stage('Deploy to Azure') {
                                steps {
                                                script{
                                                                // login Azure
                                                                withCredentials([azureServicePrincipal('ryazsvprincipal')]) {
                                                                sh '''
                                                                az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID
                                                                az account set -s $AZURE_SUBSCRIPTION_ID
                                                                '''
                                                               //sh "az webapp create -g ${webAppResourceGroup} -p ${webAppResourcePlan} -n ${webAppName} -i ${registry}:${imageWithTag}"
                                                                sh "az container create --resource-group ${webAppResourceGroup} --name ${webAppName}  --image ${registry}:${imageWithTag} --dns-name-label ${webAppName} --ports 80"
																}
                                                        }
                                        }
                        }


        stage('Test Azure App') {
                steps {
                        script{
                                sh "${CMD_AZURE} > commandResult"
                                env.status = readFile('commandResult').trim()
                                sh "echo ${env.status}"
                                if (env.status == '200') {
                                                currentBuild.result = "SUCCESS"
                                }
                                else {
                                                currentBuild.result = "FAILURE"
                                }
                        }
                }
        }

     }
}
