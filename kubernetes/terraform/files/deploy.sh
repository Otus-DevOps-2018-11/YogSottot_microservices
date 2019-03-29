#!/usr/bin/env bash
set -e

kubectl apply -f ../reddit/dev-namespace.yml && \
kubectl apply -f ../reddit/comment-deployment.yml -n dev && \
kubectl apply -f ../reddit/comment-mongodb-service.yml -n dev && \
kubectl apply -f ../reddit/comment-service.yml -n dev && \
kubectl apply -f ../reddit/dashboard.yml -n dev && \
kubectl apply -f ../reddit/mongo-claim-dynamic.yml -n dev && \
kubectl apply -f ../reddit/mongo-deployment.yml -n dev && \
kubectl apply -f ../reddit/mongo-network-policy.yml -n dev && \
kubectl apply -f ../reddit/post-deployment.yml -n dev && \
kubectl apply -f ../reddit/post-mongodb-service.yml -n dev && \
kubectl apply -f ../reddit/post-service.yml -n dev && \
kubectl apply -f ../reddit/storage-fast.yml -n dev && \
kubectl apply -f ../reddit/ui-deployment.yml -n dev && \
kubectl apply -f ../reddit/ui-service.yml -n dev && \
kubectl apply -f ../reddit/ui-ingress.yml -n dev