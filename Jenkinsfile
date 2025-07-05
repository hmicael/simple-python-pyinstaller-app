pipeline {
    agent {
        kubernetes {
            label 'python-agent'
            yamlFile 'k8s-pod.yaml'
            defaultContainer 'python'
        }
    }
    stages {
        stage("A") {
            steps {
                echo "========executing A========"
            }
            post {
                always {
                    echo "========always========"
                }
                success {
                    echo "========A executed successfully========"
                }
                failure {
                    echo "========A execution failed========"
                }
            }
        }
    }
    post {
        always {
            echo "========always========"
        }
        success {
            echo "========pipeline executed successfully========"
        }
        failure {
            echo "========pipeline execution failed========"
        }
    }
}
