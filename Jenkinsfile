#!groovy

pipeline {
  agent none

  options {
    disableConcurrentBuilds()
  }

  stages {
    stage('Build Docker image') {
      agent any

      steps {
        script {
          def dockerRepoName = 'zooniverse/designator'
          def dockerImageName = "${dockerRepoName}:${GIT_COMMIT}"
          def buildArgs = "--build-arg REVISION="${GIT_COMMIT}" ."
          def newImage = docker.build(dockerImageName, buildArgs)

          if (BRANCH_NAME == 'master') {
            stage('Update latest tag') {
              newImage.push()
              newImage.push('latest')
            }
          }
        }
      }
    }

    stage('Deploy staging to Kubernetes') {
      when { branch 'master' }
      agent any
      steps {
        sh "sed 's/__IMAGE_TAG__/${GIT_COMMIT}/g' kubernetes/deployment-staging.tmpl | kubectl --context azure apply --record -f -"
      }
    }
  }

  post {
    success {
      script {
        if (BRANCH_NAME == 'master' || env.TAG_NAME == 'production-release') {
          slackSend (
            color: '#00FF00',
            message: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})",
            channel: "#ops"
          )
        }
      }
    }

    failure {
      script {
        if (BRANCH_NAME == 'master' || env.TAG_NAME == 'production-release') {
          slackSend (
            color: '#FF0000',
            message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})",
            channel: "#ops"
          )
        }
      }
    }
  }
}
