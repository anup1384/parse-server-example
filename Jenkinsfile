#!/usr/bin/env groovy
properties([
	parameters([
        string(defaultValue: "test", description: 'Which Git Branch to clone?', name: 'GIT_BRANCH'),
        string(defaultValue: "1", description: 'pod count', name: 'replicacount'),
        string(defaultValue: "anup1384", description: 'Environment name', name: 'GIT_ORG'),
        string(defaultValue: "parse-server-example", description: 'Which Git Repo to clone?', name: 'GIT_APP_REPO'),
        string(defaultValue: "anuphnu", description: 'Docker registry account name?', name: 'REGISTRY'),
//        string(defaultValue: "digitalcst/nonprod/cst-consumer-bot", description: 'AWS ECR Repository where built docker images will be pushed.', name: 'ECR_REPO_NAME'),
        choice(name: 'action', choices: "build\nrollback", description: 'choose for build and rollback')
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
          docker.withRegistry('',registryCredential) {
            finalImage.push()
          }
      }

  stage('Remove Pushed Image form Local') {
    sh "docker rmi -f ${registry}:${IMAGETAG} "
  }

stage('helm list') {
    sh "helm ls"
}

stage('Deployment') {
    sh "helm upgrade --install --atomic --wait --timeout 120 mongo ./infra/helm/mongo-db/ --namespace atlantest"
    sh "helm upgrade --install --atomic --wait --timeout 120 parse-server ./infra/helm/parse-server/ --set image.tag=${IMAGETAG},replicaCount=${replicacount},image.repository=${registry}  --namespace atlantest"
}

stage('Image Rollout'){
    sh ("kubectl rollout status deployment/parse-server -n atlantest")
}

}
