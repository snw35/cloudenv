# Cloud environment container
# Provides a suite of cloud tools for AWS, GCP and Kubernetes

FROM alpine:3.10

WORKDIR /usr/bin/

# Install base deps and pip modules
RUN apk --update --no-cache add \
    bash \
    bash-completion \
    bind-tools \
    ca-certificates \
    coreutils \
    curl \
    diffutils \
    fzf \
    fzf-bash-completion \
    git \
    groff \
    iputils \
    libusb \
    ncurses \
    net-tools \
    nmap \
    openssh-client \
    py2-pip \
    python2 \
    python3 \
    shadow \
    su-exec \
    tzdata \
    gnupg \
    fish \
  && apk upgrade -a \
  && pip install --no-cache-dir --upgrade pip \
  && pip install --no-cache-dir --upgrade \
    awscli \
    ecs-compose \
  && pip3 install --no-cache-dir --upgrade pip \
  && pip3 install --no-cache-dir --upgrade \
    container-transform \
    awsebcli \
    okta-awscli \
  && curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest \
  && chmod +x /usr/local/bin/ecs-cli \
  && sed -i 's/^CREATE_MAIL_SPOOL=yes/CREATE_MAIL_SPOOL=no/' /etc/default/useradd \
  && mkdir -p /etc/bash_completion.d


# Install KUBECTL
# From https://storage.googleapis.com/kubernetes-release/release/stable.txt
# curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
ENV KUBECTL_VERSION 1.15.1
ENV KUBECTL_URL https://storage.googleapis.com/kubernetes-release/release/v$KUBECTL_VERSION/bin/linux/amd64
ENV KUBECTL_FILENAME kubectl
ENV KUBECTL_SHA256 f4f4b855ab16ef295bc74f07edc77482d43e8fe81abc7cf92c476c4344788aa6

RUN wget $KUBECTL_URL/$KUBECTL_FILENAME \
  && echo "$KUBECTL_SHA256  ./$KUBECTL_FILENAME" | sha256sum -c - \
  && chmod +x ./$KUBECTL_FILENAME \
  && kubectl completion bash > /etc/bash_completion.d/kubectl


# Install HELM
# From https://github.com/helm/helm/releases
ENV HELM_VERSION 2.14.2
ENV HELM_URL https://storage.googleapis.com/kubernetes-helm
ENV HELM_FILENAME helm-v${HELM_VERSION}-linux-amd64.tar.gz
ENV HELM_SHA256 9f50e69cf5cfa7268b28686728ad0227507a169e52bf59c99ada872ddd9679f0

RUN wget $HELM_URL/$HELM_FILENAME \
  && echo "$HELM_SHA256  ./$HELM_FILENAME" | sha256sum -c - \
  && tar -xzf $HELM_FILENAME \
  && mv ./linux-amd64/helm ./ \
  && rm -rf ./linux-amd64 \
  && rm -f $HELM_FILENAME \
  && chmod +x ./helm \
  && helm completion bash > /etc/bash_completion.d/helm


# Install terraform 11 as default and do not upgrade
# From https://www.terraform.io/downloads.html
ENV TERRAFORM_OLD_UPGRADE false
ENV TERRAFORM_OLD_VERSION 0.11.14
ENV TERRAFORM_OLD_URL https://releases.hashicorp.com/terraform/$TERRAFORM_OLD_VERSION
ENV TERRAFORM_OLD_FILENAME terraform_${TERRAFORM_OLD_VERSION}_linux_amd64.zip
ENV TERRAFORM_OLD_SHA256 9b9a4492738c69077b079e595f5b2a9ef1bc4e8fb5596610f69a6f322a8af8dd

RUN wget $TERRAFORM_OLD_URL/$TERRAFORM_OLD_FILENAME \
  && echo "$TERRAFORM_OLD_SHA256  ./$TERRAFORM_OLD_FILENAME" | sha256sum -c - \
  && unzip ./$TERRAFORM_OLD_FILENAME \
  && rm ./$TERRAFORM_OLD_FILENAME \
  && chmod +x ./terraform

