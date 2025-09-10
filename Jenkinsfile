pipeline {
    agent any

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
            }
            post {
                always {
                    junit 'test-reports/results.xml'
                }
            }
        }

        

        stage('Deliver') {
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