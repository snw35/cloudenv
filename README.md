# cloudenv

 * [Travis CI: ![Build Status](https://travis-ci.com/snw35/cloudenv.svg?branch=master)](https://travis-ci.com/github/snw35/cloudenv)

The Cloud Environment ⛅

This is a suite of modern cloud tooling that wraps seamlessly over your existing shell. It provides:

 * Infrastructure-as-code (IaC) tools for Amazon AWS and Google GCP.
 * Authentication tools for Okta and AWS.
 * A large collection of Kubernetes and container tools.

Tested on Mac and Linux with both Podman and Docker.

## How To Use

If you are using Docker, first add your user to the 'docker' group so you can run docker commands directly. Podman users do not need to do this.

Install the `cloudenv` command:

```shell
sudo curl https://raw.githubusercontent.com/snw35/cloudenv/master/cloudenv -o /usr/local/bin/cloudenv && sudo chmod +x /usr/local/bin/cloudenv;
```

Run the `cloudenv` command as your own user (not as root). It will pull the latest version of the container image (around 1.5GB), start the container, and drop you into the shell:

`⛅user@cloudenv-user:~$`

Everything should work as you expect. The bash shell contains common utilities (git, curl, ssh, etc) and all of the installed tools (listed below) with working bash-completion for those that support it. If your session has an ssh-agent running with cached credentials, then these will continue to work and be available for git/ssh etc.

There may be updates to the 'cloudenv' script itself, which won't be automatically applied. Check below for the last update and re-run the install command above if needed:

 * 2020-05-20 - Add debug logging with CLOUDENV_DBG flag.
 * 2020-05-19 - Add multi-user support.
 * 2020-05-14 - Add Podman support, consolidate clouenv script.

## Included Software

The following software is installed and checked for updates weekly:

 * [AWS CLI](https://aws.amazon.com/cli/)
 * [AWS Connect](https://github.com/rewindio/aws-connect)
 * [AWS EC2 Instance Connect CLI](https://github.com/aws/aws-ec2-instance-connect-cli)
 * [AWS Export Credentials](https://github.com/benkehoe/aws-export-credentials)
 * [AWS IAM Authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
 * [AWS Okta Keyman](https://github.com/nathan-v/aws_okta_keyman)
 * [AWS Okta](https://github.com/segmentio/aws-okta)
 * [AWS SAM CLI](https://github.com/aws/aws-sam-cli)
 * [AWS Session Manager Plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)
 * [Cloud Nuke](https://github.com/gruntwork-io/cloud-nuke)
 * [Confd](http://www.confd.io/)
 * [Cookiecutter](https://github.com/cookiecutter/cookiecutter)
 * [Datadog CLI](https://github.com/DataDog/datadogpy)
 * [EKS CLI (Elastic Kubernetes Service CLI)](https://eksctl.io/)
 * [Fluxctl](https://www.weave.works/docs/cloud/latest/tasks/deploy/manual-configuration/)
 * [Gcloud Suite](https://cloud.google.com/sdk/)
 * [Hashicorp Packer](https://www.packer.io/)
 * [Hashicorp Terraform](https://www.terraform.io/)
 * [HCL Format](https://github.com/hashicorp/hcl2)
 * [Helm](https://github.com/helm/helm)
 * [K9s](https://k9ss.io/)
 * [Kompose](http://kompose.io/)
 * [Kops](https://github.com/kubernetes/kops)
 * [Kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
 * [Kubectx](https://github.com/ahmetb/kubectx)
 * [Kubespy](https://github.com/pulumi/kubespy)
 * [Okta AWS CLI](https://github.com/jmhale/okta-awscli)
 * [Rakkess](https://github.com/corneliusweig/rakkess)
 * [Terraform Docs](https://github.com/terraform-docs/terraform-docs)
 * [Terragrunt](https://github.com/gruntwork-io/terragrunt)

 If something you want is missing, please open an issue or submit a PR, both are welcome!

### Multi-User and Multi-Session Support

One instance of cloudenv will be run per user, named 'cloudenv-username', and multiple sessions can be run in each instance. The environment inside each instance is separate, e.g separate environment variables. In summary:

* A user can run multiple sessions of cloudenv.
* Multiple users can run separate instances of cloudenv.

**WARNING:** If multiple users run cloudenv on the same machine, because the home directory is bind-mounted into the container, **anyone** in the docker group will be able to exec into any cloudenv container and access all of that user's files. This tool is meant to be run on e.g trusted jumpbox hosts, or on single-user workstations. Keep this in mind when deploying it elsewhere.

### Terraform and Terragrunt Versions

Terraform and Terragrunt are not backwards compatible with certain previous major versions, so multiple sets of versions are included. By default, the latest versions of Terraform and Terragrunt are used.

To run Terragrunt with a specific version of Terraform:

#### Terraform 11 (requires Terragrunt 18)

```shell
export TERRAGRUNT_TFPATH=/usr/bin/terraform11
terragrunt18 plan
```

#### Terraform 12

```shell
export TERRAGRUNT_TFPATH=/usr/bin/terraform12
terragrunt plan
```

#### Terraform Latest

```shell
terragrunt plan
```

### Changing The Shell

By default, a custom bash shell is run inside the container. You can change this to a plain fish or a bash session that will use your host machine's shell configuration. To do this, edit the `cloudenv` script and change the "user_shell" variable to `fish` or `bash`.


### Remove The Container

The container is left running in the background after you run the command for the first time. It won't re-start itself after a reboot, but will be in the stopped state. If you'd like to clean it up, then you can run the following: `docker/podman rm -f cloudenv`


## Why?

If you deal with infrastructure as code, or simply work with AWS and GCP from the command line, then you will have quickly realised:

 * There are too many tools.
 * Most of them aren't in your package manager.
 * Updating them is annoying.
 * Installing them on a new machine can take hours.
 * Installing them on a colleague's machine can take hours++.
 * If you don't use the same versions as *all* of your colleagues, $BAD_THINGS can happen.

Ironically (or elegantly), cloud-tooling solves its own problem in the form of Docker images that can be used to package all of these tools up, isolate them from your host machine, and make installing and running them simple.

## How It Works

This is fundamentally a Docker container running an interactive shell, though it does some extra things to make the experience seamless and pleasant.

It works in the following way:

1. The `cloudenv` script pulls latest version of the container and starts it.
2. It bind-mounts your home directory into the container, passes your user and group from the host machine in with environment variables, and ensures all permissions match up.
3. If the host has an ssh-agent running, it bind-mounts the auth socket into the container. If not, it runs a separate ssh-agent as your user. This lets ssh commands access stored credentials as though they were running on the host.
4. It starts a bash session inside the container as your user with a custom shell configuration (`/etc/bashrc`).
5. The container runs in the background and can be connected to with multiple sessions.

Further information on some of these aspects is below.

#### Bind-Mounting The Home Directory

Your home directory is bind-mounted into the container. This allows access to your files as well as all of your dot-files and dot-directories, such as `~/.ssh`, which contain all of the configuration for those utilities.

This allows the environment inside the container to behave as closely as possible to the environment on the host, and means that all of the included tools have access to the keys/credentials that they may require.

#### UserID and GroupID Mapping

Bind-mounting your home directory into a container normally creates issues with permissions, as your user on the host will not exist inside it. This is overcome by passing the IDs and names of the host's user and group into the container with environment variables, which the entrypoint script then uses to ensure that everything inside the container matches the host machine.

#### Timezones

The timezone inside an Alpine container defaults to UTC. Normally this is fine, but when your home directory is bind-mounted into the image in read-write mode, the timestamps on files will be incorrect if anything inside the container modifies them.

An environment variable (`TZ`) is used to set the timezone when the container starts up. The value is set in the cloudenv script and can be changed to match your requirements. Detecting the user's timezone cross-platform is one of those "this shouldn't be this hard" problems that is unfortunately best left out of scope.

## Image Tagging and Updates

- Image on Dockerhub: https://hub.docker.com/r/snw35/cloudenv

Travis CI automatically runs once per week and builds a new image if any updates are found to either the included software or the container base image.

The cloudenv container stays as minimal as possible while packaging a *lot* of tools, some of which are large (Hashicorp ones specifically), and providing a *lot* of functionality. It is possible to provision, manage, and develop production-grade cloud infrastructure with just the contents of this container.

`cloudenv` images are tagged with the ISO-8601 date they were first built (Example: 2018-08-14). The versions of all bundled software packages inside an image are the latest that were available on that date. You can edit the `cloudenv` script to pin the image to a particular date if you'd like.

The `latest` tag always points to the most recent image. Where backwards compatibility is an issue (such as with terraform), both the old and new versions will be included.

The 'cloudenv' script pulls the `latest` tag each time it is run. It does not stop or remove running containers however, so you will only use an updated version when you stop/remove the current container. This will happen after a reboot for example.

## Contributing

To build the container locally,

```sh
docker build -t snw35/cloudenv:latest .
```

To test the locally built image,

```sh
./cloudenv
```

To run with DEBUG mode on,

```sh
export CLOUDENV_DBG=true && ./cloudenv
```


Once your changes are tested, open a pull request with your changes.
