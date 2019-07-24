# cloudenv

 * [Travis CI: ![Build Status](https://travis-ci.org/snw35/cloudenv.svg?branch=master)](https://travis-ci.org/snw35/cloudenv)

The Cloud Environment Shell ⛅

This is a one-stop "install all" for modern cloud tooling that wraps seamlessly over your existing shell. It provides a suite of infrastructure-as-code (IaC) tools for Amazon AWS, Google GCP, and Kubernetes with no setup required.

## How To Use

The only requirement is to have Docker installed.

Tested and working on both Mac and Linux.

Install the `cloudenv` command:

```shell
sudo curl https://raw.githubusercontent.com/snw35/cloudenv/master/cloudenv -o /usr/local/bin/cloudenv && sudo chmod +x /usr/local/bin/cloudenv;
```

Run the `cloudenv` command and it will pull the latest version of the container image (around 1GB), start the container, and drop you into the cloudenv shell:

`⛅user@cloudenv:~$`

Everything should work as you expect. The bash shell contains common utilities (git, curl, ssh, etc) and all of the installed tools (listed below) with working bash-completion.

If you're using ssh or git, run `ssh-add` and enter your password. This will prevent you from having to enter it every time.

### Included Software

All of the following commands are available:

- aws
- aws-iam-authenticator
- aws-okta
- awsebcli
- bq
- confd
- container-transform
- cookiecutter
- docker-compose
- docker-credential-gcloud
- eb
- ebp
- ecs-cli
- ecs-compose
- fluxctl
- gcloud
- gsutil
- hclfmt
- helm
- k9s
- keychain
- kompose
- kops
- kubectl
- kubectx
- kubens
- kubespy
- okta-awscli
- packer
- rakkess
- terraform (v11, backwards compatible with <= v11)
- terraform-docs
- terraform12 (v12, not backwards compatible)
- terragrunt (v18, backwards compatible with terraform <=v11)
- terragrunt19 (v19, only compatible with terraform v12+)

If something you want is missing, please open an issue or submit a PR, both are welcome!

#### Terraform 12 and Terragrunt 19

By default, running `terragrunt` will give you the terraform v11 and terragrunt v18 stack, which is backwards-compatible with previous versions of both and will work for the majority of existing code.

To run with the new and non-backwards-compatible terraform v12 and terragrunt v19 stack instead, run the following:

```shell
export TERRAGRUNT_TFPATH=/usr/bin/terraform12
terragrunt19 plan-all
```

### Customise The Shell

You can change the shell to fish or a plain bash session that will use your host machine's ~/.bashrc. To do this, edit the `cloudenv` script and change the "user_shell" variable to `fish` or `bash`.

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
3. It runs `ssh-agent` as your user inside the container so it is available to cache ssh credentials if needed.
4. It starts a bash session inside the container as your user with a custom shell configuration (`/etc/bashrc`).
5. When you terminate the bash session, it stops and removes the cloudenv container so there are no left-over processes running.

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

The cloudenv container stays as minimal as possible while packaging a *lot* of tools, some of which are large (Hashicorp ones specifically), and providing a *lot* of functionality. It is possible to provision, manage, and develop production-grade cloud infrastructure with just the contents of this container.

`cloudenv` images are tagged with the ISO-8601 date they were first built (Example: 2018-08-14). The versions of all bundled software packages inside an image are the latest that were available on that date. You can edit the `cloudenv` script to pin the image to a particular date if you'd like.

The `latest` tag always points to the most recent image. Where backwards compatibility is an issue (such as with terraform), both the old and new versions will be included.

The 'cloudenv' script pulls the latest version of the `latest` tag each time it is run, so you will always be running the most recent software.
