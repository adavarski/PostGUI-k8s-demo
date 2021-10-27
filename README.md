# k8s PostGUI app demo (containerize app, k8s deploy, CI/CD pipelines)

### Tasks:

1. Containerize the following App: https://github.com/priyank-purohit/PostGUI
2. Provide a Helm Chart/Templates that deploys the App above inside K8S cluster so it is in a fully working state with its required dependencies. 
3. Describe a way to automate the CI/CD process of all of the above  
(Optional for Bonus points)  => Developing a pipeline for automating all of the above in a tool of personal preference
4. BASH: 
Obtain the POD status (from 1) and check if it is “Running”. If so 5 times in a row with 5 seconds between each check print “Successfully started” , otherwise log a message “Failed to start”. 

## Playground:

### Prerequisite: 

Setup local development environment (install/setup all needed software)

```
./utils//setup-environment.sh
```
Note: For setting up Kubernetes local development environment, there are two recommended methods

- k3s
- minikube

k3s is 40MB binary that runs “a fully compliant production-grade Kubernetes distribution” and requires only 512MB of RAM. k3s is a great way to wrap applications that you may not want to run in a full production Cluster but would like to achieve greater uniformity in systems deployment, monitoring, and management across all development operations.  Of the two (k3s & minikube), k3s tends to be the most viable. It is closer to a production style deployment. 

### 1.Containerize PostGUI App:

Note:  App is a React web application to query and share any PostgreSQL database. App has been copied from  https://github.com/priyank-purohit/PostGUI repo into this repo folder [postgui-docker](https://github.com/adavarski/PostGUI-k8s-demo/tree/main/postgui-docker) for better demo project consolidation.

```
### To manually build PostGUI image (using DockerHub for this demo) :

$ git clone https://github.com/adavarski/PostGUI-k8s-demo
$ cd ./postgui-docker
$ docker build -t davarski/postgui:1.0 .
$ docker login 
$ docker push davarski/postgui:1.0

### To test PostGUI image
$ cd ../utils
$ docker-copmose up -d
$ docker-compose ps
  Name                 Command               State           Ports         
---------------------------------------------------------------------------
postgres    docker-entrypoint.sh postgres    Up      0.0.0.0:5432->5432/tcp
postgrest   /bin/postgrest                   Up      0.0.0.0:3000->3000/tcp
postgui     docker-entrypoint.sh npm start   Up      0.0.0.0:8771->8771/tcp

### Check Browser : http://localhost:8771

### Clean environment
$ docker-compose down

### Convert docker-compose to k8s manifests and test k8s manifests :

$ ./kompose convert
INFO Kubernetes file "postgres-service.yaml" created 
INFO Kubernetes file "postgrest-service.yaml" created 
INFO Kubernetes file "postgui-service.yaml" created 
INFO Kubernetes file "postgres-deployment.yaml" created 
INFO Kubernetes file "postgrest-deployment.yaml" created 
INFO Kubernetes file "postgui-deployment.yaml" created 

$ cd ./k8s/k8s-manifests
$ kubectl apply -f . 
deployment.apps/postgres created
service/postgres created
deployment.apps/postgrest created
service/postgrest created
deployment.apps/postgui created
service/postgui created

$ kubectl delete -f . 
```

Note: This demo repo is just a PoC for local use only, and will not use k8s StatefulSets/k8s Operators for k8s workloads (Postgre DB, etc.). For production we have to use k8s StatefulSets/k8s Operators (for Postgre DB, etc.).

### 2. Provide a Helm Chart/Templates that deploys the App above inside K8S cluster so it is in a fully working state with its required dependencies. 

