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

        stage('Run Angular Test') {
            steps {
                script {
                    try {
                        sh '''sudo su root \
                            echo "export APP_ENV=dev" >> /etc/environment \
                            echo "export TYPE_SERVER=AWS" >> /etc/environment \
                            sudo yum update -y amazon-linux-extras \
                            sudo wget https://dl.google.com/linux/chrome/rpm/stable/x86_64/google-chrome-stable-110.0.5481.177-1.x86_64.rpm && yum localinstall -y google-chrome-stable-110.0.5481.177-1.x86_64.rp
                            '''
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
                    sh 'docker run weather-app:${IMAGE_VERSION} ng e2e --silent'
                    }
                    catch (Exception e) {
                        echo "Stage e2e failed, but continuing..."
                    }

                }
            }
        }  

        stage('Run Angular Lint') {
            steps {
                script {
                    sh 'docker run weather-app:${IMAGE_VERSION} ng lint --silent'

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
            sh "docker run weather-app:${IMAGE_VERSION} ng serve  --host=0.0.0.0 --port=4200"
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
