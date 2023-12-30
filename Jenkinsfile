pipeline {
    agent any

    parameters {
        choice(name: 'BUILD_ENV', choices: ['dev', 'prod'], description: 'Select the build environment')
        string(name: 'IMAGE_VERSION', defaultValue: '$GIT_COMMIT', description: 'Specify the application version')
        string(name: 'DOCKER_REGISTRY', defaultValue: '735783002763.dkr.ecr.eu-central-1.amazonaws.com', description: 'Docker registry URL')
        booleanParam(name: 'RUN_TESTS', defaultValue: true, description: 'Run tests during the build')
    }

    environment {

        AWS_CREDENTIALS_ID = 'aws_key'
    }

    stages {
        stage('Checkout Code') {
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
            steps {
                script {
                    sh 'pwd'
                    sh 'ls '
                    sh 'echo starts Build'
                    sh 'echo $(whoami)'
                    sh 'echo ${PATH}'
                    sh 'cd ./web-app && pwd && docker build -t project_repo:$IMAGE_VERSION .'
                    sh 'echo ${PATH}'

                    sh 'echo ends Build'
                }
            }
        }


        stage('Run Angular Build') {
            steps {
                script {
                    sh 'cd web-app && docker run project_repo:$IMAGE_VERSION ng build'

                }
            }
        }

        stage('Run Angular Lint') {
            steps {
                script {
                    sh 'cd web-app && docker run project_repo:$IMAGE_VERSION ng lint '

                }
            }
        }

        stage('Run Angular Test') {
            steps {
                script {
                    try {
                        sh 'cd web-app && docker run project_repo:$IMAGE_VERSION ng test --watch=false --browsers ChromeHeadless'

                    }
                    catch (Exception e) {
                        echo "Stage test failed, but continuing..."
                    }

                }
            }
        }

        stage('Run Angular E2E') {
            steps {
                script {
                    try{
                    sh 'cd web-app && docker run project_repo:$IMAGE_VERSION ng e2e --watch=false --browsers ChromeHeadless'
                    }
                    catch (Exception e) {
                        echo "Stage e2e failed, but continuing..."
                    }

                }
            }
        }  

        stage('Trivy Scan') {
            steps {
                script {
                    sh "cd web-app && trivy image project_repo:$IMAGE_VERSION"
                }
            }
        }

        // stage('Push Image') {
        //     steps {
        //         script {
        //             sh "echo Pushing Docker image to ECR"
        //             sh "docker run project_repo:$IMAGE_VERSION"
        //         }
        //     }
        // }

        stage('Clean Up') {
            steps {
                script {
                    // Clean up, e.g., stop and remove the docker container
                    sh "cd web-app && docker stop project_repo:$IMAGE_VERSION|| true"
                    sh "docker rm project_repo:$IMAGE_VERSION || true"
                }
            }
        }

        stage('Push Image') {
            steps {
            
            withAWS(credentials: "${AWS_CREDENTIALS_ID}"){
                    sh 'docker tag project_repo:$IMAGE_VERSION 735783002763.dkr.ecr.eu-central-1.amazonaws.com/project_repo:$IMAGE_VERSION'
                    sh """ cd web-app && aws ecr get-login-password --region eu-central-1  | docker login --username AWS --password-stdin  $DOCKER_REGISTRY 
                    docker push 735783002763.dkr.ecr.eu-central-1.amazonaws.com/project_repo:$IMAGE_VERSION """
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    // change agent to be ECS Fargate
                    // run docker
                    sh 'docker stop $(docker ps -q) && docker rm $(docker ps -aq)'
                    sh 'cd web-app'
                    sh 'docker run -p 4200:4200 project_repo:$IMAGE_VERSION ng serve --host 0.0.0.0 --port 4200 > ng-serve.log 2>&1 &'
                }
            }
        }
    }
    post {

        success {
            emailext body: 'Job Paased',
                subject: 'Job Passed',
                to: 'dalia.anwar112@gmail.com'
        }
        failure {
            emailext body: 'Job failed',
                subject: 'Job failed',
                to: 'dalia.anwar112@gmail.com'
        }
    }
}
