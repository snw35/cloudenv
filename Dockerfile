# Cloud environment container
# Provides a suite of cloud tools for AWS, GCP and Kubernetes

FROM alpine:3.10.3

WORKDIR /usr/bin/

# Install base deps and pip modules
RUN apk --update --no-cache upgrade -a \
  && apk --update --no-cache add \
    bash \
    bash-completion \
    bind-tools \
    ca-certificates \
    coreutils \
    curl \
    diffutils \
    fish \
    fzf \
    fzf-bash-completion \
    gcompat \
    git \
    gnupg \
    groff \
    iputils \
    keychain \
    libc6-compat \
    libusb \
    ncurses \
    net-tools \
    nmap \
    openssh-client \
    perl \
    py2-pip \
    python2 \
    python3 \
    shadow \
    su-exec \
    tzdata \
    jq \
    tmux \
  && pip install --no-cache-dir --upgrade pip \
  && pip install --no-cache-dir --upgrade \
    awscli \
    ecs-compose \
  && pip3 install --no-cache-dir --upgrade pip \
  && pip3 install --no-cache-dir --upgrade \
    container-transform \
    awsebcli \
    cookiecutter \
    okta-awscli \
  && curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest \
  && chmod +x /usr/local/bin/ecs-cli \
  && sed -i 's/^CREATE_MAIL_SPOOL=yes/CREATE_MAIL_SPOOL=no/' /etc/default/useradd \
  && mkdir -p /etc/bash_completion.d


# Install KUBECTL
# From https://storage.googleapis.com/kubernetes-release/release/stable.txt
# curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
ENV KUBECTL_VERSION 1.16.2
ENV KUBECTL_URL https://storage.googleapis.com/kubernetes-release/release/v$KUBECTL_VERSION/bin/linux/amd64
ENV KUBECTL_FILENAME kubectl
ENV KUBECTL_SHA256 3ff48e12f9c768ad548e4221d805281ea28dfcda5c18b3cd1797fe37aee3012e

RUN wget $KUBECTL_URL/$KUBECTL_FILENAME \
  && echo "$KUBECTL_SHA256  ./$KUBECTL_FILENAME" | sha256sum -c - \
  && chmod +x ./$KUBECTL_FILENAME \
  && kubectl completion bash > /etc/bash_completion.d/kubectl


# Install HELM
# From https://github.com/helm/helm/releases
ENV HELM_VERSION 2.15.2
ENV HELM_URL https://storage.googleapis.com/kubernetes-helm
ENV HELM_FILENAME helm-v${HELM_VERSION}-linux-amd64.tar.gz
ENV HELM_SHA256 a9d2db920bd4b3d824729bbe1ff3fa57ad27760487581af6e5d3156d1b3c2511

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
ENV TERRAFORM_NEW_VERSION 0.12.12
ENV TERRAFORM_NEW_URL https://releases.hashicorp.com/terraform/$TERRAFORM_NEW_VERSION
ENV TERRAFORM_NEW_FILENAME terraform_${TERRAFORM_NEW_VERSION}_linux_amd64.zip
ENV TERRAFORM_NEW_SHA256 67bc7a49c0946ad48b14cc6e95482fdd3e7e9f7dc6811f4ce6ff531fc565bd3a

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
ENV TERRAGRUNT_NEW_VERSION 0.21.1
ENV TERRAGRUNT_NEW_URL https://github.com/gruntwork-io/terragrunt/releases/download/v$TERRAGRUNT_NEW_VERSION
ENV TERRAGRUNT_NEW_FILENAME terragrunt_linux_amd64
ENV TERRAGRUNT_NEW_SHA256 34ca561f973319b20719d945f37f0e5ccc3c5ae9259717825442343b23b3cd62

RUN wget $TERRAGRUNT_NEW_URL/$TERRAGRUNT_NEW_FILENAME \
  && echo "$TERRAGRUNT_NEW_SHA256  ./$TERRAGRUNT_NEW_FILENAME" | sha256sum -c - \
  && mv ./$TERRAGRUNT_NEW_FILENAME ./terragrunt19 \
  && chmod +x ./terragrunt19


