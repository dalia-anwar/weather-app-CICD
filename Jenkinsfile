pipeline {
    agent any

    parameters {
        choice(name: 'BUILD_ENV', choices: ['dev', 'prod'], description: 'Select the build environment')
        string(name: 'IMAGE_VERSION', defaultValue: '1.0', description: 'Specify the application version')
    }

    environment {
        GitHubToken = credentials('Github-token')
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials-id')
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Docker Build Image') {
            steps {
                script {
                    // Build Docker image
                    sh 'Docker build -t weather-app:${params.IMAGE_VERSION} .'
                    // docker.withRegistry('https://registry.hub.docker.com', 'DOCKER_HUB_CREDENTIALS') {
                    //     def customImage = docker.build("my-docker-image:${env.BUILD_NUMBER}")
                    // }
                }
            }
        }


        stage('Run Angular Build') {
            steps {
                script {
                    sh 'Docker run weather-app:${params.IMAGE_VERSION} ng build'

                }
            }
        }

        stage('Run Angular Test') {
            steps {
                script {
                    sh 'Docker run weather-app:${params.IMAGE_VERSION} ng test --watch=false --browsers ChromeHeadless'

                }
            }
        }

        stage('Run Angular E2E') {
            steps {
                script {
                    sh 'Docker run weather-app:${params.IMAGE_VERSION} ng e2e'

                }
            }
        }  

        stage('Run Angular Lint') {
            steps {
                script {
                    sh 'Docker run weather-app:${params.IMAGE_VERSION} ng lint'

                }
            }
        }

        stage('Clean Up') {
            steps {
                script {
                    // Clean up, e.g., stop and remove the Docker container
                    sh "docker stop weather-app:${params.IMAGE_VERSION}|| true"
                    sh "docker rm weather-app:${params.IMAGE_VERSION} || true"
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline succeeded! Deploying to ${env.BUILD_ENV} environment."
            sh "Docker run weather-app:${params.IMAGE_VERSION} ng serve  --host=0.0.0.0 --port=4200"
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
