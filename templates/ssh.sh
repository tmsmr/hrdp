#!/usr/bin/env bash

BASE_FOLDER=$(dirname "$0")/..

ssh -i "$BASE_FOLDER/session/id_ecdsa" -o UserKnownHostsFile="$BASE_FOLDER/session/known_hosts" hrdp@${node_ip} "$@"
