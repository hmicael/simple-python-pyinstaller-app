pipeline {
    agent {
        dockerfile {
            filename 'Dockerfile'
            dir 'python-agent'
        }
    }

    stages {
        stage('Build') {
            steps {
                sh 'python -m py_compile sources/add2vals.py sources/calc.py'
            }
        }

        stage('Test') {
            steps {
                sh '''
                pytest \
                --junit-xml=test-reports/results.xml \
                sources/test_calc.py
                '''
            }
            post {
                always {
                    junit 'test-reports/results.xml'
                }
            }
        }

        stage('Sonarqub Analysis') {
            agent {
                docker { image 'sonarsource/sonar-scanner-cli:latest' }
            }
            steps {
                withSonarQubeEnv('sonarqube-server') {// If you have configured more than one global server connection, you can specify its name as configured in Jenkins
                    sh 'echo "hello world'
                }
            }
        }

        
    }
}