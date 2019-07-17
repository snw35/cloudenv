#!/usr/bin/env bash
set -e

# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "${1:0:1}" = '-' ]; then
    set -- ssh-agent "$@"
fi

# check if running ssh-agent and run as appropriate user and group
if [ "$1" = 'ssh-agent' ]; then

  if [ -z "${HOST_USER_NAME}" ]; then
    echo '$HOST_USER_NAME is not set, defaulting to "user"'
    HOST_USER_NAME=user
  else
    # Clean user name
    CLEAN=${HOST_USER_NAME//_/}
    # Replace spaces with underscores
    CLEAN=${CLEAN// /_}
    # Clean out anything that's not alphanumeric or an underscore
    CLEAN=${CLEAN//[^a-zA-Z0-9_]/}
    # Lowercase with TR
    CLEAN=`echo -n $CLEAN | tr A-Z a-z`
    HOST_USER_NAME=$CLEAN
  fi

  if [ -z "${HOST_GROUP_NAME}" ]; then
    echo '$HOST_GROUP_NAME is not set, defaulting to "group"'
    HOST_GROUP_NAME=group
  else
    # Clean group name
    CLEAN=${HOST_GROUP_NAME//_/}
    # Replace spaces with underscores
    CLEAN=${CLEAN// /_}
    # Clean out anything that's not alphanumeric or an underscore
    CLEAN=${CLEAN//[^a-zA-Z0-9_]/}
    # Lowercase with TR
    CLEAN=`echo -n $CLEAN | tr A-Z a-z`
    HOST_GROUP_NAME=$CLEAN
  fi

  internalUser=$HOST_USER_NAME
  internalGroup=$HOST_GROUP_NAME

  # Use an internal group if one matches, or create one with the correct GID if not
  if [ -z "${HOST_GROUP_ID}" ]; then
    echo '$HOST_GROUP_ID not set, unable to map external and internal GIDs'
    echo 'Using default GID of 1000 instead'
    HOST_GROUP_ID=1000
    groupadd -g $HOST_GROUP_ID $internalGroup
  else
    if id -g $HOST_GROUP_ID >/dev/null 2>&1; then
      internalGroup=$(id -gn $HOST_GROUP_ID)
      echo "Matching internal group found, running as $internalGroup"
    else
      echo "No matching internal group found, creating one..."
      groupadd -g $HOST_GROUP_ID $internalGroup
    fi
  fi

  # Use an internal user if one matches, or create one with the correct UID and GID if not
  if [ -z "${HOST_USER_ID}" ]; then
    echo '$HOST_USER_ID not set, unable to map external and internal UIDs'
    echo 'Using default UID of 1000 instead'
    HOST_USER_ID=1000
    useradd -l -m -s /bin/bash -u $HOST_USER_ID -g $HOST_GROUP_ID $internalUser
  else
    # Use an existing internal user if one matches
    if id -u $HOST_USER_ID >/dev/null 2>&1; then
      internalUser=$(id -un $HOST_USER_ID)
      echo "Matching internal user found, running as $internalUser"
    else
      echo "No matching interneral user found, creating one..."
      useradd -l -m -s /bin/bash -u $HOST_USER_ID -g $HOST_GROUP_ID $internalUser
    fi
  fi

  echo "Running ssh-agent as $internalUser:$internalGroup"
  exec su-exec $internalUser:$internalGroup "$@"
fi

# else default to run whatever the user wanted like "bash"
exec "$@"
