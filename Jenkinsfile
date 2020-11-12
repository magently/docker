node('docker') {
    stage('Init') {
        deleteDir()
        checkout scm
    }

    publish = false
    utils = load 'dev/jenkins/utils.groovy'
    pipeline = load 'dev/jenkins/build.groovy'
}

pipeline.pipeline()
