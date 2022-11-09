#!/bin/sh

name=$1
url=$2
token=$3
arch=$4

host="$(hostname)"
[ "$host" = "" ] && host="random"
full_name="${host}-${name}"

cd "$HOME" || exit
mkdir actions-runner

cd actions-runner || exit

# obtain token via GH actions
jwt=$(curl --request POST "https://api.github.com/repos/${url}/actions/runners/registration-token" --header "Authorization: token ${token}")
reg_token=$(echo "$jwt" | jq -r '.token')

version=$(curl --silent "https://api.github.com/repos/actions/runner/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
v=$(printf "%s\n" "${version#?}")
curl -o "actions-runner.tar.gz" -L "https://github.com/actions/runner/releases/download/$version/actions-runner-linux-$arch-$v.tar.gz"

tar xzf ./actions-runner.tar.gz
rm ./actions-runner.tar.gz
./config.sh --url "https://github.com/$url" --token "$reg_token" --name "$full_name" --unattended --work "_work" --replace --labels "docker,nix,$arch"
sudo ./svc.sh install "$USER"
sudo ./svc.sh start
