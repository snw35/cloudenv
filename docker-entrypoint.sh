#!/usr/bin/env bash
set -e

# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "${1:0:1}" = '-' ]; then
    set -- su-exec user:user ssh-agent "$@"
fi

# check if running ssh-agent and run as appropriate user
if [ "$1" = 'ssh-agent' ]; then
  # Use the 'user' user and group as default
  internalUser=user
  internalGroup=user

  # If we don't have external ID's to use then run as default user
  if [ -z "${HOST_USER_ID}" ] || [ -z "${HOST_USER_GID}" ]; then
    echo "No HOST_USER_UID or HOST_USER_GID set, unable to map IDs to internal user and group."
    echo "Running ssh-agent as default internal user and group $internalUser:$internalGroup instead."
    exec su-exec $internalUser:$internalGroup "$@"
  fi

  if id -g $HOST_USER_GID >/dev/null 2>&1; then
    echo "Matching internal group found, running as $internalGroup"
    internalGroup=$(id -gn $HOST_USER_GID)
  else
    echo "No matching internal group found, changing built-in group to match"
    groupadd -g $HOST_USER_GID $internalGroup
  fi

  # Check to see if we already have a user and group with the external ID
  if id -u $HOST_USER_ID >/dev/null 2>&1; then
    echo "Matching internal user found, running as $internalUser"
    internalUser=$(id -un $HOST_USER_ID)
  else
    echo "No matching interneral user found, changing built-in user to match"
    # To avoid issues with large UIDs, delete and re-create the user
    userdel $internalUser
    useradd -l -u $HOST_USER_ID -g $HOST_USER_GID $internalUser
  fi

  echo "Running ssh-agent as $internalUser:$internalGroup"
  exec su-exec $internalUser:$internalGroup "$@"
fi

# else default to run whatever the user wanted like "bash"
exec "$@"
