# cloudenv

 * [Travis CI: ![Build Status](https://travis-ci.org/snw35/cloudenv.svg?branch=master)](https://travis-ci.org/snw35/cloudenv)

The Cloud Environment Shell ⛅

This is a one-stop "install all" for modern cloud tooling that wraps seamlessly over your existing shell. It provides a suite of tools for AWS and GCP and makes them all accessible from a single command.

## How To Use

The only requirement is to have Docker installed (the docker-ce package on most distros).

Clone the repo and install the 'cloudenv' command into your path.

```shell
git clone https://github.com/snw35/cloudenv.git
sudo cp ./cloudenv/cloudenv /usr/local/bin/cloudenv
sudo chmod +x /usr/local/bin/cloudenv
cloudenv
```

After running 'cloudenv', the container image will be pulled down to your machine and you will be dropped into the cloudenv bash shell:

`⛅user@cloudenv:~$`

Everything should work as you expect. The bash shell contains common utilities (git, curl, ssh, etc) as well as all of the installed tools, and has working bash-completion for them too.

If you're using ssh or git, run `ssh-add` and enter your password. This will prevent you from having to enter it every time.

### Included Software

All of the following commands are available:

- aws-iam-authenticator
- aws-okta
- awscli
- awsebcli
- confd
- container-transform
- ecs-cli
- ecs-compose
- gcloud
- gsutil
- hclfmt
- helm
- kubectl
- kubectx
- kubens
- okta-awscli
- packer
- terraform (v11, backwards compatible with <= v11)
- terraform12 (v12, not backwards compatible)
- terraform-docs
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

1. The script pulls and starts the cloudenv Docker container on your machine.
2. It bind-mounts your home directory into the container, passes your user and group IDs from the host machine into the container, and ensures the UID and GID in the container match up.
3. It runs `ssh-agent` as your user inside the container so it is available to cache ssh credentials if needed.
4. It starts a bash session inside the container as your user with a custom shell configuration (`/etc/bashrc`).
5. When you terminate the bash session, it stops and removes the cloudenv container so there are no left-over processes running.

Further information on some of these aspects is below.

#### Bind-Mounting The Home Directory

Your home directory is bind-mounted into the container in place of the built-in user's home directory. This allows access to your files as well as all of your dot-files and dot-directories, such as `~/.ssh`, which contain all of the configuration for those utilities.

This allows the environment inside the container to behave as closely as possible to the environment on the host, and means that all of the included tools have access to the keys/credentials that they may require.

#### UserID and GroupID Mapping

One of the biggest problems with bind-mounting your home directory into a running container is permissions. The built-in user "user" has a default UID and GID of 1000 inside the container, but your user on the host can have any UID and GID.

If they have different ID's, then you won't be able to access your files.

The way this is overcome is by passing the UID and GID of the host's user into the container when it is started, and then ensuring that all processes and bash sessions started inside it have that same UID and GID. It will use an existing user inside the container if it finds one that matches, or modify the built-in user's UID and GID if it doesn't.

#### Timezones

The timezone inside an Alpine container defaults to UTC. Normally this is fine, but when your home directory is bind-mounted into the image in read-write mode, the timestamps on files will be incorrect if anything inside the container modifies them.

An environment variable (`TZ`) is used to set the timezone when the container starts up. The value is set in the cloudenv script and can be changed to match your requirements. Detecting the user's timezone cross-platform is one of those "this shouldn't be this hard" problems that is unfortunately best left out of scope.
