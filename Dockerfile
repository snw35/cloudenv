# Cloud environment container
# Provides a suite of cloud tools for AWS, GCP and Kubernetes

FROM alpine:3.15

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
    git \
    gnupg \
    groff \
    iputils \
    jq \
    keychain \
    libusb \
    ncurses \
    net-tools \
    nmap \
    openssh-client \
    openssl \
    perl \
    py3-pip \
    python3 \
    shadow \
    su-exec \
    tmux \
    tzdata \
  && pip install --upgrade pip \
  && pip install --no-cache-dir  \
    aws-export-credentials \
    cookiecutter \
    datadog \
    okta-awscli \
    wheel \
  && curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest \
  && chmod +x /usr/local/bin/ecs-cli \
  && sed -i 's/^CREATE_MAIL_SPOOL=yes/CREATE_MAIL_SPOOL=no/' /etc/default/useradd \
  && mkdir -p /etc/bash_completion.d \
  && ln -s /usr/bin/python3 /usr/bin/python

# Install software / modules that need build_base
RUN apk --update --no-cache add --virtual build.deps \
    build-base \
    cargo \
    libffi-dev \
    openssl-dev \
    python3-dev \
    rust \
  && pip install --no-cache-dir \
    aws-okta-keyman \
    aws-sam-cli \
    ec2instanceconnectcli \
    keyrings.cryptfile \
  && apk del build.deps


# Install glibc
ENV GLIBC_VERSION 2.34-r0
ENV GLIBC_URL https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}
ENV GLIBC_FILENAME glibc-${GLIBC_VERSION}.apk
ENV GLIBC_SHA256 3ef4a8d71777b3ccdd540e18862d688e32aa1c7bc5a1c0170271a43d0e736486

RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
  && wget $GLIBC_URL/$GLIBC_FILENAME \
  && wget $GLIBC_URL/glibc-bin-${GLIBC_VERSION}.apk \
  && echo "$GLIBC_SHA256  ./$GLIBC_FILENAME" | sha256sum -c - \
  && apk add --no-cache ./$GLIBC_FILENAME ./glibc-bin-${GLIBC_VERSION}.apk \
  && rm -f ./$GLIBC_FILENAME \
  && rm -f glibc-bin-${GLIBC_VERSION}.apk


# Install KUBECTL
# From https://storage.googleapis.com/kubernetes-release/release/stable.txt
# curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
ENV KUBECTL_VERSION 1.23.1
ENV KUBECTL_URL https://storage.googleapis.com/kubernetes-release/release/v$KUBECTL_VERSION/bin/linux/amd64
ENV KUBECTL_FILENAME kubectl
ENV KUBECTL_SHA256 156fd5e7ebbedf3c482fd274089ad75a448b04cf42bc53f370e4e4ea628f705e

RUN wget $KUBECTL_URL/$KUBECTL_FILENAME \
  && echo "$KUBECTL_SHA256  ./$KUBECTL_FILENAME" | sha256sum -c - \
  && chmod +x ./$KUBECTL_FILENAME \
  && kubectl completion bash > /etc/bash_completion.d/kubectl


# Install HELM
# From https://github.com/helm/helm/releases
ENV HELM_VERSION 3.7.2
ENV HELM_URL https://get.helm.sh
ENV HELM_FILENAME helm-v${HELM_VERSION}-linux-amd64.tar.gz
ENV HELM_SHA256 4ae30e48966aba5f807a4e140dad6736ee1a392940101e4d79ffb4ee86200a9e

RUN wget $HELM_URL/$HELM_FILENAME \
  && echo "$HELM_SHA256  ./$HELM_FILENAME" | sha256sum -c - \
  && tar -xzf $HELM_FILENAME \
  && mv ./linux-amd64/helm ./ \
  && rm -rf ./linux-amd64 \
  && rm -f $HELM_FILENAME \
  && chmod +x ./helm \
  && helm completion bash > /etc/bash_completion.d/helm


