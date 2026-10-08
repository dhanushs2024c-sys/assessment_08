pipeline {

    agent any

    environment {
        DOCKER_IMAGE = "dhan01/noticeboard"
        DOCKER_TAG = "latest"
    }

    stages {

        stage('Clone Code') {
            steps {
                echo 'Code has been checked out by Jenkins.'
            }
        }

        stage('Check Docker') {
            steps {
                bat '''
                    echo Checking Docker...
                    where docker
                    docker --version
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                bat 'docker build -t %DOCKER_IMAGE%:%DOCKER_TAG% .'
            }
        }

        stage('Push Image') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    bat '''
                        docker login -u "%DOCKER_USERNAME%" -p "%DOCKER_PASSWORD%"
                        docker push %DOCKER_IMAGE%:%DOCKER_TAG%
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([
                    file(
                        credentialsId: 'kubeconfig',
                        variable: 'KUBECONFIG_FILE'
                    )
                ]) {
                    bat '''
                        set KUBECONFIG=%KUBECONFIG_FILE%
                        kubectl apply -f deployment.yaml
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                withCredentials([
                    file(
                        credentialsId: 'kubeconfig',
                        variable: 'KUBECONFIG_FILE'
                    )
                ]) {
                    bat '''
                        set KUBECONFIG=%KUBECONFIG_FILE%
                        kubectl get deployment
                        kubectl get pods
                        kubectl get service
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'College Notice Board deployed successfully!'
        }

        failure {
            echo 'Pipeline failed.'
        }
    }
}
