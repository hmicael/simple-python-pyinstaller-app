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

        
    }
}