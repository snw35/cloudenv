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

  # If we don't have external ID's to use then exit
  if [ -z "${HOST_USER_ID}" ] || [ -z "${HOST_USER_GID}" ]; then
    echo "No external UID or GID set, unable to map IDs to internal container user."
    echo "Running as built-in UID and GID 1000 instead."
    exec su-exec user:user "$@"
  fi

  # Check to see if we already have a user and group with the external ID
  if id -u $HOST_USER_ID >/dev/null 2>&1; then
    internalUser=$(id -un $HOST_USER_ID)
    echo "Matching internal user found, running as $internalUser"
  else
    echo "No matching interneral user found, changing built-in user to match"
    usermod  -u $HOST_USER_ID user
    internalUser="user"
  fi

  if id -g $HOST_USER_GID >/dev/null 2>&1; then
    internalGroup=$(id -gn $HOST_USER_GID)
    echo "Matching internal group found, running as $internalGroup"
  else
    echo "No matchihng internal group found, changing built-in group to match"
    groupmod -g $HOST_USER_GID user
    usermod -g $HOST_USER_GID user
    internalGroup="user"
  fi

  exec su-exec $internalUser:$internalGroup "$@"
fi

# else default to run whatever the user wanted like "bash"
exec "$@"
