// Declarative pipeline.
// Jenkins prerequisites (Manage Jenkins -> Tools): a Maven install named "Maven3"
// and a JDK 17 install named "JDK17". Docker must be available on the agent for the last stage.
pipeline {
    agent any

    tools {
        maven 'Maven3'
        jdk 'JDK17'
    }

    options {
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    // CI trigger: poll Git every minute (or use a GitHub webhook instead)
    triggers {
        pollSCM('* * * * *')
    }

    environment {
        IMAGE_NAME = 'todo-api'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.GIT_SHORT = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    // CI enhancement: every build is tied to a build number + commit SHA
                    env.IMAGE_TAG = "${env.BUILD_NUMBER}-${env.GIT_SHORT}"
                }
            }
        }

        stage('Test') {
            steps {
                sh 'mvn -B clean test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('Build') {
            steps {
                sh 'mvn -B -DskipTests package'
            }
        }

        stage('Archive') {
            steps {
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Docker Build') {
            when {
                expression { return sh(script: 'command -v docker', returnStatus: true) == 0 }
            }
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest ."
            }
        }
    }

    post {
        success { echo "Build OK -> image ${IMAGE_NAME}:${IMAGE_TAG}" }
        failure { echo 'Build FAILED - check the console output' }
    }
}