# Install terraform 11
# From https://www.terraform.io/downloads.html
ENV TERRAFORM_11_VERSION 0.11.15
ENV TERRAFORM_11_URL https://releases.hashicorp.com/terraform/$TERRAFORM_11_VERSION
ENV TERRAFORM_11_FILENAME terraform_${TERRAFORM_11_VERSION}_linux_amd64.zip
ENV TERRAFORM_11_SHA256 e6c8c884de6c353cf98252c5e11faf972d4b30b5d070ab5ff70eaf92660a5aac

RUN wget $TERRAFORM_11_URL/$TERRAFORM_11_FILENAME \
  && echo "$TERRAFORM_11_SHA256  ./$TERRAFORM_11_FILENAME" | sha256sum -c - \
  && unzip ./$TERRAFORM_11_FILENAME \
  && rm ./$TERRAFORM_11_FILENAME \
  && chmod +x ./terraform \
  && mv ./terraform ./terraform11

# Install terraform 12
# From https://www.terraform.io/downloads.html
ENV TERRAFORM_12_VERSION 0.12.31
ENV TERRAFORM_12_URL https://releases.hashicorp.com/terraform/$TERRAFORM_12_VERSION
ENV TERRAFORM_12_FILENAME terraform_${TERRAFORM_12_VERSION}_linux_amd64.zip
ENV TERRAFORM_12_SHA256 e5eeba803bc7d8d0cae7ef04ba7c3541c0abd8f9e934a5e3297bf738b31c5c6d

RUN wget $TERRAFORM_12_URL/$TERRAFORM_12_FILENAME \
  && echo "$TERRAFORM_12_SHA256  ./$TERRAFORM_12_FILENAME" | sha256sum -c - \
  && unzip ./$TERRAFORM_12_FILENAME \
  && rm ./$TERRAFORM_12_FILENAME \
  && chmod +x ./terraform \
  && mv ./terraform ./terraform12

# Install terraform latest
# From https://www.terraform.io/downloads.html
ENV TERRAFORM_LATEST_VERSION 1.1.3
ENV TERRAFORM_LATEST_URL https://releases.hashicorp.com/terraform/$TERRAFORM_LATEST_VERSION
ENV TERRAFORM_LATEST_FILENAME terraform_${TERRAFORM_LATEST_VERSION}_linux_amd64.zip
ENV TERRAFORM_LATEST_SHA256 b215de2a18947fff41803716b1829a3c462c4f009b687c2cbdb52ceb51157c2f

RUN wget $TERRAFORM_LATEST_URL/$TERRAFORM_LATEST_FILENAME \
  && echo "$TERRAFORM_LATEST_SHA256  ./$TERRAFORM_LATEST_FILENAME" | sha256sum -c - \
  && unzip ./$TERRAFORM_LATEST_FILENAME \
  && rm ./$TERRAFORM_LATEST_FILENAME \
  && chmod +x ./terraform \
  && mv ./terraform ./terraform-latest

# Use Terrafrom latest by default
RUN ln -s ./terraform-latest ./terraform


# Install terragrunt 18
# From https://github.com/gruntwork-io/terragrunt/releases
ENV TERRAGRUNT_OLD_VERSION 0.18.7
ENV TERRAGRUNT_OLD_URL https://github.com/gruntwork-io/terragrunt/releases/download/v$TERRAGRUNT_OLD_VERSION
ENV TERRAGRUNT_OLD_FILENAME terragrunt_linux_amd64
ENV TERRAGRUNT_OLD_SHA256 3a45138e77fb41e0884b9491c67dcdeacd06418cd10a1e16ea0cc03976f1b288

RUN wget $TERRAGRUNT_OLD_URL/$TERRAGRUNT_OLD_FILENAME \
  && echo "$TERRAGRUNT_OLD_SHA256  ./$TERRAGRUNT_OLD_FILENAME" | sha256sum -c - \
  && mv ./$TERRAGRUNT_OLD_FILENAME ./terragrunt18 \
  && chmod +x ./terragrunt18

