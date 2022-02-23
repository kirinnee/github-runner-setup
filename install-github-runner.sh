#!/bin/sh

name=$1
url=$2
token=$3
host="$(hostname)"
[ "$host" = "" ] && host="random"

full_name="${host}-${name}"

cd "$HOME" || exit
mkdir actions-runner
cd actions-runner || exit
curl -o actions-runner-linux-x64-2.287.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.287.1/actions-runner-linux-x64-2.287.1.tar.gz
tar xzf ./actions-runner-linux-x64-2.287.1.tar.gz
rm actions-runner-linux-x64-2.287.1.tar.gz
./config.sh --url "$url" --token "$token" --name "$full_name"  --unattended --disableupdate --work "_work" --replace
tmux new -s "$full_name" -d 'while true; do ./run.sh; done'