# Install packer
# From https://www.packer.io/downloads.html
ENV PACKER_VERSION 1.4.4
ENV PACKER_URL https://releases.hashicorp.com/packer/$PACKER_VERSION
ENV PACKER_FILENAME packer_${PACKER_VERSION}_linux_amd64.zip
ENV PACKER_SHA256 b4dc37877a0fd00fc72ebda98977c2133be9ba6b26bcdd13b1b14a369e508948

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
  && chmod +x ./${AWS_IAM_AUTH_FILENAME} \
  && mv ./${AWS_IAM_AUTH_FILENAME} ./aws-iam-authenticator


# Install Kubectx
# From https://github.com/ahmetb/kubectx/releases
ENV KUBECTX_VERSION 0.7.0
ENV KUBECTX_URL https://github.com/ahmetb/kubectx/archive
ENV KUBECTX_FILENAME v${KUBECTX_VERSION}.tar.gz
ENV KUBECTX_SHA256 b7e13a890a3543b819b8a68a0b9802dde0bedc7609b609b54475ec2c7612d26c

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
ENV KOPS_VERSION 1.14.0
ENV KOPS_URL https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}
ENV KOPS_FILENAME kops-linux-amd64
ENV KOPS_SHA256 01f246ba1eb27af09736993bb708b908a240410b216b5d11f979e6b52df48ff0

RUN wget $KOPS_URL/$KOPS_FILENAME \
  && echo "$KOPS_SHA256  ./$KOPS_FILENAME" | sha256sum -c - \
  && chmod +x ./${KOPS_FILENAME} \
  && mv ./${KOPS_FILENAME} ./kops \
  && kops completion bash > /etc/bash_completion.d/kops


# Install kompose
# From https://github.com/kubernetes/kompose/releases
ENV KOMPOSE_VERSION 1.19.0
ENV KOMPOSE_URL https://github.com/kubernetes/kompose/releases/download/v${KOMPOSE_VERSION}
ENV KOMPOSE_FILENAME kompose-linux-amd64
ENV KOMPOSE_SHA256 d73aa4242102884bc5589e7a6777461b7b2e0ddc20b63f2812bfbfcbaa4659d9

RUN wget $KOMPOSE_URL/$KOMPOSE_FILENAME \
  && echo "$KOMPOSE_SHA256  ./$KOMPOSE_FILENAME" | sha256sum -c - \
  && chmod +x ./${KOMPOSE_FILENAME} \
  && mv ./${KOMPOSE_FILENAME} ./kompose \
  && kompose completion bash > /etc/bash_completion.d/kompose


# Install k9s
# From https://github.com/derailed/k9s/releases
ENV K9S_VERSION 0.9.3
ENV K9S_URL https://github.com/derailed/k9s/releases/download/${K9S_VERSION}
ENV K9S_FILENAME k9s_${K9S_VERSION}_Linux_x86_64.tar.gz
ENV K9S_SHA256 af3608517684e59de94573ad123486edd6f392c8c319ddbde6223d3ac2d37bd9

RUN wget $K9S_URL/$K9S_FILENAME \
  && echo "$K9S_SHA256  ./$K9S_FILENAME" | sha256sum -c - \
  && tar -xzf ./${K9S_FILENAME} \
  && chmod +x ./k9s \
  && rm -f LICENSE \
  && rm -f README.md \
  && rm -f ./${K9S_FILENAME}


# Install fluxctl
# From https://github.com/fluxcd/flux/releases
ENV FLUXCTL_VERSION 1.15.0
ENV FLUXCTL_URL https://github.com/fluxcd/flux/releases/download/${FLUXCTL_VERSION}
ENV FLUXCTL_FILENAME fluxctl_linux_amd64
ENV FLUXCTL_SHA256 d6ca90f6edaf5a770127ceb8fca63e1eafc2bfff8e382df255ffe16dce4fd099

