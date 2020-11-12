// Helper function for test steps creation
def createBuildStep(image, version = null, publish = false) {
    return {
        node('docker') {
            deleteDir()
            checkout scm

            // Fix umask issue
            sh 'find . -type f -exec chmod o+r {} \\; && find . -type d -exec chmod o+rx {} \\; && find . -type f -perm -u+x,g+x -exec chmod o+x {} \\;'

            def args = "${image}"

            if (version != null) {
                args = args + " ${version}"
            }

            if (publish == true) {
                args = '--publish ' + args

                withCredentials([
                    usernamePassword(credentialsId: "${DOCKER_ID}", passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')
                ]) {
                    sh 'docker login -u $DOCKER_USER -p $DOCKER_PASS'
                }
            }

            withCredentials([
                string(credentialsId: "${COMPOSER_ID}", variable: 'COMPOSER_AUTH')
            ]) {
                sh "scripts/build.sh ${args}"
            }
        }
    }
}

return this
