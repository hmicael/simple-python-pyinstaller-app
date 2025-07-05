pipeline {
    agent {
        kubernetes {
            yamlFile 'k8s-pod.yaml'
            defaultContainer 'python'
        }
    }
    stages {
        stage("Build) {
            steps {
                sh 'python -m py_compile sources/add2vals.py sources/calc.py' 
                stash(name: 'compiled-results', includes: 'sources/*.py*') 
            }
        }
    }
}
