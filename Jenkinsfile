pipeline {
    agent none
    parameters {
        string(name: 'DOCKER_REGISTRY', defaultValue: '735783002763.dkr.ecr.eu-central-1.amazonaws.com', description: 'Docker registry URL')
    }

    environment {
        IMAGE_VERSION =  "${env.BUILD_ID}"
        AWS_CREDENTIALS_ID = 'aws_key'
        BUILD_NUMBER = "${env.BUILD_ID}"

    }

    stages {
        stage('Checkout Code') {
            agent {label 'worker_node'}
            steps {
                checkout scm
                sh 'echo Done cloning'
                // echo "Source Branch: ${sourceBranch}"
                // echo "Commit SHA: ${commitSHA}"
                // echo "Author: ${author}"
                // echo "PR Description: ${prDescription}"
            }
        }

        stage('docker Build Image') {
            agent {label 'worker_node'}
            steps {
                script {
                    sh 'pwd'
                    sh 'ls '
                    sh 'echo starts Build'
                    sh 'echo $(whoami)'
                    sh 'echo ${PATH}'
                    sh 'cd ./web-app && pwd && docker build -t weather_app:$IMAGE_VERSION .'
                    sh 'echo ${PATH}'
                    sh 'echo ends Build'
                }
            }
        }


        stage('Run Angular Build') {
            agent {label 'worker_node'}
            steps {
                script {
                    sh 'cd web-app && docker run -v /var/jenkins/workspace/web-app-CICD/web-app/dist:/app/dist/ weather_app:$IMAGE_VERSION ng build'

                }
            }
        }

        stage('Run Angular Lint') {
            agent {label 'worker_node'}
            steps {
                script {
                    sh 'cd web-app && docker run weather_app:$IMAGE_VERSION ng lint '

                }
            }
        }

        stage('Run Angular Test') {
            agent {label 'worker_node'}
            steps {
                script {
                    try {
                        sh 'cd web-app && docker run weather_app:$IMAGE_VERSION ng test --watch=false --browsers ChromeHeadless'

                    }
                    catch (Exception e) {
                        echo "Stage test failed, but continuing for demp purpose only..."
                    }

                }
            }
        }

        stage('Run Angular E2E') {
            agent {label 'worker_node'}
            steps {
                script {
                    try{
                    sh 'cd web-app && docker run weather_app:$IMAGE_VERSION ng e2e --watch=false --browsers ChromeHeadless'
                    }
                    catch (Exception e) {
                        echo "Stage e2e failed, but continuing for demp purpose only..."
                    }

                }
            }
        }  

        stage('Trivy Scan') {
            agent {label 'worker_node'}
            steps {
                script {
                    sh "cd web-app && trivy image weather_app:$IMAGE_VERSION"
                }
            }
        }


        
        stage('Upload to S3') {
            agent {label 'worker_node'}
            steps {
                script{
            sh 'echo aws s3 cp ./web-app/dist/* s3://myappbuscket/dist/$BUILD_NUMBER_$IMAGE_VERSION --recursive --region eu-central-1'
            sh "aws s3 cp ./web-app/dist/* s3://myappbuscket/dist/$BUILD_NUMBER --recursive --region eu-central-1"      
            }
            }
        }
        stage('Clean Up') {
            agent {label 'worker_node'}
            steps {
                script {
                    try{
                    // Clean up, e.g., stop and remove the docker container
                    sh "cd web-app && docker stop weather_app:$IMAGE_VERSION|| true"
                    sh "docker rm weather_app:$IMAGE_VERSION || true"
                    sh 'docker stop $(docker ps -q)'
                    sh 'docker rm $(docker ps -aq)'
                    }
                    catch (Exception e) {
                        echo "Stage test failed, but continuing for demp purpose only..."
                    }
                }
            }
        }

        stage('Push Image') {
            agent {label 'worker_node'}
            steps {
            
            withAWS(credentials: "${AWS_CREDENTIALS_ID}"){
                    sh 'docker tag weather_app:$IMAGE_VERSION $DOCKER_REGISTRY/weather_app:$IMAGE_VERSION'
                    sh """ cd web-app && aws ecr get-login-password --region eu-central-1  | docker login --username AWS --password-stdin  $DOCKER_REGISTRY 
                    docker push $DOCKER_REGISTRY/weather_app:$IMAGE_VERSION """
                }
            }
        }
        stage('Testing ENV Deploy') {
            agent {label 'worker_node'}
            steps {
                script {
                    // change agent to be ECS Fargate
                    // run docker
                    sh 'cd web-app'
                    sh 'docker run -p 4200:4200 weather_app:$IMAGE_VERSION ng serve --host 0.0.0.0 --port 4200 > ng-serve.log 2>&1 &'
                }
            }
        }


        stage('PROD Clean Up') {
            agent {label 'deployment_node'}
            steps {
                script {
                    try{
                    // Clean up, e.g., stop and remove the docker container
                    sh "cd web-app && docker stop weather_app:$IMAGE_VERSION|| true"
                    sh "docker rm weather_app:$IMAGE_VERSION || true"
                    sh 'docker stop $(docker ps -q)'
                    sh 'docker rm $(docker ps -aq)'
                    }
                    catch (Exception e) {
                        echo "Stage test failed, but continuing for demp purpose only..."
                    }
                }
            }
        }
        stage('Production ENV Deploy') {
            agent {label 'deployment_node'}
            steps {
                withAWS(credentials: "${AWS_CREDENTIALS_ID}"){
                    sh """ aws ecr get-login-password --region eu-central-1  | docker login --username AWS --password-stdin  $DOCKER_REGISTRY 
                    docker pull $DOCKER_REGISTRY/weather_app:$IMAGE_VERSION """
                    sh 'docker run -p 4200:4200  $DOCKER_REGISTRY/weather_app:$IMAGE_VERSION ng serve --host 0.0.0.0 --port 4200 > ng-serve.log 2>&1 &'
                }
            }
        }
    }
    post {
        success {
            agent {label 'worker_node'}
            emailext body: 'Job Paased',
                subject: 'Job Passed',
                to: 'dalia.anwar112@gmail.com'
        }
        failure {
            agent {label 'worker_node'}
            emailext body: 'Job failed',
                subject: 'Job failed',
                to: 'dalia.anwar112@gmail.com'
        }
    }
    
    
}