RUN wget $FLUXCTL_URL/$FLUXCTL_FILENAME \
  && echo "$FLUXCTL_SHA256  ./$FLUXCTL_FILENAME" | sha256sum -c - \
  && chmod +x ./${FLUXCTL_FILENAME} \
  && mv ./${FLUXCTL_FILENAME} ./fluxctl


# Install rakkess
# From https://github.com/corneliusweig/rakkess/releases
ENV RAKKESS_VERSION 0.4.1
ENV RAKKESS_URL https://github.com/corneliusweig/rakkess/releases/download/v${RAKKESS_VERSION}
ENV RAKKESS_FILENAME rakkess-linux-amd64.gz
ENV RAKKESS_SHA256 56427bfd878a49010eb9238eb92cfefb958389e80bc790fd6cdb66ac9a363b43

RUN wget $RAKKESS_URL/$RAKKESS_FILENAME \
  && echo "$RAKKESS_SHA256  ./$RAKKESS_FILENAME" | sha256sum -c - \
  && gunzip ./${RAKKESS_FILENAME} \
  && mv ./rakkess-linux-amd64 ./rakkess \
  && chmod +x ./rakkess \
  && rm -f ./${RAKKESS_FILENAME} \
  && rakkess completion bash > /etc/bash_completion.d/rakkess


# Install kubespy
# From https://github.com/pulumi/kubespy/releases
ENV KUBESPY_VERSION 0.4.0
ENV KUBESPY_URL https://github.com/pulumi/kubespy/releases/download/v${KUBESPY_VERSION}
ENV KUBESPY_FILENAME kubespy-linux-amd64.tar.gz
ENV KUBESPY_SHA256 04e3c2d3583e3817e95dfa5041ad97b9fca9d4349f088c3520a233cca16cac55

RUN wget $KUBESPY_URL/$KUBESPY_FILENAME \
  && echo "$KUBESPY_SHA256  ./$KUBESPY_FILENAME" | sha256sum -c - \
  && tar -xzf ./${KUBESPY_FILENAME} \
  && mv ./releases/kubespy-linux-amd64/kubespy ./ \
  && chmod +x ./kubespy \
  && rm -f ./${KUBESPY_FILENAME} \
  && rm -rf ./releases


# Install eksctl
# From https://github.com/weaveworks/eksctl/releases
ENV EKSCTL_VERSION 0.7.0
ENV EKSCTL_URL https://github.com/weaveworks/eksctl/releases/download/${EKSCTL_VERSION}
ENV EKSCTL_FILENAME eksctl_Linux_amd64.tar.gz
ENV EKSCTL_SHA256 b36bff0b4c6a3d9e2614a4727850ca2c5bc7a84ecb0fefdb7707b3080e8d2ab5

RUN wget $EKSCTL_URL/$EKSCTL_FILENAME \
  && echo "$EKSCTL_SHA256  ./$EKSCTL_FILENAME" | sha256sum -c - \
  && tar -xzf ./${EKSCTL_FILENAME} \
  && chmod +x ./eksctl \
  && rm -f ./${EKSCTL_FILENAME} \
  && eksctl completion bash > /etc/bash_completion.d/eksctl


# Install the AWS session manager plugin
ENV AWSSMP_VERSION 1.1.31.0
ENV AWSSMP_URL https://s3.amazonaws.com/session-manager-downloads/plugin/${AWSSMP_VERSION}/linux_64bit
ENV AWSSMP_FILENAME session-manager-plugin.rpm
ENV AWSSMP_SHA256 6a4abafaa921a5ff242bb8dfff18d528f1544e22571ba03b3a5d7d4d3cf28072

