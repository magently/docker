node {
    stage('Checkout') {
        checkout scm
    }

    stage('Build') {
        withCredentials(
            [
                string(
                    credentialsId: "${MAGENTO_KEY_ID}",
                    variable: 'COMPOSER_AUTH'
                )
            ]
        ) {
            sh './scripts/build.sh'
        }
    }
}
