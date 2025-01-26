# Cloud environment container
# Provides a suite of cloud tools for AWS, GCP and Kubernetes

FROM debian:bookworm-20250113-slim

WORKDIR /usr/bin/

# Install base packages and deps
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    bash \
    bash-completion \
    bind9-utils \
    ca-certificates \
    coreutils \
    curl \
    diffutils \
    fish \
    fzf \
    git \
    gnupg \
    groff \
    iputils-ping \
    iputils-tracepath \
    keychain \
    less \
    make \
    net-tools \
    nmap \
    openssh-client \
    python3-pip \
    tmux \
    tzdata \
    unzip \
    vim \
    wget \
    zsh \
  && apt-get clean

# Install pip apps
RUN pip install --no-cache-dir --break-system-packages \
    aws-okta-keyman \
    aws-sam-cli \
    ec2instanceconnectcli \
    keyrings.cryptfile \
    aws-export-credentials \
    cookiecutter \
    datadog \
    okta-awscli \
  && curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest \
  && chmod +x /usr/local/bin/ecs-cli \
  && mkdir -p /etc/bash_completion.d


# Install KUBECTL
# From https://storage.googleapis.com/kubernetes-release/release/stable.txt
# curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
ENV KUBECTL_VERSION 1.31.0
ENV KUBECTL_URL https://storage.googleapis.com/kubernetes-release/release/v$KUBECTL_VERSION/bin/linux/amd64
ENV KUBECTL_FILENAME kubectl
ENV KUBECTL_SHA256 7c27adc64a84d1c0cc3dcf7bf4b6e916cc00f3f576a2dbac51b318d926032437

RUN wget $KUBECTL_URL/$KUBECTL_FILENAME \
  && echo "$KUBECTL_SHA256  ./$KUBECTL_FILENAME" | sha256sum -c - \
  && chmod +x ./$KUBECTL_FILENAME \
  && kubectl completion bash > /etc/bash_completion.d/kubectl


# Install HELM
# From https://github.com/helm/helm/releases
ENV HELM_VERSION 3.17.0
ENV HELM_URL https://get.helm.sh
ENV HELM_FILENAME helm-v${HELM_VERSION}-linux-amd64.tar.gz
ENV HELM_SHA256 fb5d12662fde6eeff36ac4ccacbf3abed96b0ee2de07afdde4edb14e613aee24

RUN wget $HELM_URL/$HELM_FILENAME \
  && echo "$HELM_SHA256  ./$HELM_FILENAME" | sha256sum -c - \
  && tar -xzf $HELM_FILENAME \
  && mv ./linux-amd64/helm ./ \
  && rm -rf ./linux-amd64 \
  && rm -f $HELM_FILENAME \
  && chmod +x ./helm \
  && helm completion bash > /etc/bash_completion.d/helm


# Install terraform
# From https://www.terraform.io/downloads.html
ENV TERRAFORM_VERSION 1.10.5
ENV TERRAFORM_URL https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION
ENV TERRAFORM_FILENAME terraform_${TERRAFORM_VERSION}_linux_amd64.zip
ENV TERRAFORM_SHA256 0566a24f5332098b15716ebc394be503f4094acba5ba529bf5eb0698ed5e2a90

RUN wget $TERRAFORM_URL/$TERRAFORM_FILENAME \
  && echo "$TERRAFORM_SHA256  ./$TERRAFORM_FILENAME" | sha256sum -c - \
  && unzip ./$TERRAFORM_FILENAME \
  && rm ./$TERRAFORM_FILENAME \
  && chmod +x ./terraform


# Install terragrunt
# From https://github.com/gruntwork-io/terragrunt/releases
ENV TERRAGRUNT_VERSION 0.72.4
ENV TERRAGRUNT_URL https://github.com/gruntwork-io/terragrunt/releases/download/v$TERRAGRUNT_VERSION
ENV TERRAGRUNT_FILENAME terragrunt_linux_amd64
ENV TERRAGRUNT_SHA256 b32d0b48b0c27f301dabe16cbadc074088f78ffc6f84f98aa99a6d4f9293c53a

RUN wget $TERRAGRUNT_URL/$TERRAGRUNT_FILENAME \
  && echo "$TERRAGRUNT_SHA256  ./$TERRAGRUNT_FILENAME" | sha256sum -c - \
  && mv ./$TERRAGRUNT_FILENAME ./terragrunt \
  && chmod +x ./terragrunt


# Install packer
# From https://www.packer.io/downloads.html
ENV PACKER_VERSION 1.12.0
ENV PACKER_URL https://releases.hashicorp.com/packer/$PACKER_VERSION
ENV PACKER_FILENAME packer_${PACKER_VERSION}_linux_amd64.zip
ENV PACKER_SHA256 e859a76659570d1e29fa55396d5d908091bacacd4567c17770e616c4b58c9ace

RUN wget $PACKER_URL/$PACKER_FILENAME \
  && echo "$PACKER_SHA256  ./$PACKER_FILENAME" | sha256sum -c - \
  && unzip -o ./$PACKER_FILENAME \
  && rm ./$PACKER_FILENAME \
  && chmod +x ./packer