# Install terragrunt 19+
# From https://github.com/gruntwork-io/terragrunt/releases
ENV TERRAGRUNT_NEW_VERSION 0.35.16
ENV TERRAGRUNT_NEW_URL https://github.com/gruntwork-io/terragrunt/releases/download/v$TERRAGRUNT_NEW_VERSION
ENV TERRAGRUNT_NEW_FILENAME terragrunt_linux_amd64
ENV TERRAGRUNT_NEW_SHA256 0404f0dfd2ab3b642dcf2c1c038d0bcbee256ee14a92d731a9ea0514f6cf47f4

RUN wget $TERRAGRUNT_NEW_URL/$TERRAGRUNT_NEW_FILENAME \
  && echo "$TERRAGRUNT_NEW_SHA256  ./$TERRAGRUNT_NEW_FILENAME" | sha256sum -c - \
  && mv ./$TERRAGRUNT_NEW_FILENAME ./terragrunt \
  && chmod +x ./terragrunt


# Install packer
# From https://www.packer.io/downloads.html
ENV PACKER_VERSION 1.7.8
ENV PACKER_URL https://releases.hashicorp.com/packer/$PACKER_VERSION
ENV PACKER_FILENAME packer_${PACKER_VERSION}_linux_amd64.zip
ENV PACKER_SHA256 8a94b84542d21b8785847f4cccc8a6da4c7be5e16d4b1a2d0a5f7ec5532faec0

RUN wget $PACKER_URL/$PACKER_FILENAME \
  && echo "$PACKER_SHA256  ./$PACKER_FILENAME" | sha256sum -c - \
  && unzip ./$PACKER_FILENAME \
  && rm ./$PACKER_FILENAME \
  && chmod +x ./packer


# Install aws-iam-authenticator
# From https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
# https://github.com/kubernetes-sigs/aws-iam-authenticator/releases
ENV AWS_IAM_AUTH_VERSION 0.5.3
ENV AWS_IAM_AUTH_URL https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${AWS_IAM_AUTH_VERSION}
ENV AWS_IAM_AUTH_FILENAME aws-iam-authenticator_${AWS_IAM_AUTH_VERSION}_linux_amd64
ENV AWS_IAM_AUTH_SHA256 20f4d8ece0f867c38b917ebe37dff934a31aabe385e26986183b14d72c70c137

RUN wget $AWS_IAM_AUTH_URL/$AWS_IAM_AUTH_FILENAME \
  && echo "$AWS_IAM_AUTH_SHA256  ./$AWS_IAM_AUTH_FILENAME" | sha256sum -c - \
  && chmod +x ./${AWS_IAM_AUTH_FILENAME} \
  && mv ./${AWS_IAM_AUTH_FILENAME} ./aws-iam-authenticator


# Install Kubectx
# From https://github.com/ahmetb/kubectx/releases
ENV KUBECTX_VERSION 0.9.4
ENV KUBECTX_URL https://github.com/ahmetb/kubectx/archive
ENV KUBECTX_FILENAME v${KUBECTX_VERSION}.tar.gz
ENV KUBECTX_SHA256 91e6b2e0501bc581f006322d621adad928ea3bd3d8df6612334804b93efd258c

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
ENV KOPS_VERSION 1.22.3
ENV KOPS_URL https://github.com/kubernetes/kops/releases/download/v${KOPS_VERSION}
ENV KOPS_FILENAME kops-linux-amd64
ENV KOPS_SHA256 827619a79de49a3ee8398d5d2fa3c0da281948c5c1159227c952eae342d1b619

RUN wget $KOPS_URL/$KOPS_FILENAME \
  && echo "$KOPS_SHA256  ./$KOPS_FILENAME" | sha256sum -c - \
  && chmod +x ./${KOPS_FILENAME} \
  && mv ./${KOPS_FILENAME} ./kops \
  && kops completion bash > /etc/bash_completion.d/kops


