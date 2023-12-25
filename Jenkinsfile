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

        stage('Docker Build Image') {
            steps {
                script {
                    sh 'echo starts Build'
                    sh 'echo $(whoami)'
                    sh 'echo ${env.PATH}'
                    sh ''' env.PATH = "/usr/bin/docker:${env.PATH}" \
                    Docker build -t weather-app:${IMAGE_VERSION} . '''
                    sh 'echo ${env.PATH}'

                    sh 'echo ends Build'
                }
            }
        }


        stage('Run Angular Build') {
            steps {
                script {
                    sh 'Docker run weather-app:${IMAGE_VERSION} ng build'

                }
            }
        }

        stage('Run Angular Test') {
            steps {
                script {
                    sh 'Docker run weather-app:${IMAGE_VERSION} ng test --watch=false --browsers ChromeHeadless'

                }
            }
        }

        stage('Run Angular E2E') {
            steps {
                script {
                    sh 'Docker run weather-app:${IMAGE_VERSION} ng e2e'

                }
            }
        }  

        stage('Run Angular Lint') {
            steps {
                script {
                    sh 'Docker run weather-app:${IMAGE_VERSION} ng lint'

                }
            }
        }

        stage('Clean Up') {
            steps {
                script {
                    // Clean up, e.g., stop and remove the Docker container
                    sh "docker stop weather-app:${IMAGE_VERSION}|| true"
                    sh "docker rm weather-app:${IMAGE_VERSION} || true"
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline succeeded! Deploying to ${BUILD_ENV} environment."
            sh "Docker run weather-app:${IMAGE_VERSION} ng serve  --host=0.0.0.0 --port=4200"
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
