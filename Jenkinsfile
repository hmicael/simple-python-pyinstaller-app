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
                //stash(name: 'compiled-results', includes: 'sources/*.py*') 
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
                container('sonar') {
                    withSonarQubeEnv('sonarqube-server') { 
                        sh '''sonar-scanner \
                            -Dsonar.projectKey=simple-python-pyinstaller-app \
                            -Dsonar.sources=sources/ \
                            -Dsonar.junit.reportPaths=test-reports/results.xml \
                            -Dsonar.python.coverage.reportPaths=coverage.xml
                        '''
                    }
                }
            }
        }

        stage("Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    // Parameter indicates whether to set pipeline to UNSTABLE if Quality Gate fails
                    // true = set pipeline to UNSTABLE, false = don't
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Deliver') {
            steps {
                sh 'pyinstaller --onefile sources/add2vals.py'
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
                            credentialsId: 'nexus-login',
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

        stage('Build & Upload Image') {
            steps {
                container('docker') {
                    script {
                        // Si on utilise un registry privée
                        docker.withRegistry('https://registry.hub.docker.com', 'dockerhub') {
                            def imageName = "add2vals"
                            def registryOwner = "hmicael"
                            def imageTag = "${env.BUILD_ID}"
                            def img = docker.build("${registryOwner}/${imageName}")
                            img.push(imageTag)
                            img.push("latest")
                        }
                    }
                }
            }
        }
    }
}
