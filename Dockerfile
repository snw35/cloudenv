# Cloud environment container
# Provides a complete suite of cloud tools suitable for GCP and AWS

FROM alpine:3.10

WORKDIR /usr/bin/

# Install base deps and pip modules
RUN apk --update --no-cache add \
    bash \
    bash-completion \
    python2 \
    python3 \
    ca-certificates \
    git \
    openssh-client \
    py2-pip \
    curl \
    libusb \
    groff \
    ncurses \
    fzf \
    fzf-bash-completion \
    net-tools \
    bind-tools \
    coreutils \
    diffutils \
    iputils \
    nmap \
    tzdata \
    shadow \
    su-exec \
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
  && adduser -s bash -D user \
  && mkdir -p /etc/bash_completion.d


# Install KUBECTL
# From https://storage.googleapis.com/kubernetes-release/release/stable.txt
# curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
ENV KUBECTL_VERSION 1.14.3
ENV KUBECTL_URL https://storage.googleapis.com/kubernetes-release/release/v$KUBECTL_VERSION/bin/linux/amd64
ENV KUBECTL_FILENAME kubectl
ENV KUBECTL_SHA256 ebc8c2fadede148c2db1b974f0f7f93f39f19c8278619893fd530e20e9bec98f

RUN wget $KUBECTL_URL/$KUBECTL_FILENAME \
  && echo "$KUBECTL_SHA256  ./$KUBECTL_FILENAME" | sha256sum -c - \
  && chmod +x ./$KUBECTL_FILENAME \
  && kubectl completion bash > /etc/bash_completion.d/kubectl


# Install HELM
# From https://github.com/helm/helm/releases
ENV HELM_VERSION 2.13.1
ENV HELM_URL https://storage.googleapis.com/kubernetes-helm
ENV HELM_FILENAME helm-v${HELM_VERSION}-linux-amd64.tar.gz
ENV HELM_SHA256 c1967c1dfcd6c921694b80ededdb9bd1beb27cb076864e58957b1568bc98925a

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
ENV TERRAFORM_NEW_VERSION 0.12.2
ENV TERRAFORM_NEW_URL https://releases.hashicorp.com/terraform/$TERRAFORM_NEW_VERSION
ENV TERRAFORM_NEW_FILENAME terraform_${TERRAFORM_NEW_VERSION}_linux_amd64.zip
ENV TERRAFORM_NEW_SHA256 d9a96b646420d7f0a80aa5d51bb7b2a125acead537ab13c635f76668de9b8e32

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
ENV TERRAGRUNT_NEW_VERSION 0.19.5
ENV TERRAGRUNT_NEW_URL https://github.com/gruntwork-io/terragrunt/releases/download/v$TERRAGRUNT_NEW_VERSION
ENV TERRAGRUNT_NEW_FILENAME terragrunt_linux_amd64
ENV TERRAGRUNT_NEW_SHA256 75ab74e726d3c3226a25361e204c2c6353197592438704034301e0526d48c5c1

RUN wget $TERRAGRUNT_NEW_URL/$TERRAGRUNT_NEW_FILENAME \
  && echo "$TERRAGRUNT_NEW_SHA256  ./$TERRAGRUNT_NEW_FILENAME" | sha256sum -c - \
  && mv ./$TERRAGRUNT_NEW_FILENAME ./terragrunt19 \
  && chmod +x ./terragrunt19


# Install packer
# From https://www.packer.io/downloads.html
ENV PACKER_VERSION 1.4.1
ENV PACKER_URL https://releases.hashicorp.com/packer/$PACKER_VERSION
ENV PACKER_FILENAME packer_${PACKER_VERSION}_linux_amd64.zip
ENV PACKER_SHA256 b713ea79a6fb131e27d65ec3f2227f36932540e71820288c3c5ad770b565ecd7

RUN wget $PACKER_URL/$PACKER_FILENAME \
  && echo "$PACKER_SHA256  ./$PACKER_FILENAME" | sha256sum -c - \
  && unzip ./$PACKER_FILENAME \
  && rm ./$PACKER_FILENAME \
  && chmod +x ./packer


# Install aws-iam-authenticator
# From https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
ENV AWS_IAM_AUTH_VERSION 1.12.7/2019-03-27
ENV AWS_IAM_AUTH_URL https://amazon-eks.s3-us-west-2.amazonaws.com/${AWS_IAM_AUTH_VERSION}/bin/linux/amd64
ENV AWS_IAM_AUTH_FILENAME aws-iam-authenticator
ENV AWS_IAM_AUTH_SHA256 cc35059999bad461d463141132a0e81906da6c23953ccdac59629bb532c49c83

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


WORKDIR /opt

# Install gcloud suite
# From https://cloud.google.com/sdk/docs/quickstart-linux
ENV GCLOUD_VERSION 250.0.0
ENV GCLOUD_URL https://dl.google.com/dl/cloudsdk/channels/rapid/downloads
ENV GCLOUD_FILENAME google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz
ENV GCLOUD_SHA256 fe59b988c6a8a40ae98a3b9d0ea98b98e55e5061e8cec14d71e93b7d198c133e

RUN wget $GCLOUD_URL/$GCLOUD_FILENAME \
  && echo "$GCLOUD_SHA256  ./$GCLOUD_FILENAME" | sha256sum -c - \
  && tar -xzf ./$GCLOUD_FILENAME \
  && rm ./$GCLOUD_FILENAME \
  && ./google-cloud-sdk/install.sh --quiet


COPY docker-entrypoint.sh /docker-entrypoint.sh

# Install go binaries
ENV GOROOT "/usr/lib/go"
RUN apk --update --no-cache add --virtual build.deps \
    go \
    build-base \
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


WORKDIR /home/user

COPY bashrc /etc/bashrc

VOLUME /home/user

ENV SSH_AUTH_SOCK /tmp/agent.sock

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["ssh-agent", "-d", "-s", "-a", "/tmp/agent.sock"]