RUN apk --update --no-cache add --virtual build.deps \
    rpm2cpio \
  && wget $AWSSMP_URL/$AWSSMP_FILENAME \
  && echo "$AWSSMP_SHA256  ./$AWSSMP_FILENAME" | sha256sum -c - \
  && rpm2cpio ./session-manager-plugin.rpm | cpio -idmv \
  && mv ./usr/local/sessionmanagerplugin/bin/session-manager-plugin /usr/local/bin/ \
  && rm -rf ./etc ./usr ./var ./$AWSSMP_FILENAME \
  && apk del build.deps


# Install cloud-nuke
ENV CLOUD_NUKE_VERSION 0.1.11
ENV CLOUD_NUKE_URL https://github.com/gruntwork-io/cloud-nuke/releases/download/v${CLOUD_NUKE_VERSION}
ENV CLOUD_NUKE_FILENAME cloud-nuke_linux_amd64
ENV CLOUD_NUKE_SHA256 afe7eaaddabfa9ca25edfe1af1436bbf09dbf1f791dec23930ac3c02758fa074

RUN wget $CLOUD_NUKE_URL/$CLOUD_NUKE_FILENAME \
  && echo "$CLOUD_NUKE_SHA256  ./$CLOUD_NUKE_FILENAME" | sha256sum -c - \
  && chmod +x ./${CLOUD_NUKE_FILENAME} \
  && mv ./${CLOUD_NUKE_FILENAME} ./cloud-nuke


WORKDIR /opt

# Install gcloud suite
# From https://cloud.google.com/sdk/docs/quickstart-linux
ENV GCLOUD_VERSION 269.0.0
ENV GCLOUD_URL https://dl.google.com/dl/cloudsdk/channels/rapid/downloads
ENV GCLOUD_FILENAME google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz
ENV GCLOUD_SHA256 f152815d05a2f9374c87be1325a7d3bdbf62720d8fad9acb42dc2312d2e33f4a

RUN wget $GCLOUD_URL/$GCLOUD_FILENAME \
  && echo "$GCLOUD_SHA256  ./$GCLOUD_FILENAME" | sha256sum -c - \
  && tar -xzf ./$GCLOUD_FILENAME \
  && rm ./$GCLOUD_FILENAME \
  && ./google-cloud-sdk/install.sh --quiet


COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY clearokta /usr/bin/clearokta

# Install go binaries
ENV GOROOT "/usr/lib/go"
RUN apk --update --no-cache add --virtual build.deps \
    build-base \
    go \
    libusb-dev \
    pkgconfig \
  && echo GOROOT=/usr/lib/go > /usr/lib/go/src/all.bash \
  && export CGO_ENABLED=0 \
  && go get github.com/hashicorp/hcl2/cmd/hclfmt \
  && go get github.com/segmentio/terraform-docs \
  && go get github.com/kelseyhightower/confd \
  && export CGO_ENABLED=1 \
  && go get github.com/segmentio/aws-okta \
  && go get gopkg.in/mikefarah/yq.v2 \
  && go clean -cache \
  && mv /root/go/bin/* /usr/bin/ \
  && mv /usr/bin/yq.v2 /usr/bin/yq \
  && apk del build.deps \
  && rm -rf /root/go/ \
  && rm -rf /root/.cache \
  && rm -rf /usr/lib/go/src/all.bash \
  && terraform-docs completion bash > /etc/bash_completion.d/terraform-docs \
  && aws-okta completion bash > /etc/bash_completion.d/aws-okta \
  && echo "# Added at containter build-time" >> /etc/ssh/ssh_config \
  && echo "    Host *" >> /etc/ssh/ssh_config \
  && echo "ServerAliveInterval 30" >> /etc/ssh/ssh_config \
  && echo "ServerAliveCountMax 3" >> /etc/ssh/ssh_config \
  && chmod +x /docker-entrypoint.sh \
  && chmod +x /usr/bin/clearokta

COPY bashrc /etc/bashrc

ENV SSH_AUTH_SOCK /tmp/agent.sock

EXPOSE 5555

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["ssh-agent", "-d", "-s", "-a", "/tmp/agent.sock"]
