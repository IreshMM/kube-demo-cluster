#!/bin/bash -x

# Generate CA certificate and private key
cfssl gencert -initca ca-csr.json | cfssljson -bare ca

# Generate admin client certificate
cfssl gencert \
    -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=ca-config.json \
    -profile=kubernetes \
    admin-csr.json | cfssljson -bare admin

# Generate kubelet certificates
for instance in worker-{0..0}; do
    sed "s/INSTANCE/${instance}/" kubelet-csr.json >${instance}-csr.json.tmp

    EXTERNAL_IP=$(gcloud compute instances describe ${instance} \
        --format 'value(networkInterfaces[0].accessConfigs[0].natIP)')

    INTERNAL_IP=$(gcloud compute instances describe ${instance} \
        --format 'value(networkInterfaces[0].networkIP)')

    cfssl gencert \
        -ca=ca.pem \
        -ca-key=ca-key.pem \
        -config=ca-config.json \
        -hostname=${instance},${EXTERNAL_IP},${INTERNAL_IP} \
        -profile=kubernetes \
        ${instance}-csr.json.tmp | cfssljson -bare ${instance}
done

# Generate controller manager certificate
cfssl gencert \
    -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=ca-config.json \
    -profile=kubernetes \
    kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager

# Generate kube proxy certificate
cfssl gencert \
    -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=ca-config.json \
    -profile=kubernetes \
    kube-proxy-csr.json | cfssljson -bare kube-proxy

# Generate kube scheduler certificate
cfssl gencert \
    -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=ca-config.json \
    -profile=kubernetes \
    kube-scheduler-csr.json | cfssljson -bare kube-scheduler

# Generate kube API server certificate
KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kube-external-ip \
    --region $(gcloud config get-value compute/region) \
    --format 'value(address)')
KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local
cfssl gencert \
    -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=ca-config.json \
    -hostname=10.32.0.1,10.240.0.10,10.240.0.11,10.240.0.12,${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,${KUBERNETES_HOSTNAMES} \
    -profile=kubernetes \
    kube-api-server-csr.json | cfssljson -bare kubernetes

# Generate service account certificate (key pair)
cfssl gencert \
    -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=ca-config.json \
    -profile=kubernetes \
    kube-service-account-csr.json | cfssljson -bare service-account
