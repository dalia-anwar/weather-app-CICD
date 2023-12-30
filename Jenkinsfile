pipeline {
    agent any

    parameters {
        choice(name: 'BUILD_ENV', choices: ['dev', 'prod'], description: 'Select the build environment')
        string(name: 'IMAGE_VERSION', defaultValue: '1.0', description: 'Specify the application version')
        string(name: 'DOCKER_REGISTRY', defaultValue: '735783002763.dkr.ecr.eu-central-1.amazonaws.com/project_repo', description: 'Docker registry URL')
        booleanParam(name: 'RUN_TESTS', defaultValue: true, description: 'Run tests during the build')
    }

    // environment {
    //     sourceBranch = env.ghprbSourceBranch
    //     commitSHA = env.ghprbActualCommit
    //     author = env.ghprbPullAuthorLogin
    //     prDescription = env.ghprbPullDescription
    // }

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
                    sh 'echo starts Build'
                    sh 'echo $(whoami)'
                    sh 'echo ${PATH}'
                    sh 'docker build -t $DOCKER_REGISTRY/weather-app:$IMAGE_VERSION .'
                    sh 'echo ${PATH}'

                    sh 'echo ends Build'
                }
            }
        }


        stage('Run Angular Build') {
            steps {
                script {
                    sh 'docker run $DOCKER_REGISTRY/weather-app:$IMAGE_VERSION ng build'

                }
            }
        }

        stage('Run Angular Lint') {
            steps {
                script {
                    sh 'docker run $DOCKER_REGISTRY/weather-app:$IMAGE_VERSION ng lint '

                }
            }
        }

        stage('Run Angular Test') {
            steps {
                script {
                    try {
                        sh 'docker run $DOCKER_REGISTRY/weather-app:$IMAGE_VERSION ng test --watch=false --browsers ChromeHeadless'

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
                    sh 'docker run $DOCKER_REGISTRY/weather-app:$IMAGE_VERSION ng e2e --watch=false --browsers ChromeHeadless'
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
                    sh "trivy image $DOCKER_REGISTRY/weather-app:$IMAGE_VERSION"
                }
            }
        }

        stage('Push Image') {
            steps {
                script {
                    sh "echo Pushing Docker image to ECR"
                    sh "docker run $DOCKER_REGISTRY/weather-app:$IMAGE_VERSION"
                }
            }
        }

        stage('Clean Up') {
            steps {
                script {
                    // Clean up, e.g., stop and remove the docker container
                    sh "docker stop $DOCKER_REGISTRY/weather-app:$IMAGE_VERSION|| true"
                    sh "docker rm $DOCKER_REGISTRY/weather-app:$IMAGE_VERSION || true"
                }
            }
        }

        stage('Push Image') {
            steps {
                withAWS(credentials: "${AWS_CREDENTIALS_ID}"){
                    sh "(aws ecr get-login-password --region us-east-1) | docker login -u AWS --password-stdin ${DOCKER_REGISTRY}"
                    sh 'echo Pushing Docker image to $DOCKER_REGISTRY-$BUILD_NUMBER-$commitID'
                    sh 'docker push $DOCKER_REGISTRY/weather-app:$IMAGE_VERSION-$BUILD_NUMBER-$commitID'
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    // change agent to be ECS Fargate
                    // run docker
                    sh 'docker run -it -p 4200:4200 $DOCKER_REGISTRY/weather-app:$IMAGE_VERSION ng serve --host 0.0.0.0 --port 4200 > ng-serve.log 2>&1 &'
                }
            }
        }
    }
    post {
    //     success {
    //         script {
    //             def github = GitHub.connect(credentialsId: 'github_u_p')
    //             def repo = github.getRepository('dalia-anwar/weather-app-CICD')
    //             def sha = sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
    //             repo.createStatus(sha, 'SUCCESS', description: 'Build and tests passed', context: 'Jenkins')
    //         }
    //     }
    //     failure {
    //         script {
    //             def github = GitHub.connect(credentialsId: 'github_u_p')
    //             def repo = github.getRepository('dalia-anwar/weather-app-CICD')
    //             def sha = sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
    //             repo.createStatus(sha, 'FAILURE', description: 'Build or tests failed', context: 'Jenkins')
    //         }
    //     }
        always {
            emailext(
                subject: "Build ${currentBuild.currentResult} : Job ${currentBuild.fullDisplayName}",
                body: "Build ${currentBuild.currentResult} for Job ${currentBuild.fullDisplayName}",
                to: 'dalia.anwar112@gmail.com',
            )
        }
    }
}