def pipeline() {
    /**
     * Workflow
     */
    stage('Base') {
        utils.createBuildStep('base', null, publish)()
    }

    stage('PhpTest') {
        utils.createBuildStep('php-test', null, publish)()
    }

    stage('Magento2 env') {
        utils.createBuildStep('magento2-env', null, publish)()
    }

    // Run parallel steps
    parallel(magentoVersions.collectEntries {
        ["Magento ${it}" : utils.createBuildStep('magento', it, publish)]
    } + magento2Versions.collectEntries {
        ["Magento ${it}" : utils.createBuildStep('magento2', it, publish)]
    })
}

return this
