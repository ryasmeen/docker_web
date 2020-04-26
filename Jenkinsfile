node {
    def app
    stage('Clone repository') {
        /* Let's make sure we have the repository cloned to our workspace */

        checkout scm
    }

    stage('Build image') {
        /* This builds the actual image; synonymous to
         * docker build on the command line */

        app = docker.build("ryasmeen/docker_web")
    }

    stage('Test image') {
        /* Ideally, we would run a test framework against our image.
         * For this example, we're using a Volkswagen-type approach ;-) */

        app.inside {
            sh 'echo "Tests passed"'
        }
    }

    stage('Push image') {
        /* Finally, we'll push the image with two tags:
         * First, the incremental build number from Jenkins
         * Second, the 'latest' tag.
         * Pushing multiple tags is cheap, as all the layers are reused. */
        docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
        }
    }

    stage ('Deploy To Dev') {
        script {
            sshagent (credentials: ['caas-master-ssh-key']) {
                sh 'ssh -o StrictHostKeyChecking=no -l ryasmeen 192.168.1.234 uptime'
                sh 'ssh -o StrictHostKeyChecking=no -l ryasmeen 192.168.1.234 sudo docker rm -f webdocker'
                sh 'ssh -o StrictHostKeyChecking=no -l ryasmeen 192.168.1.234 sudo docker run -d --name docker-web  -it -p 8089:80 ryasmeen/docker_web'
            }
        }
    }
          	
	stage('Test Dev') {                          
	    script{
				sh "curl --write-out %{http_code} --silent --output /dev/null http://192.168.1.234:8089 > commandResult"
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
        
    stage ('Deploy To Prod') {
        script {
            sshagent (credentials: ['podman-master-ssh-key']) {
                sh 'ssh -o StrictHostKeyChecking=no -l amohamm2 192.168.1.235 uptime'
                sh 'ssh -o StrictHostKeyChecking=no -l amohamm2 192.168.1.235 sudo docker rm -f webdocker' 
                sh 'ssh -o StrictHostKeyChecking=no -l amohamm2 192.168.1.235 sudo docker run -d --name webdocker -it -p 8089:80 ryasmeen/docker_web'
            }
        }
    }
	
	stage('Test Prod') {                          
	    script{
				sh "curl --write-out %{http_code} --silent --output /dev/null http://192.168.1.235:8089 > commandResult"
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
