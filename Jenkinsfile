pipeline {
    agent {
        kubernetes {
            yamlFile 'k8s-pod.yaml'
            defaultContainer 'python'
        }
    }
    options {
        skipStagesAfterUnstable()
    }
    stages {
        stage("Build") {
            steps {
                sh 'python -m py_compile sources/add2vals.py sources/calc.py' 
                stash(name: 'compiled-results', includes: 'sources/*.py*') 
            }
        }
        stage('Test') {
            steps {
                sh 'pytest --junit-xml test-reports/results.xml sources/test_calc.py'
            }
            post {
                always {
                    junit 'test-reports/results.xml'
                }
            }
        }
        stage('SonarQube analysis') {
            environment {
                SCANNER_HOME = tool 'sonar-scanner-7.1'
            }
            steps {
                withSonarQubeEnv('sonarqube-server') { 
                    sh '''$SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectKey=simple-python-pyinstaller-app \
                        -Dsonar.sources=src/ \
                        -Dsonar.junit.reportPaths=test-reports/results.xml \
                        -Dsonar.python.coverage.reportPaths=coverage.xml
                    '''
                }
            }
        }
        // stage("Quality Gate") {
        //     steps {
        //         timeout(time: 1, unit: 'HOURS') {
        //             // Parameter indicates whether to set pipeline to UNSTABLE if Quality Gate fails
        //             // true = set pipeline to UNSTABLE, false = don't
        //             waitForQualityGate abortPipeline: true
        //         }
        //     }
        // }
        stage('Deliver') {
            steps {
                sh 'pyinstaller --onefile sources/add2vals.py'
            }
            post {
                success {
                    archiveArtifacts 'dist/add2vals*'
                }
            }
        }
    }
}
