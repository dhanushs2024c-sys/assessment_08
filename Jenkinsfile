pipeline {

    agent any

    environment {
        DOCKER_IMAGE = "dhan01/noticeboard"
        DOCKER_TAG = "latest"

        DOCKER_EXE = "C:\\Users\\nares\\AppData\\Local\\Programs\\DockerDesktop\\resources\\bin\\docker.exe"
        KUBECTL_EXE = "kubectl"
    }

    stages {

        stage('Clone Code') {
            steps {
                echo 'Code has been checked out from GitHub.'
                bat '''
                    echo Current workspace:
                    cd
                    echo.
                    echo Project files:
                    dir
                '''
            }
        }

        stage('Check Docker') {
            steps {
                bat '''
                    echo ========================================
                    echo Checking Docker
                    echo ========================================

                    "%DOCKER_EXE%" --version

                    echo.
                    echo Docker executable found successfully.
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                bat '''
                    echo ========================================
                    echo Building Docker Image
                    echo ========================================

                    "%DOCKER_EXE%" build -t %DOCKER_IMAGE%:%DOCKER_TAG% .

                    echo.
                    echo Docker image built successfully.
                '''
            }
        }

        stage('Check Docker Image') {
            steps {
                bat '''
                    echo ========================================
                    echo Checking Docker Image
                    echo ========================================

                    "%DOCKER_EXE%" images %DOCKER_IMAGE%

                    echo.
                    echo Image check completed.
                '''
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
                        echo ========================================
                        echo Logging in to Docker Hub
                        echo ========================================

                        echo %DOCKER_PASSWORD% | "%DOCKER_EXE%" login -u "%DOCKER_USERNAME%" --password-stdin

                        if errorlevel 1 (
                            echo Docker Hub login failed.
                            exit /b 1
                        )

                        echo.
                        echo Pushing Docker image...

                        "%DOCKER_EXE%" push %DOCKER_IMAGE%:%DOCKER_TAG%

                        if errorlevel 1 (
                            echo Docker image push failed.
                            exit /b 1
                        )

                        echo.
                        echo Docker image pushed successfully.
                    '''
                }
            }
        }

        stage('Check Kubernetes') {
            steps {
                bat '''
                    echo ========================================
                    echo Checking Kubernetes
                    echo ========================================

                    kubectl version --client

                    echo.
                    kubectl get nodes

                    if errorlevel 1 (
                        echo Kubernetes is not available.
                        exit /b 1
                    )

                    echo.
                    echo Kubernetes is available.
                '''
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
                        echo ========================================
                        echo Deploying to Kubernetes
                        echo ========================================

                        set KUBECONFIG=%KUBECONFIG_FILE%

                        kubectl apply -f deployment.yaml

                        if errorlevel 1 (
                            echo Kubernetes deployment failed.
                            exit /b 1
                        )

                        echo.
                        echo Kubernetes deployment successful.
                    '''
                }
            }
        }

        stage('Wait for Pods') {
            steps {
                withCredentials([
                    file(
                        credentialsId: 'kubeconfig',
                        variable: 'KUBECONFIG_FILE'
                    )
                ]) {
                    bat '''
                        echo ========================================
                        echo Waiting for Kubernetes Pods
                        echo ========================================

                        set KUBECONFIG=%KUBECONFIG_FILE%

                        kubectl rollout status deployment/college-notice-board --timeout=120s

                        if errorlevel 1 (
                            echo Deployment rollout failed.
                            exit /b 1
                        )

                        echo.
                        echo Pods are ready.
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
                        echo ========================================
                        echo Kubernetes Deployment Verification
                        echo ========================================

                        set KUBECONFIG=%KUBECONFIG_FILE%

                        echo.
                        echo ===== DEPLOYMENT =====
                        kubectl get deployment

                        echo.
                        echo ===== PODS =====
                        kubectl get pods -o wide

                        echo.
                        echo ===== SERVICE =====
                        kubectl get service

                        echo.
                        echo ===== SERVICE DETAILS =====
                        kubectl describe service college-notice-board-service

                        echo.
                        echo Kubernetes verification completed.
                    '''
                }
            }
        }
    }

    post {

        success {
            echo '''
========================================
PIPELINE SUCCESS
========================================
College Notice Board deployment completed successfully.

Docker Image:
dhan01/noticeboard:latest

Kubernetes:
2 replicas

NodePort:
30080

Open in browser:
http://localhost:30080
========================================
'''
        }

        failure {
            echo '''
========================================
PIPELINE FAILED
========================================
Check the Console Output above to identify
the failed stage.
========================================
'''
        }

        always {
            echo 'Zero-Trust / CI-CD pipeline execution completed.'
        }
    }
}