# Install terraform 12
# From https://www.terraform.io/downloads.html
ENV TERRAFORM_NEW_VERSION 0.12.5
ENV TERRAFORM_NEW_URL https://releases.hashicorp.com/terraform/$TERRAFORM_NEW_VERSION
ENV TERRAFORM_NEW_FILENAME terraform_${TERRAFORM_NEW_VERSION}_linux_amd64.zip
ENV TERRAFORM_NEW_SHA256 babb4a30b399fb6fc87a6aa7435371721310c2e2102a95a763ef2c979ab06ce2

RUN wget $TERRAFORM_NEW_URL/$TERRAFORM_NEW_FILENAME \
  && echo "$TERRAFORM_NEW_SHA256  ./$TERRAFORM_NEW_FILENAME" | sha256sum -c - \
  && mkdir tf12 \
  && cd tf12 \
  && unzip ../$TERRAFORM_NEW_FILENAME \
  && mv ./terraform ../terraform12 \
  && cd .. \
  && rm -rf ./tf12 \
  && rm ./$TERRAFORM_NEW_FILENAME \
  && chmod +x ./terraform12


# Install terragrunt 18 as default and do not upgrade
# From https://github.com/gruntwork-io/terragrunt/releases
ENV TERRAGRUNT_OLD_UPGRADE false
ENV TERRAGRUNT_OLD_VERSION 0.18.7
ENV TERRAGRUNT_OLD_URL https://github.com/gruntwork-io/terragrunt/releases/download/v$TERRAGRUNT_OLD_VERSION
ENV TERRAGRUNT_OLD_FILENAME terragrunt_linux_amd64
ENV TERRAGRUNT_OLD_SHA256 3a45138e77fb41e0884b9491c67dcdeacd06418cd10a1e16ea0cc03976f1b288

RUN wget $TERRAGRUNT_OLD_URL/$TERRAGRUNT_OLD_FILENAME \
  && echo "$TERRAGRUNT_OLD_SHA256  ./$TERRAGRUNT_OLD_FILENAME" | sha256sum -c - \
  && mv ./$TERRAGRUNT_OLD_FILENAME ./terragrunt \
  && chmod +x ./terragrunt

# Install terragrunt 19
# From https://github.com/gruntwork-io/terragrunt/releases
ENV TERRAGRUNT_NEW_VERSION 0.19.9
ENV TERRAGRUNT_NEW_URL https://github.com/gruntwork-io/terragrunt/releases/download/v$TERRAGRUNT_NEW_VERSION
ENV TERRAGRUNT_NEW_FILENAME terragrunt_linux_amd64
ENV TERRAGRUNT_NEW_SHA256 9226cffc6b67b48c78e659b8ed1228e41b01c6fa4bd55e26e3b56c4d488db7ea

RUN wget $TERRAGRUNT_NEW_URL/$TERRAGRUNT_NEW_FILENAME \
  && echo "$TERRAGRUNT_NEW_SHA256  ./$TERRAGRUNT_NEW_FILENAME" | sha256sum -c - \
  && mv ./$TERRAGRUNT_NEW_FILENAME ./terragrunt19 \
  && chmod +x ./terragrunt19


# Install packer
# From https://www.packer.io/downloads.html
ENV PACKER_VERSION 1.4.2
ENV PACKER_URL https://releases.hashicorp.com/packer/$PACKER_VERSION
ENV PACKER_FILENAME packer_${PACKER_VERSION}_linux_amd64.zip
ENV PACKER_SHA256 2fcbd1662ac76dc4dec381bdc7b5e6316d5b9d48e0774a32fe6ef9ec19f47213

RUN wget $PACKER_URL/$PACKER_FILENAME \
  && echo "$PACKER_SHA256  ./$PACKER_FILENAME" | sha256sum -c - \
  && unzip ./$PACKER_FILENAME \
  && rm ./$PACKER_FILENAME \
  && chmod +x ./packer


