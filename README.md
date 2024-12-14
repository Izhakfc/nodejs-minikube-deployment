# Node.js App Deployment to Minikube with GitHub Actions  

This repository demonstrates how to deploy a Node.js application to a local Kubernetes cluster running on **Minikube**, using **GitHub Actions**. The project is designed for testing and development purposes, helping you automate deployments and validate your app before pushing to a production environment.  

---

## Features  
- **Minikube Integration**: Run a local Kubernetes cluster for testing.  
- **CI/CD with GitHub Actions**: Automate the deployment of your Node.js app to the cluster.  
- **Lightweight and Easy to Use**: A simple Node.js app to help you focus on Kubernetes workflows.  

---

## Prerequisites  

Before you begin, ensure you have the following tools installed locally:  

- [Docker](https://www.docker.com/products/docker-desktop) or a compatible container runtime  
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)  
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)  

---
## Step-by-Step Walkthrough

### Step 1: Setting Up the Node.js App

The first step was to create the necessary files for the Node.js app:

#### Dockerfile
The `Dockerfile` specifies how to build a Docker image for the Node.js application:
```dockerfile
FROM node:14
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
RUN npm install express
COPY . .
EXPOSE 3000
CMD [ "node", "server.js" ]´
```
#### package.json
The package.json file specifies the dependencies and scripts for the Node.js app:
```
{
  "name": "docker_web_app",
  "version": "1.0.0",
  "description": "Node.js on Docker",
  "author": "First Last <first.last@example.com>",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.16.1"
  }
}
```
#### server.js
The server.js file contains the code to start the Node.js application and serve requests:
```
'use strict';

const express = require('express');

// Constants
const PORT = 3000;
const HOST = '0.0.0.0';

// App
const app = express();
app.get('/', (req, res) => {
  res.send('Hello World');
});

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);
```
### Step 2: Kubernetes Deployment (k8s-node-app.yaml)
Next, we created the Kubernetes deployment configuration file, k8s-node-app.yaml:
```
kind: Deployment
apiVersion: apps/v1
metadata:
  name: nodejs-app
  namespace: default
  labels:
    app: nodejs-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nodejs-app
  template:
    metadata:
      labels:
        app: nodejs-app
    spec:
      containers:
      - name: nodejs-app
        image: "devopshint/node-app:latest"
        ports:
          - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: nodejs-app
  namespace: default
spec:
  selector:
    app: nodejs-app
  type: NodePort
  ports:
  - name: http
    targetPort: 3000
    port: 80
```
This file defines both the deployment and service for the Node.js app. The service type NodePort makes the app accessible outside the Kubernetes cluster.

### Step 3: Setting Up GitHub Actions Workflow
We created the GitHub Actions workflow to automate the deployment process. This file was stored in .github/workflows/deploy-to-minikube-github-actions.yaml:
```
name: Deploy to Minikube using GitHub Actions

on: 
  push:
    branches:
      - main  

jobs:
  job1:
    runs-on: ubuntu-latest
    name: Build Node.js Docker Image and Deploy to Minikube
    steps:
    - uses: actions/checkout@v2

    - name: Start minikube
      uses: medyagh/setup-minikube@master

    - name: Verify cluster initialization
      run: kubectl get pods -A

    - name: Build image
      run: |
          export SHELL=/bin/bash
          eval $(minikube -p minikube docker-env)
          docker build -f ./Dockerfile -t devopshint/node-app:latest .
          echo -n "Verifying images:"
          docker images         

    - name: Deploy to Minikube
      run:
        kubectl apply -f k8s-node-app.yaml

    - name: Wait for Minikube to stabilize
      run: sleep 100  # Allow time for Minikube to start the pods

    - name: Check pod status
      run: kubectl get pods  # Shows the status of the pods

    - name: Describe pod
      run: kubectl describe pod nodejs-app  # Debug issues with the pod

    - name: Test service URLs
      run: |
          minikube service list
          minikube service nodejs-app --url  # Gives you the URL to access the service
```
#### Explanation of the Additions:
### Verify Cluster Initialization:
The first addition was to verify that the Minikube cluster is running correctly by checking the pods. The command kubectl get pods -A lists all the pods across namespaces, which helps ensure that the Kubernetes cluster is properly initialized and that no pods are stuck in an error state before deploying the application.

### Wait for Minikube to Stabilize:
We introduced a sleep delay of 100 seconds to give Minikube time to start the pods and stabilize the cluster before checking the pod status. Without this delay, the deployment may be too fast, and the pods may not be fully initialized by the time we check their status, potentially causing errors.

### Check Pod Status:
After waiting for Minikube to stabilize, we use the command kubectl get pods to check the status of the pods in the cluster. This confirms whether the Node.js app pod is running and healthy.

### Describe Pod:
To help debug any issues with the pods, we use kubectl describe pod nodejs-app. This provides detailed information about the pod, including events, logs, and reasons for any errors that might have occurred during deployment.

### Step 4: Testing the Deployment
Once the workflow was completed, I tested the deployment by checking the service URL with the minikube service nodejs-app --url command. The service was successfully deployed, and I could access it via the URL provided by Minikube.

---
## 3. Evidence

---
## 4. Conclusion
In this lab, I successfully set up a continuous deployment pipeline using GitHub Actions to deploy a Node.js app to Minikube. This pipeline builds the Docker image, deploys it to Minikube, and verifies that the service is accessible. Through this lab, I have gained experience in automating deployments to a local Kubernetes cluster using GitHub Actions, and learned the importance of verifying the cluster state, waiting for stabilization, and checking pod statuses to ensure successful deployment.

---

## 5. GitHub Repository Link
You can access the GitHub repository where the code and configurations are stored:
https://github.com/Izhakfc/nodejs-minikube-deployment