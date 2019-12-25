# parse-server-example

Deploying parse-server nodejs app on on kubernetes cluster step by step.

### For Local setup on mac k8s

# Prerequisites

* An existing Kubernetes cluster is up and running.
* Helm setup and chart
* jenkins- for build and deployment
* Docker registry hub, you can use any other registry like, ECR, GCR.


I’m using local mac k8s to setup & deploy parse-server app, but you may use any other provider or infrastructure.
This repository has a Dockerfile,Jenkinsfile (pipeline script to build,deploy app on k8s using helm chart) and a helm chart for deploying parse-server on Kubernetes.

### Steps

# 1. Install and Enable helm in your cluster:

```
# Download helm package and unpack it
$ wget https://get.helm.sh/helm-v3.0.0-rc.2-linux-amd64.tar.gz
$ tar zxfv helm-v3.0.0-rc.2-linux-amd64.tar.gz
$ cp linux-amd64/helm /usr/local/bin/helm
# Create The Tiller Service Account and rbac permission
$ kubectl -n kube-system create serviceaccount tiller
$ kubectl create clusterrolebinding tiller \
  --clusterrole cluster-admin \
  --serviceaccount=kube-system:tiller
# Init helm and tiller on your cluster
$ helm init --service-account tiller --upgrade
```

# 2. Configure Dockerfile & Jenkinsfile

* Configure Dockerfile to build app.
* Configure Jenkinsfile pipeline and update parametes variables for build,deploy app on k8s using helm chart.
* Add credential of docker hub registry (Go to Credentials > System > Global credentials and click on Add Credentials:) and     update your Jenkinsfile.

# 3. Build and Deploy Application.
#### Without Jenkinsfile (Manual steps)
```
# Build Image
$ docker build -t anuphnu/parse-server-example -f ./infra/docker/Dockerfile .
# Push Image to hub
$ docker push anuphnu/parse-server-example
# Deploy application dependency mongo db using helm chart
$ helm upgrade --install mongo ./infra/helm/mongo-db --namespace parseapp
# Deploy parse-server app
$ helm upgrade --install parse-server ./infra/helm/parse-server/ --set image.tag=latest,replicaCount=1,image.repository=anuphnu/parse-server-example  --namespace parseap
```
#### With Jenkinsfile

```
* Create new jenkins pipeline job and in pipeline section choose "Pipeline script from SCM" and provide bitbucket repo       details and pipeline scipt file name with path.
* Run pipeline job build with parameter.
```

# 4. Test and verify deployed app

Before using it, you can access a test page to verify if the basic setup is working fine [http://localhost/test](http://localhost:1337/test).
Then you can use the REST API, the JavaScript SDK, and any of our open-source SDKs:

Example request to a server running locally:

```curl
curl -X POST \
  -H "X-Parse-Application-Id: app_id_starter" \
  -H "Content-Type: application/json" \
  -d '{"score":1337,"playerName":"Sean Plott","cheatMode":false}' \
  http://localhost/parse/classes/GameScore
  
curl -X POST \
  -H "X-Parse-Application-Id: app_id_starter" \
  -H "Content-Type: application/json" \
  -d '{}' \
  http://localhost/parse/functions/hello
```
