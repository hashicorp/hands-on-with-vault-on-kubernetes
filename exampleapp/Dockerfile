FROM alpine:3.7
MAINTAINER Anubhav Mishra <mishra@hashicorp.com>

ENV VAULT_VERSION=1.1.3

RUN apk add --no-cache ca-certificates gnupg curl git unzip bash openssh libcap openssl

RUN curl -LOks https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip && \
    unzip vault_${VAULT_VERSION}_linux_amd64.zip -d /tmp/vault_${VAULT_VERSION} && \
    mv /tmp/vault_${VAULT_VERSION}/vault /usr/local/bin/vault && \
    rm vault_${VAULT_VERSION}_linux_amd64.zip

ADD build/linux/amd64/exampleapp /usr/bin/exampleapp
ENTRYPOINT ["exampleapp"]
