#!/usr/bin/env bash
set -e

#ingress_ip=$(kubectl get ingress -n dev | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
#printf $(ingress_ip)

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=$1"
#openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=$ingress_ip" && \
kubectl delete secret ui-ingress -n dev || true && \
kubectl create secret tls ui-ingress --key tls.key --cert tls.crt -n dev && \
rm -f tls.*