# Install kompose
# From https://github.com/kubernetes/kompose/releases
ENV KOMPOSE_VERSION 1.26.0
ENV KOMPOSE_URL https://github.com/kubernetes/kompose/releases/download/v${KOMPOSE_VERSION}
ENV KOMPOSE_FILENAME kompose-linux-amd64
ENV KOMPOSE_SHA256 8c6c47073a95a52487a760f69a79669e2786c7aa3ba6e3007095efd524593253

RUN wget $KOMPOSE_URL/$KOMPOSE_FILENAME \
  && echo "$KOMPOSE_SHA256  ./$KOMPOSE_FILENAME" | sha256sum -c - \
  && chmod +x ./${KOMPOSE_FILENAME} \
  && mv ./${KOMPOSE_FILENAME} ./kompose \
  && kompose completion bash > /etc/bash_completion.d/kompose


# Install k9s
# From https://github.com/derailed/k9s/releases
ENV K9S_VERSION 0.25.18
ENV K9S_URL https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}
ENV K9S_FILENAME k9s_Linux_x86_64.tar.gz
ENV K9S_SHA256 d288aacc368ab6b243fc9e7ecd17b53fa34a813509c2dc3023171085db83cf9d

RUN wget $K9S_URL/$K9S_FILENAME \
  && echo "$K9S_SHA256  ./$K9S_FILENAME" | sha256sum -c - \
  && tar -xzf ./${K9S_FILENAME} \
  && chmod +x ./k9s \
  && rm -f LICENSE \
  && rm -f README.md \
  && rm -f ./${K9S_FILENAME}


# Install fluxctl
# From https://github.com/fluxcd/flux/releases
ENV FLUXCTL_VERSION 1.24.3
ENV FLUXCTL_URL https://github.com/fluxcd/flux/releases/download/${FLUXCTL_VERSION}
ENV FLUXCTL_FILENAME fluxctl_linux_amd64
ENV FLUXCTL_SHA256 0062e85339b65bf7db74b27b862ec000949e7abb7954b11f34367e0eff9c1ea8

RUN wget $FLUXCTL_URL/$FLUXCTL_FILENAME \
  && echo "$FLUXCTL_SHA256  ./$FLUXCTL_FILENAME" | sha256sum -c - \
  && chmod +x ./${FLUXCTL_FILENAME} \
  && mv ./${FLUXCTL_FILENAME} ./fluxctl


# Install rakkess
# From https://github.com/corneliusweig/rakkess/releases
ENV RAKKESS_VERSION 0.5.0
ENV RAKKESS_URL https://github.com/corneliusweig/rakkess/releases/download/v${RAKKESS_VERSION}
ENV RAKKESS_FILENAME rakkess-amd64-linux.tar.gz
ENV RAKKESS_SHA256 f9d90b3d2d96c3afc76adb1d92755a11b82f27800d44864416479b128f3f991e

RUN wget $RAKKESS_URL/$RAKKESS_FILENAME \
  && echo "$RAKKESS_SHA256  ./$RAKKESS_FILENAME" | sha256sum -c - \
  && tar -xzf ./${RAKKESS_FILENAME} \
  && mv ./rakkess-amd64-linux ./rakkess \
  && chmod +x ./rakkess \
  && rm -f ./${RAKKESS_FILENAME} \
  && rm -f ./LICENSE


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
ENV EKSCTL_VERSION 0.77.0
ENV EKSCTL_URL https://github.com/weaveworks/eksctl/releases/download/v${EKSCTL_VERSION}
ENV EKSCTL_FILENAME eksctl_Linux_amd64.tar.gz
ENV EKSCTL_SHA256 127630fc72d15985822392dd13e3a5318419c443d68fcb11ce511a304e16eb74

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


# Install cloud-nuke (temp disable upgrading again)
ENV CLOUD_NUKE_UPGRADE false
ENV CLOUD_NUKE_VERSION 0.1.18
ENV CLOUD_NUKE_URL https://github.com/gruntwork-io/cloud-nuke/releases/download/v${CLOUD_NUKE_VERSION}
ENV CLOUD_NUKE_FILENAME cloud-nuke_linux_amd64
ENV CLOUD_NUKE_SHA256 7cf26457baa404017b2e89b6768a1ee24073ec0ca17bcdf23a79efb27f5bb736