# Install aws-iam-authenticator
# From https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
# https://github.com/kubernetes-sigs/aws-iam-authenticator/releases
ENV AWS_IAM_AUTH_VERSION 0.4.0
ENV AWS_IAM_AUTH_URL https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${AWS_IAM_AUTH_VERSION}
ENV AWS_IAM_AUTH_FILENAME aws-iam-authenticator_${AWS_IAM_AUTH_VERSION}_linux_amd64
ENV AWS_IAM_AUTH_SHA256 9744923781cca33dba3f48e1b8443af4d7f158748bd105134aaa68252da3b907

RUN wget $AWS_IAM_AUTH_URL/$AWS_IAM_AUTH_FILENAME \
  && echo "$AWS_IAM_AUTH_SHA256  ./$AWS_IAM_AUTH_FILENAME" | sha256sum -c - \
  && chmod +x ./${AWS_IAM_AUTH_FILENAME}


# Install Kubectx
# From https://github.com/ahmetb/kubectx/releases
ENV KUBECTX_VERSION 0.6.3
ENV KUBECTX_URL https://github.com/ahmetb/kubectx/archive
ENV KUBECTX_FILENAME v${KUBECTX_VERSION}.tar.gz
ENV KUBECTX_SHA256 f39eb7bc448f4444f4e3bfd1bb1258187615d51f1c4fa60d826b794b9ca70983

RUN wget $KUBECTX_URL/$KUBECTX_FILENAME \
  && echo "$KUBECTX_SHA256  ./$KUBECTX_FILENAME" | sha256sum -c - \
  && tar -xzf ./$KUBECTX_FILENAME \
  && rm ./$KUBECTX_FILENAME \
  && cp ./kubectx-${KUBECTX_VERSION}/completion/kubectx.bash /etc/bash_completion.d/kubectx \
  && cp ./kubectx-${KUBECTX_VERSION}/completion/kubens.bash /etc/bash_completion.d/kubens \
  && cp ./kubectx-${KUBECTX_VERSION}/kubectx . \
  && cp ./kubectx-${KUBECTX_VERSION}/kubens . \
  && rm -rf ./kubectx-${KUBECTX_VERSION} \
  && chmod +x ./kubectx \
  && chmod +x ./kubens


# Install Kops
# From https://github.com/kubernetes/kops/releases
ENV KOPS_VERSION 1.12.2
ENV KOPS_URL https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}
ENV KOPS_FILENAME kops-linux-amd64
ENV KOPS_SHA256 c71fa644741b4e831d417dfacd3bb4e513d8f320f1940de0a011b7dd3a9e4fcb

RUN wget $KOPS_URL/$KOPS_FILENAME \
  && echo "$KOPS_SHA256  ./$KOPS_FILENAME" | sha256sum -c - \
  && chmod +x ./${KOPS_FILENAME} \
  && mv ./${KOPS_FILENAME} ./kops \
  && kops completion bash > /etc/bash_completion.d/kops


# Install kompose
# From https://github.com/kubernetes/kompose/releases
ENV KOMPOSE_VERSION 1.18.0
ENV KOMPOSE_URL https://github.com/kubernetes/kompose/releases/download/v${KOMPOSE_VERSION}
ENV KOMPOSE_FILENAME kompose-linux-amd64
ENV KOMPOSE_SHA256 4675f1a580b2775d021f3d1777f060ffd44b5f540f956c3b68f092480af9caf4

RUN wget $KOMPOSE_URL/$KOMPOSE_FILENAME \
  && echo "$KOMPOSE_SHA256  ./$KOMPOSE_FILENAME" | sha256sum -c - \
  && chmod +x ./${KOMPOSE_FILENAME} \
  && mv ./${KOMPOSE_FILENAME} ./kompose


