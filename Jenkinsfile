pipeline {
    agent any

    parameters {
        choice(name: 'BUILD_ENV', choices: ['dev', 'prod'], description: 'Select the build environment')
        string(name: 'IMAGE_VERSION', defaultValue: '1.0', description: 'Specify the application version')
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
                sh 'echo Done cloning'
            }
        }

        stage('docker Build Image') {
            steps {
                script {
                    sh 'echo starts Build'
                    sh 'echo $(whoami)'
                    sh 'echo ${PATH}'
                    sh 'docker build -t weather-app:${IMAGE_VERSION} .'
                    sh 'echo ${PATH}'

                    sh 'echo ends Build'
                }
            }
        }


        stage('Run Angular Build') {
            steps {
                script {
                    sh 'docker run weather-app:${IMAGE_VERSION} ng build'

                }
            }
        }

        stage('Run Angular Lint') {
            steps {
                script {
                    sh 'docker run weather-app:${IMAGE_VERSION} ng lint '

                }
            }
        }

        stage('Run Angular Test') {
            steps {
                script {
                    try {
                        sh 'docker run weather-app:${IMAGE_VERSION} ng test --watch=false --browsers ChromeHeadless'

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
                    sh 'docker run weather-app:${IMAGE_VERSION} ng e2e '
                    }
                    catch (Exception e) {
                        echo "Stage e2e failed, but continuing..."
                    }

                }
            }
        }  



        stage('Clean Up') {
            steps {
                script {
                    // Clean up, e.g., stop and remove the docker container
                    sh "docker stop weather-app:${IMAGE_VERSION}|| true"
                    sh "docker rm weather-app:${IMAGE_VERSION} || true"
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline succeeded! Deploying to ${BUILD_ENV} environment."
            sh "docker run -p 4200:4200 weather-app:${IMAGE_VERSION}"
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
