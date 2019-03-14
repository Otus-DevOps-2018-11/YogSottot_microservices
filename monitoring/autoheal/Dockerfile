ARG OPENSHIFT_VERSION=v4.0.0 
FROM openshift/origin-base:"$OPENSHIFT_VERSION" as builder

ARG AUTOHEAL_VERSION=4.1.0-2019.03.13.07.53

WORKDIR /autoheal
#yum groupinstall "Development Tools" -y
RUN yum install git go make rpm-build createrepo -y && \ 
    git clone --branch openshift-enterprise-autoheal-"$AUTOHEAL_VERSION" https://github.com/openshift/autoheal/ . && \
    make build-rpms

ARG OPENSHIFT_VERSION=v4.0.0
FROM openshift/origin-base:"$OPENSHIFT_VERSION"

COPY --from=builder /autoheal/_output/local/releases/rpms/openshift-autoheal-*.x86_64.rpm /tmp/

RUN \
yum install -y /tmp/openshift-autoheal-*.x86_64.rpm && \
yum clean all && \
rm -rf /tmp/openshift-autoheal-*.x86_64.rpm && \
rm -rf /var/lib/yum/

LABEL \
io.k8s.display-name="OpenShift Autoheal" \
io.k8s.description="OpenShift Autoheal" \
io.openshift.tags="openshift"

#RUN useradd --no-create-home autoheal
RUN useradd --no-create-home autoheal
COPY autoheal.yml /home/autoheal/autoheal.yml
USER autoheal
EXPOSE 9099

ENTRYPOINT [ "/usr/bin/autoheal" ]
#CMD [ "server --config-file=/home/autoheal/autoheal.yml --logtostderr" ]