# Install k9s
# From https://github.com/derailed/k9s/releases
ENV K9S_VERSION 0.7.12
ENV K9S_URL https://github.com/derailed/k9s/releases/download/${K9S_VERSION}
ENV K9S_FILENAME k9s_${K9S_VERSION}_Linux_x86_64.tar.gz
ENV K9S_SHA256 0d4ef92c2da1aa73e8da60aeae1ae0004bcf42e5e1ed8d982ea0fca8b8633ebe

RUN wget $K9S_URL/$K9S_FILENAME \
  && echo "$K9S_SHA256  ./$K9S_FILENAME" | sha256sum -c - \
  && tar -xzf ./${K9S_FILENAME} \
  && chmod +x ./k9s \
  && rm -f LICENSE.txt \
  && rm -f README.md \
  && rm -f ./${K9S_FILENAME}


# Install fluxctl
# From https://github.com/fluxcd/flux/releases
ENV FLUXCTL_VERSION 1.13.2
ENV FLUXCTL_URL https://github.com/fluxcd/flux/releases/download/${FLUXCTL_VERSION}
ENV FLUXCTL_FILENAME fluxctl_linux_amd64
ENV FLUXCTL_SHA256 2d6262591e8409550acf95ee25ababa18c01fbaa2a9f94d9279e70197027d518

RUN wget $FLUXCTL_URL/$FLUXCTL_FILENAME \
  && echo "$FLUXCTL_SHA256  ./$FLUXCTL_FILENAME" | sha256sum -c - \
  && chmod +x ./${FLUXCTL_FILENAME} \
  && mv ./${FLUXCTL_FILENAME} ./fluxctl


WORKDIR /opt

# Install gcloud suite
# From https://cloud.google.com/sdk/docs/quickstart-linux
ENV GCLOUD_VERSION 254.0.0
ENV GCLOUD_URL https://dl.google.com/dl/cloudsdk/channels/rapid/downloads
ENV GCLOUD_FILENAME google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz
ENV GCLOUD_SHA256 1bb4752645889a0a6a420787d7ceb9cbaa59ae2f8f42fd2338f8c2ffdafec8ca

RUN wget $GCLOUD_URL/$GCLOUD_FILENAME \
  && echo "$GCLOUD_SHA256  ./$GCLOUD_FILENAME" | sha256sum -c - \
  && tar -xzf ./$GCLOUD_FILENAME \
  && rm ./$GCLOUD_FILENAME \
  && ./google-cloud-sdk/install.sh --quiet


COPY docker-entrypoint.sh /docker-entrypoint.sh

# Install go binaries
ENV GOROOT "/usr/lib/go"
RUN apk --update --no-cache add --virtual build.deps \
    build-base \
    go \
    libusb-dev \
    pkgconfig \
  && echo GOROOT=/usr/lib/go > /usr/lib/go/src/all.bash \
  && export CGO_ENABLED=0 \
  && go get github.com/fatih/hclfmt \
  && go get github.com/segmentio/terraform-docs \
  && go get github.com/kelseyhightower/confd \
  && export CGO_ENABLED=1 \
  && go get github.com/segmentio/aws-okta \
  && go clean -cache \
  && mv /root/go/bin/* /usr/bin/ \
  && apk del build.deps \
  && rm -rf /root/go/ \
  && rm -rf /root/.cache \
  && rm -rf /usr/lib/go/src/all.bash \
  && aws-okta completion bash > /etc/bash_completion.d/aws-okta \
  && echo "# Added at containter build-time" >> /etc/ssh/ssh_config \
  && echo "    Host *" >> /etc/ssh/ssh_config \
  && echo "ServerAliveInterval 30" >> /etc/ssh/ssh_config \
  && echo "ServerAliveCountMax 3" >> /etc/ssh/ssh_config \
  && chmod +x /docker-entrypoint.sh


COPY bashrc /etc/bashrc

ENV SSH_AUTH_SOCK /tmp/agent.sock

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["ssh-agent", "-d", "-s", "-a", "/tmp/agent.sock"]
