#!/bin/sh

name=$1
url=$2
token=$3
arch=$4
disable_host=$5
addition_labels=$6

host="$(hostname)"
[ "$host" = "" ] && host="random"
full_name="${host}-${name}"
[ "$disable_host" = "true" ] && full_name="${name}"

tokenType="orgs"
(echo "$url" | grep "\/") && tokenType="repos"

cd "$HOME" || exit
mkdir actions-runner

cd actions-runner || exit

# obtain token via GH actions
jwt=$(curl --request POST "https://api.github.com/${tokenType}/${url}/actions/runners/registration-token" --header "Authorization: Bearer ${token}")
reg_token=$(echo "$jwt" | jq -r '.token')

version=$(curl --silent "https://api.github.com/repos/actions/runner/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
v=$(printf "%s\n" "${version#?}")
curl -o "actions-runner.tar.gz" -L "https://github.com/actions/runner/releases/download/$version/actions-runner-linux-$arch-$v.tar.gz"

tar xzf ./actions-runner.tar.gz
rm ./actions-runner.tar.gz
./config.sh --url "https://github.com/$url" --token "$reg_token" --name "$full_name" --unattended --work "_work" --replace --labels "docker,nix,${arch}${addition_labels}"
sudo ./svc.sh install "$USER"
sudo ./svc.sh start
