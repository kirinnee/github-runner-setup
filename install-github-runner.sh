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
curl -o actions-runner-linux-x64-2.295.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.295.0/actions-runner-linux-x64-2.295.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.295.0.tar.gz
rm actions-runner-linux-x64-2.295.0.tar.gz
./config.sh --url "$url" --token "$token" --name "$full_name" --unattended --work "_work" --replace --labels "docker,nix"
sudo ./svc.sh install "$USER"
sudo ./svc.sh start
