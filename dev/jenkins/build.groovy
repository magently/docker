def pipeline() {
    stage('Base') {
        utils.createBuildStep('base', null, publish)()
    }

    stage('PhpTest') {
        utils.createBuildStep('php-test', null, publish)()
    }
}

return this
