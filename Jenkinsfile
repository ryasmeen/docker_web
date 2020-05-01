pipeline {
  environment {
    registry = "ryasmeen/docker_web"
    registryCredential = 'docker-hub-credentials'
    dockerImage = ''
    HOSTA = "192.168.1.234"
    HOSTB = "192.168.1.242"
    DPORT = "8001"
    SPORT = "80"
    webAppResourceGroup = 'rehana_app_services'
    webAppResourcePlan = 'ryasmeen-app-service-plan'
    webAppName = 'docker-azure-jenkins-demo'
    imageName = 'docker_web'
    imageWithTag = '1.0'
    containerDomain = "centralus.azurecontainer.io"
    CHECK_URL_DEV = "http://${HOSTA}:${DPORT}"
    CMD_DEV = "curl --write-out %{http_code} --silent --output /dev/null ${CHECK_URL_DEV}"
    CHECK_URL_UAT = "http://{HOSTB}:${DPORT}"
    CMD_UAT = "curl --write-out %{http_code} --silent --output /dev/null ${CHECK_URL_UAT}"
    CHECK_URL_AZURE = "http://${webAppName}.${containerDomain}/"
    CMD_AZURE = "curl --write-out %{http_code} --silent --output /dev/null ${CHECK_URL_AZURE}"
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
                                       sh 'ssh -o StrictHostKeyChecking=no -l ryasmeen ${HOSTA} sudo docker run -d --name ${webAppName} -it -p ${DPORT}:${SPORT} ${registry}:${imageWithTag}'
                                }
            }
        }
    }

    stage ('Test Dev') {
                steps {
                        script{
                                sh './test.sh -w ${HOSTA} -p ${DPORT}'
            }
        }
    }

    stage ('Deploy To UAT') {
                steps {
                        script {
                                sshagent (credentials: ['podman-master-ssh-key']) {
                                        sh 'ssh -o StrictHostKeyChecking=no -l amohamm2 ${HOSTB} uptime'
                                        sh 'ssh -o StrictHostKeyChecking=no -l amohamm2 ${HOSTB} sudo docker rm -f ${webAppName}'
                                        sh 'ssh -o StrictHostKeyChecking=no -l amohamm2 ${HOSTB} sudo docker run -d --name ${webAppName} -it -p ${DPORT}:${SPORT} ${registry}:${imageWithTag}'
                                }
            }
        }
    }

    stage ('Test UAT') {
                steps {
                        script{
                                sh './test.sh -w ${HOSTB} -p ${DPORT}'
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
     stage ('Azure') {
           steps {
                  script{
                         sh './test.sh -w "${webAppName}.${containerDomain}" -p ${SPORT}'
                        }
                   }
           }

     }
}