RUN wget $CLOUD_NUKE_URL/$CLOUD_NUKE_FILENAME \
  && echo "$CLOUD_NUKE_SHA256  ./$CLOUD_NUKE_FILENAME" | sha256sum -c - \
  && chmod +x ./${CLOUD_NUKE_FILENAME} \
  && mv ./${CLOUD_NUKE_FILENAME} ./cloud-nuke


# Install confd
ENV CONFD_VERSION 0.16.0
ENV CONFD_URL https://github.com/kelseyhightower/confd/releases/download/v$CONFD_VERSION
ENV CONFD_FILENAME confd-$CONFD_VERSION-linux-amd64
ENV CONFD_SHA256 255d2559f3824dd64df059bdc533fd6b697c070db603c76aaf8d1d5e6b0cc334

RUN wget $CONFD_URL/$CONFD_FILENAME \
  && echo "$CONFD_SHA256  ./$CONFD_FILENAME" | sha256sum -c - \
  && mv ./$CONFD_FILENAME /usr/bin/confd \
  && chmod +x /usr/bin/confd \
  && mkdir -p /etc/confd/conf.d \
  && mkdir -p /etc/confd/templates


# Install aws-okta
# Upstream has stopped providing pre-built binaries
ENV AWS_OKTA_VERSION 1.0.11
ENV AWS_OKTA_URL https://github.com/segmentio/aws-okta/archive
ENV AWS_OKTA_FILENAME v${AWS_OKTA_VERSION}.tar.gz
ENV AWS_OKTA_SHA256 444a84cd9c81097a7c462f806605193c5676879133255cfa0f610b7d14756b65

RUN wget $AWS_OKTA_URL/$AWS_OKTA_FILENAME \
  && echo "$AWS_OKTA_SHA256  ./$AWS_OKTA_FILENAME" | sha256sum -c - \
  && tar -xzf ./$AWS_OKTA_FILENAME \
  && apk --update --no-cache add --virtual build.deps \
    go \
  && export CGO_ENABLED=0 \
  && cd ./aws-okta-${AWS_OKTA_VERSION} \
  && go build \
  && cd .. \
  && mv ./aws-okta-${AWS_OKTA_VERSION}/aws-okta /usr/bin/aws-okta \
  && rm -rf ./aws-okta-${AWS_OKTA_VERSION} \
  && rm -rf ./$AWS_OKTA_FILENAME \
  && go clean -cache \
  && apk del build.deps \
  && rm -rf /root/go/ \
  && rm -rf /root/.cache \
  && /usr/bin/aws-okta completion bash > /etc/bash_completion.d/aws-okta


# Install terraform-docs
ENV TERRAFORM_DOCS_VERSION 0.16.0
ENV TERRAFORM_DOCS_URL https://github.com/terraform-docs/terraform-docs/releases/download/v$TERRAFORM_DOCS_VERSION
ENV TERRAFORM_DOCS_FILENAME terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz
ENV TERRAFORM_DOCS_SHA256 328c16cd6552b3b5c4686b8d945a2e2e18d2b8145b6b66129cd5491840010182

RUN wget $TERRAFORM_DOCS_URL/$TERRAFORM_DOCS_FILENAME \
  && echo "$TERRAFORM_DOCS_SHA256  ./$TERRAFORM_DOCS_FILENAME" | sha256sum -c - \
  && tar -xzf ./$TERRAFORM_DOCS_FILENAME \
  && chmod +x /usr/bin/terraform-docs \
  && /usr/bin/terraform-docs completion bash > /etc/bash_completion.d/terraform-docs \
  && rm -f ./$TERRAFORM_DOCS_FILENAME


