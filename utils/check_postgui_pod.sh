#!/bin/bash
export KUBECONFIG=~/.kube/k3s.yaml
for ip in {1..5};

do
# check for open ports #
pod=`kubectl get po|awk '{print $1}'|grep postgui`
podTest=`kubectl logs $pod |grep "Compiled successfully!"`

sleep 5
    if [ $? -eq 0 ]
    then
        (( count ++ ))
    fi
done
    if [ $count == 5 ]
    then
        echo "Successfully started" 
    else
        echo "Failed to start"
    fi
