pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Base') {
            steps {
                sh './scripts/build.sh base'
            }
        }

        stage('Magento') {
            parallel {
                stage('Magento 1') {
                    steps {
                        sh './scripts/build.sh magento `scripts/versions.sh git://github.com/openmage/magento-mirror ${MAGENTO_BUILDS}`'
                    }
                }

                stage('Magento 2') {
                    steps {
                        sh './scripts/build.sh magento2-env'

                        withCredentials(
                            [
                                string(
                                    credentialsId: "${MAGENTO_KEY_ID}",
                                    variable: 'COMPOSER_AUTH'
                                )
                            ]
                        ) {
                            sh './scripts/build.sh magento2 `scripts/versions.sh git://github.com/magento/magento2 ${MAGENTO2_BUILDS}`'
                        }
                    }
                }
            }
        }
    }
}