# Install aws-connect
ENV AWS_CONNECT_VERSION 1.0.11
ENV AWS_CONNECT_URL https://github.com/rewindio/aws-connect/archive
ENV AWS_CONNECT_FILENAME v${AWS_CONNECT_VERSION}.tar.gz
ENV AWS_CONNECT_SHA256 56d9ae4695302ca93c4020bf634d5f09eb772dfde7be2db02035266b7d3d44a2

RUN wget $AWS_CONNECT_URL/$AWS_CONNECT_FILENAME \
  && echo "$AWS_CONNECT_SHA256  ./$AWS_CONNECT_FILENAME" | sha256sum -c - \
  && tar -xzf ./${AWS_CONNECT_FILENAME} \
  && mv ./aws-connect-${AWS_CONNECT_VERSION}/aws-connect /usr/local/bin/aws-connect \
  && chmod +x /usr/local/bin/aws-connect \
  && rm -f ./${AWS_CONNECT_FILENAME} \
  && rm -rf ./aws-connect-${AWS_CONNECT_VERSION}


# Install AWS CLI v2
ENV AWS_CLI_VERSION 2.4.9
ENV AWS_CLI_URL https://awscli.amazonaws.com
ENV AWS_CLI_FILENAME awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip
ENV AWS_CLI_SHA256 0582d347ce0bd435b154631795b8cd6c868c1a44d60ada5746e3c1d13f8347ec

RUN wget $AWS_CLI_URL/$AWS_CLI_FILENAME \
  && echo "$AWS_CLI_SHA256  ./$AWS_CLI_FILENAME" | sha256sum -c - \
  && unzip ./$AWS_CLI_FILENAME \
  && rm -f ./$AWS_CLI_FILENAME \
  && ./aws/install \
  && rm -rf ./aws


WORKDIR /opt

# Install gcloud suite
# From https://cloud.google.com/sdk/docs/quickstart-linux
ENV GCLOUD_VERSION 367.0.0
ENV GCLOUD_URL https://dl.google.com/dl/cloudsdk/channels/rapid/downloads
ENV GCLOUD_FILENAME google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz
ENV GCLOUD_SHA256 94328b9c6559a1b7ec2eeaab9ef0e4702215e16e8327c5b99718750526ae1efe

RUN wget $GCLOUD_URL/$GCLOUD_FILENAME \
  && echo "$GCLOUD_SHA256  ./$GCLOUD_FILENAME" | sha256sum -c - \
  && tar -xzf ./$GCLOUD_FILENAME \
  && rm ./$GCLOUD_FILENAME \
  && ./google-cloud-sdk/install.sh --quiet


COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY clearokta /usr/bin/clearokta

# Set up bashrc and scripts
RUN echo "# Added at containter build-time" >> /etc/ssh/ssh_config \
  && echo "    Host *" >> /etc/ssh/ssh_config \
  && echo "ServerAliveInterval 30" >> /etc/ssh/ssh_config \
  && echo "ServerAliveCountMax 3" >> /etc/ssh/ssh_config \
  && chmod +x /docker-entrypoint.sh \
  && chmod +x /usr/bin/clearokta

RUN echo "Test Layer" \
  && /opt/google-cloud-sdk/bin/gcloud version \
  && aws --version \
  && aws_okta_keyman --help \
  && aws-connect -v \
  && aws-export-credentials --help \
  && aws-iam-authenticator \
  && aws-okta \
  && cloud-nuke \
  && confd -version \
  && cookiecutter -h \
  && eksctl \
  && fluxctl \
  && helm \
  && kompose -h \
  && kops \
  && kubectl \
  && kubectx --help \
  && kubens --help \
  && mssh --help \
  && okta-awscli --help \
  && rakkess --help \
  && sam --help \
  && session-manager-plugin --version \
  && terraform-docs \
  && terraform-latest -h \
  && terraform11 -h \
  && terraform12 -h \
  && terragrunt -h \
  && terragrunt18 -h

COPY bashrc /etc/bashrc

ENV SSH_AUTH_SOCK /tmp/agent.sock

EXPOSE 5555

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["ssh-agent", "-d", "-s", "-a", "/tmp/agent.sock"]