Create [Helm Chart](https://github.com/adavarski/PostGUI-k8s-demo/tree/main/k8s/helm/postgui)
```
$ helm create postgui

### Edit Chart.yaml, values.yaml and templates files and test helm chart 

$ cd ./k8s/k8s-manifests
$ kubectl apply -f postgres-deployment.yaml -f postgres-service.yaml -f postgrest-deployment.yaml -f postgrest-service.yaml
$ cd ./k8s/helm
$ helm upgrade --install postgui postgui
$ helm list
$ helm delete postgui
```

### 3. Describe a way to automate the CI/CD process of all of the above  

(Optional for Bonus points)  => Developing a pipeline for automating all of the above in a tool of personal preference

Note: Using Jenkins pipelines:

Example J.pipelines:
<img src="https://github.com/adavarski/PostGUI-k8s-demo/blob/main/pictures/PostGUI-pipelines-examples.png" width="900">

[Example J.pipeline: Jenkinsfile-PostGUI-docker-build-k8s-deploy-via-helm](https://github.com/adavarski/PostGUI-k8s-demo/blob/main/jenkins/Jenkinsfile-PostGUI-docker-build-k8s-deploy-via-helm)

[Example J.pipeline PostGUI-docker-build-k8s-deploy-via-helm J.console output](https://github.com/adavarski/PostGUI-k8s-demo/blob/main/jenkins/J.console-logs/J.PostGUI-docker-build-k8s-deploy-via-helm-consoleText.txt)

Example J.pipeline -> J.UI:

<img src="https://github.com/adavarski/PostGUI-k8s-demo/blob/main/pictures/PostGUI-docker-build-k8s-deploy-via-helm.png" width="900">

```
### Check k8s workloads

$ kubectl get po
NAME                         READY   STATUS    RESTARTS   AGE
postgres-5b467dbcf4-xbtsk    1/1     Running   0          2m50s
postgrest-79bc954b76-r5j6l   1/1     Running   0          2m50s
postgui-95786c9b9-wsfkn      1/1     Running   0          2m48s

$ kubectl get all
NAME                             READY   STATUS    RESTARTS   AGE
pod/postgres-5b467dbcf4-xbtsk    1/1     Running   0          2m57s
pod/postgrest-79bc954b76-r5j6l   1/1     Running   0          2m57s
pod/postgui-95786c9b9-wsfkn      1/1     Running   0          2m55s

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
service/kubernetes   ClusterIP   10.43.0.1      <none>        443/TCP    6h49m
service/postgres     ClusterIP   10.43.86.70    <none>        5432/TCP   2m57s
service/postgrest    ClusterIP   10.43.80.125   <none>        3000/TCP   2m57s
service/postgui      ClusterIP   10.43.123.40   <none>        8771/TCP   2m55s

NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/postgres    1/1     1            1           2m57s
deployment.apps/postgrest   1/1     1            1           2m57s
deployment.apps/postgui     1/1     1            1           2m55s

NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/postgres-5b467dbcf4    1         1         1       2m57s
replicaset.apps/postgrest-79bc954b76   1         1         1       2m57s
replicaset.apps/postgui-95786c9b9      1         1         1       2m55s

$ helm list
NAME   	NAMESPACE	REVISION	UPDATED                                 	STATUS  	CHART    	APP VERSION
postgui	default  	1       	2021-10-27 10:44:24.417436927 +0300 EEST	deployed	postgui-1	1.0  

### To access PostGUI via browser for testing: 
$ kubectl --namespace default port-forward postgui-95786c9b9-wsfkn 8771:8771
Forwarding from 127.0.0.1:8771 -> 8771
Forwarding from [::1]:8771 -> 8771
Handling connection for 8771

```
Check PostGUI: Browser: http://localhost:8771

<img src="https://github.com/adavarski/PostGUI-k8s-demo/blob/main/pictures/postgregui-UI.png" width="700">

### 4. BASH: 

Obtain the POD status (from 1) and check if it is “Running”. If so 5 times in a row with 5 seconds between each check print “Successfully started” , otherwise log a message “Failed to start”. 

```
$ ./utils/check_postgui_pod.sh
Successfully started
```