# Install aws-iam-authenticator
# From https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
# https://github.com/kubernetes-sigs/aws-iam-authenticator/releases
ENV AWS_IAM_AUTH_VERSION 0.6.29
ENV AWS_IAM_AUTH_URL https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${AWS_IAM_AUTH_VERSION}
ENV AWS_IAM_AUTH_FILENAME aws-iam-authenticator_${AWS_IAM_AUTH_VERSION}_linux_amd64
ENV AWS_IAM_AUTH_SHA256 3eb662fc197510d27418ae57a10d71c864d15ecab4b5c2b04e495175a8f87d8f

RUN wget $AWS_IAM_AUTH_URL/$AWS_IAM_AUTH_FILENAME \
  && echo "$AWS_IAM_AUTH_SHA256  ./$AWS_IAM_AUTH_FILENAME" | sha256sum -c - \
  && chmod +x ./${AWS_IAM_AUTH_FILENAME} \
  && mv ./${AWS_IAM_AUTH_FILENAME} ./aws-iam-authenticator


# Install Kubectx
# From https://github.com/ahmetb/kubectx/releases
ENV KUBECTX_VERSION 0.9.5
ENV KUBECTX_URL https://github.com/ahmetb/kubectx/archive
ENV KUBECTX_FILENAME v${KUBECTX_VERSION}.tar.gz
ENV KUBECTX_SHA256 c94392fba8dfc5c8075161246749ef71c18f45da82759084664eb96027970004

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


# Install kompose
# From https://github.com/kubernetes/kompose/releases
ENV KOMPOSE_VERSION 1.35.0
ENV KOMPOSE_URL https://github.com/kubernetes/kompose/releases/download/v${KOMPOSE_VERSION}
ENV KOMPOSE_FILENAME kompose-linux-amd64
ENV KOMPOSE_SHA256 d7de6c93ef083b668cdcf11bb7ebf739f853952ad229c4afcbbda5af7a480672

RUN wget $KOMPOSE_URL/$KOMPOSE_FILENAME \
  && echo "$KOMPOSE_SHA256  ./$KOMPOSE_FILENAME" | sha256sum -c - \
  && chmod +x ./${KOMPOSE_FILENAME} \
  && mv ./${KOMPOSE_FILENAME} ./kompose \
  && kompose completion bash > /etc/bash_completion.d/kompose


# Install k9s
# From https://github.com/derailed/k9s/releases
ENV K9S_VERSION 0.32.7
ENV K9S_URL https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}
ENV K9S_FILENAME k9s_Linux_amd64.tar.gz
ENV K9S_SHA256 03934727bfbf39b1e61a74d8e045796cda2de14f8ce4c01df27f43d4494021de

RUN wget $K9S_URL/$K9S_FILENAME \
  && echo "$K9S_SHA256  ./$K9S_FILENAME" | sha256sum -c - \
  && tar -xzf ./${K9S_FILENAME} \
  && chmod +x ./k9s \
  && rm -f LICENSE \
  && rm -f README.md \
  && rm -f ./${K9S_FILENAME}


# Install flux2
# From https://github.com/fluxcd/flux2/releases
ENV FLUX2_VERSION 2.4.0
ENV FLUX2_URL https://github.com/fluxcd/flux2/releases/download/v${FLUX2_VERSION}
ENV FLUX2_FILENAME flux_${FLUX2_VERSION}_linux_amd64.tar.gz
ENV FLUX2_SHA256 7b70b75af20e28fc30ee66cf5372ec8d51dd466fd2ee21aa42690984de70b09b

RUN wget $FLUX2_URL/$FLUX2_FILENAME \
  && echo "$FLUX2_SHA256  ./$FLUX2_FILENAME" | sha256sum -c - \
  && tar -xzf ./${FLUX2_FILENAME} \
  && chmod +x ./flux \
  && rm -f ./${FLUX2_FILENAME}


# Install kubespy
# From https://github.com/pulumi/kubespy/releases
ENV KUBESPY_VERSION 0.6.3
ENV KUBESPY_URL https://github.com/pulumi/kubespy/releases/download/v${KUBESPY_VERSION}
ENV KUBESPY_FILENAME kubespy-v${KUBESPY_VERSION}-linux-amd64.tar.gz
ENV KUBESPY_SHA256 a1e9a38fd9afddeaec6c5c992aee8cb9ddaeabf9d6f122241754426a79d9b86e

RUN wget $KUBESPY_URL/$KUBESPY_FILENAME \
  && echo "$KUBESPY_SHA256  ./$KUBESPY_FILENAME" | sha256sum -c - \
  && tar -xzf ./${KUBESPY_FILENAME} \
  && chmod +x ./kubespy \
  && rm -f ./${KUBESPY_FILENAME} ./LICENSE ./README.md


# Install eksctl
# From https://github.com/eksctl-io/eksctl/releases
ENV EKSCTL_VERSION 0.202.0
ENV EKSCTL_URL https://github.com/eksctl-io/eksctl/releases/download/v${EKSCTL_VERSION}
ENV EKSCTL_FILENAME eksctl_Linux_amd64.tar.gz
ENV EKSCTL_SHA256 74d44cd60fa00c25248e8adf19cffbba796128b40445f4d199c89f9d89d67598

