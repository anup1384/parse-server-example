#!/usr/bin/env groovy
properties([
	parameters([
        string(defaultValue: "master", description: 'Which Git Branch to clone?', name: 'GIT_BRANCH'),
        string(defaultValue: "parseapp", description: 'Namespace for setup application', name: 'NAMESPACE'),
        string(defaultValue: "1", description: 'pod count', name: 'replicacount'),
        string(defaultValue: "anup1384", description: 'Environment name', name: 'GIT_ORG'),
        string(defaultValue: "parse-server-example", description: 'Which Git Repo to clone?', name: 'GIT_APP_REPO'),
        string(defaultValue: "anuphnu", description: 'Docker registry account name?', name: 'REGISTRY'),
        choice(name: 'action', choices: "build", description: 'choose for build and rollback')
	])
])

registry = "${REGISTRY}/parse-server-example"
registryCredential = "anuphnu-dockerregistry"

node('master'){
stage('Clone Repo'){
      cleanWs()
      checkout([$class: 'GitSCM', branches: [[name: '*/$GIT_BRANCH']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'git@github.com:$GIT_ORG/$GIT_APP_REPO.git']]])
  }
  
  stage('Build Docker Image') {
    GIT_COMMIT_ID = sh (
        script: 'git log -1 --pretty=%H',
        returnStdout: true
      ).trim()
      TIMESTAMP = sh (
        script: 'date +%Y%m%d%H%M%S',
        returnStdout: true
      ).trim()
      echo "Git commit id: ${GIT_COMMIT_ID}"
      IMAGETAG="${GIT_COMMIT_ID}-${TIMESTAMP}"
      finalImage = docker.build("${registry}:${IMAGETAG}",'-f ./infra/docker/Dockerfile .')
  }
 
 stage ('Push to Registry') {
          withEnv(['DOCKER_CONTENT_TRUST=1','DOCKER_CONTENT_TRUST_ROOT_PASSPHRASE=$DOCKER_CONTENT_TRUST_ROOT_PASSPHRASE','DOCKER_CONTENT_TRUST_REPOSITORY_PASSPHRASE=$DOCKER_CONTENT_TRUST_REPOSITORY_PASSPHRASE']){
          docker.withRegistry('',registryCredential) {
            finalImage.push()
          }
}

}

  stage('Remove Pushed Image form Local') {
    sh "docker rmi -f ${registry}:${IMAGETAG} "
  }

stage('helm list') {
    sh "helm ls"
}

stage('Deployment') {
    sh "helm upgrade --install --atomic --wait --timeout 300 mongo ./infra/helm/mongo-db/ --namespace ${NAMESPACE}"
    sh "helm upgrade --install --atomic --wait --timeout 300 parse-server ./infra/helm/parse-server/ --set image.tag=${IMAGETAG},replicaCount=${replicacount},image.repository=${registry}  --namespace ${NAMESPACE}"
}

stage('Image Rollout'){
    sh ("kubectl rollout status deployment/parse-server -n ${NAMESPACE}")
}

}
