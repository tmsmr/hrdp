#!/usr/bin/env bash

set -e

BASE_FOLDER=$(dirname "$0")/..
SSH_SESSION_SOCK="$BASE_FOLDER/session/${node_ip}.sock"

if [[ "$1" == "stop" ]]; then
  if test -S "$SSH_SESSION_SOCK"; then
    echo "stopping xrdp tunnel"
    ssh -S "$SSH_SESSION_SOCK" -O exit hrdp@${node_ip}
  else
    echo "xrdp tunnel not started or broken"
  fi
  exit 0
fi

if ! test -S "$SSH_SESSION_SOCK"; then
  echo "starting xrdp tunnel"
  ssh -M -S "$SSH_SESSION_SOCK" -i "$BASE_FOLDER/session/id_ecdsa" -o UserKnownHostsFile="$BASE_FOLDER/session/known_hosts" -f -N -T hrdp@${node_ip} -L 3389:localhost:4489
else
  echo "xrdp tunnel exists already"
fi

if nc -z localhost 3389 &>/dev/null; then
  echo "xrdp socket available at localhost:3389"
  echo
  pushd "$BASE_FOLDER" >/dev/null
  printf "host\t\t%s\nusername\t%s\npassword\t%s\ncert SHA-1\t%s\n" \
    "localhost:3389" \
    "hrdp" \
    "$(terraform output -raw xrdp_pass)" \
    "$(terraform output -raw xrdp_cert_sha1)"
  popd >/dev/null
else
  echo "xrdp socket NOT available"
fi