RUN wget $EKSCTL_URL/$EKSCTL_FILENAME \
  && echo "$EKSCTL_SHA256  ./$EKSCTL_FILENAME" | sha256sum -c - \
  && tar -xzf ./${EKSCTL_FILENAME} \
  && chmod +x ./eksctl \
  && rm -f ./${EKSCTL_FILENAME} \
  && eksctl completion bash > /etc/bash_completion.d/eksctl


# Install the AWS session manager plugin
ENV AWSSMP_VERSION 1.2.536.0
ENV AWSSMP_URL https://s3.amazonaws.com/session-manager-downloads/plugin/${AWSSMP_VERSION}/ubuntu_64bit
ENV AWSSMP_FILENAME session-manager-plugin.deb
ENV AWSSMP_SHA256 c49839338045e4ef4e44c3aec7574919add1c45c4b0b979e9c84ea53fb75553b

RUN wget $AWSSMP_URL/$AWSSMP_FILENAME \
  && echo "$AWSSMP_SHA256  ./$AWSSMP_FILENAME" | sha256sum -c - \
  && dpkg -i ./${AWSSMP_FILENAME} \
  && rm ./$AWSSMP_FILENAME


# Install cloud-nuke
ENV CLOUD_NUKE_VERSION 0.38.1
ENV CLOUD_NUKE_URL https://github.com/gruntwork-io/cloud-nuke/releases/download/v${CLOUD_NUKE_VERSION}
ENV CLOUD_NUKE_FILENAME cloud-nuke_linux_amd64
ENV CLOUD_NUKE_SHA256 194986f1b13fe1d9c96b71e83638fcef03e15a966d7e6dc51cfbe6b32aea991e
ENV DISABLE_TELEMETRY TRUE

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


# Install terraform-docs
ENV TERRAFORM_DOCS_VERSION 0.19.0
ENV TERRAFORM_DOCS_URL https://github.com/terraform-docs/terraform-docs/releases/download/v$TERRAFORM_DOCS_VERSION
ENV TERRAFORM_DOCS_FILENAME terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz
ENV TERRAFORM_DOCS_SHA256 dd741a0ece81059a478684b414d95d72b8b74fa58f50ac4036b4e8b56130d64b

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
ENV AWS_CLI_VERSION 2.23.6
ENV AWS_CLI_URL https://awscli.amazonaws.com
ENV AWS_CLI_FILENAME awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip
ENV AWS_CLI_SHA256 8d26ffa2e9427804a9f8928c692ee83e1c88456e0519a69e63bc992caf2b2339

RUN wget $AWS_CLI_URL/$AWS_CLI_FILENAME \
  && echo "$AWS_CLI_SHA256  ./$AWS_CLI_FILENAME" | sha256sum -c - \
  && unzip ./$AWS_CLI_FILENAME \
  && rm -f ./$AWS_CLI_FILENAME \
  && ./aws/install \
  && rm -rf ./aws


WORKDIR /opt

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY clearokta /usr/bin/clearokta

# Set up bashrc and scripts
RUN echo "# Added at containter build-time" >> /etc/ssh/ssh_config \
  && echo "    Host *" >> /etc/ssh/ssh_config \
  && echo "ServerAliveInterval 30" >> /etc/ssh/ssh_config \
  && echo "ServerAliveCountMax 3" >> /etc/ssh/ssh_config \
  && chmod +x /docker-entrypoint.sh \
  && chmod +x /usr/bin/clearokta

# Install latest su-exec
RUN curl -o /usr/local/bin/su-exec.c https://raw.githubusercontent.com/ncopa/su-exec/master/su-exec.c \
  && fetch_deps='gcc libc-dev' \
  && apt-get install -y --no-install-recommends $fetch_deps \
  && rm -rf /var/lib/apt/lists/* \
  && gcc -Wall /usr/local/bin/su-exec.c -o/usr/local/bin/su-exec \
  && chown root:root /usr/local/bin/su-exec \
  && chmod 0755 /usr/local/bin/su-exec \
  && rm /usr/local/bin/su-exec.c \
  && apt-get purge -y --auto-remove $fetch_deps

RUN echo "Test Layer" \
  && aws --version \
  && aws_okta_keyman --help \
  && aws-connect -v \
  && aws-export-credentials --help \
  && aws-iam-authenticator \
  && cloud-nuke \
  && confd -version \
  && cookiecutter -h \
  && eksctl \
  && flux \
  && helm \
  && kompose -h \
  && kubectl \
  && kubectx --help \
  && kubens --help \
  && kubespy \
  && mssh --help \
  && okta-awscli --help \
  && sam --help \
  && session-manager-plugin --version \
  && terraform -h \
  && terraform-docs \
  && terragrunt -h

COPY bashrc /etc/bashrc

ENV SSH_AUTH_SOCK /tmp/agent.sock

EXPOSE 5555

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["ssh-agent", "-d", "-s", "-a", "/tmp/agent.sock"]
