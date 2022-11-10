#!/bin/sh

name=$1
url=$2
token=$3
arch=$4
disable_host=$5

host="$(hostname)"
[ "$host" = "" ] && host="random"
full_name="${host}-${name}"
[ "$disable_host" = "true" ] && full_name="${name}"

cd "$HOME" || exit
mkdir actions-runner

cd actions-runner || exit

version=$(curl --silent "https://api.github.com/repos/actions/runner/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
v=$(printf "%s\n" "${version#?}")
curl -o "actions-runner.tar.gz" -L "https://github.com/actions/runner/releases/download/$version/actions-runner-linux-$arch-$v.tar.gz"

tar xzf ./actions-runner.tar.gz
rm ./actions-runner.tar.gz
./config.sh --url "https://github.com/$url" --token "$token" --name "$full_name" --unattended --work "_work" --replace --labels "docker,nix,$arch"
sudo ./svc.sh install "$USER"
sudo ./svc.sh start
