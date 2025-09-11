pipeline {
    agent none

    stages {
        stage('Build') {
            agent {
                dockerfile {
                    filename 'Dockerfile'
                    dir 'python-agent'
                }
            }
            steps {
                sh 'python -m py_compile sources/add2vals.py sources/calc.py'
            }
        }

        stage('Test') {
            agent {
                dockerfile {
                    filename 'Dockerfile'
                    dir 'python-agent'
                }
            }
            steps {
                sh '''
                pytest \
                --junit-xml=test-reports/results.xml \
                sources/test_calc.py
                '''
                sh '''
                pytest --cov=sources \
                --junit-xml=test-reports/coverage.xml
                '''
            }
            post {
                always {
                    junit 'test-reports/*'
                }
            }
        }

        stage('Sonarqub Analysis') {
            agent {
                docker { image 'sonarsource/sonar-scanner-cli:latest' }
            }
            steps {
                withSonarQubeEnv('sonarqube-server') {// If you have configured more than one global server connection, you can specify its name as configured in Jenkins
                    sh '''
                        export SONAR_USER_HOME=$WORKSPACE/.sonar
                        sonar-scanner \
                            -Dsonar.projectKey=simple-python-pyinstaller-app \
                            -Dsonar.sources=sources/ \
                            -Dsonar.junit.reportPaths=test-reports/results.xml \
                            -Dsonar.python.coverage.reportPaths=test-reports/coverage.xml
                    '''
                }
            }
        }

        stage("Quality Gate") {
            agent {
                docker { image 'sonarsource/sonar-scanner-cli:latest' }
            }
            steps {
                timeout(time: 1, unit: 'HOURS') {
                waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Deliver') {
            agent {
                dockerfile {
                    filename 'Dockerfile'
                    dir 'python-agent'
                }
            }
            steps {
                sh 'pyinstaller --onefile sources/add2vals.py' // créer un executable dist.add2vals
            }
            post {
                success {
                    script {
                        def projectName = "add2vals"

                        nexusArtifactUploader(
                            nexusVersion: 'nexus3',
                            protocol: 'http',
                            nexusUrl: '192.168.1.2:31251',
                            groupId: 'add2vals',
                            version: "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}",
                            repository: 'simple-python-pyinstaller-app',
                            credentialsId: 'nexus-repo-cred',
                            artifacts: [
                                [
                                    artifactId: projectName,
                                    classifier: '',
                                    file: "dist/${projectName}",
                                    type: 'bin'
                                ]
                            ]
                        )
                    }
                }
                failure {
                    echo 'La livraison a échoué. Aucun artefact ne sera publié.'
                }
                //always {
                //    archiveArtifacts artifacts: 'dist/add2vals*'
                //}
            }
        }

        stage("Build & Upload Docker image") {
            agent any
            // agent {
            //     docker {
            //         image 'docker:latest'
            //         args '--privileged -u root -v /var/run/docker.sock:/var/run/docker.sock'
            //     }
            // }
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-login') {
                        def imageName = "add2vals"
                        def registryOwner = "hmicael"
                        def imageTag = "${env.BUILD_NUMBER}"
                        def img = docker.build("${registryOwner}/${imageName}")
                        img.push(imageTag)
                        img.push("latest")
                    }
                }
            }
        }
    }
}