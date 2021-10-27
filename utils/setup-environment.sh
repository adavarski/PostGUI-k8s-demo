#!/bin/bash

# Install jenkins
sudo apt update
sudo apt install -y openjdk-11-jre-headless
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install -y jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

#Install docker
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
sudo apt-cache policy docker-ce
sudo apt install -y docker-ce
sudo usermod -aG docker jenkins
sudo usermod -aG docker $USER
sudo systemctl enable docker
sudo systemctl start docker

#Install pkgs for (for J.docker pipeline plugin)
sudo apt install -y gnupg2 pass

#Install k3s
curl -sfL https://get.k3s.io | sh -

#Install kubectl
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl && sudo cp kubectl /usr/local/bin/ && rm kubectl

#Install Helm 
# Install Prerequisites:Helm needed by operator-sdk for Helm-based Operators 
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install -y helm 

#Configure kubectl & Helm 
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/
sudo chmod 644 ~/.kube/k3s.yaml
export KUBECONFIG=~/.kube/k3s.yaml

#Configure kubectl& Helm  for jenkins
sudo cp /etc/rancher/k3s/k3s.yaml ~jenkins/.kube/k3s.yaml
sudo chmod 644 ~jenkins/.kube/k3s.yaml

#Install kompose for docker-compose to k8s convert
curl -L https://github.com/kubernetes/kompose/releases/download/v1.24.0/kompose-linux-amd64 -o kompose
chmod +x kompose
sudo mv kompose /usr/local/bin


