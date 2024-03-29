#!/bin/env bash

subnet="$1"

# install required binary to allow for p2p sharing
nix-channel --add https://github.com/kirinnee/test-nix-repo/archive/main.tar.gz atomi-u
nix-channel --update

nix-env -iA nixpkgs.cachix
nix-env -iA nixpkgs.jq
nix-env -iA nixpkgs.sx-go
nix-env -iA atomi-u.nix-share

host=$(hostname)

cd "$HOME" || exit
mkdir -p nix-share
cd nix-share || exit
nix-store --generate-binary-cache-key "$host-1" ./secret ./public

echo "trusted-users = root github-runner" | sudo tee -a /etc/nix/nix.conf && sudo pkill nix-daemon
cachix use kirinnee-sample-binary-cache

secretKeyPath="$(pwd)/secret"
publicKeyPath="$(pwd)/public"

cronContent=$(
	cat <<EndOfMessage
@reboot sudo -u github-runner bash -i -c 'sudo chown -R \$USER /nix'
@reboot sleep 5 && sudo -u github-runner bash -i -c 'nix-shell -p hello --command hello && NIX_SECRET_KEY_FILE=${secretKeyPath} nix run github:edolstra/nix-serve'
@reboot sleep 15 && sudo -u github-runner bash -i -c 'nix-shell -p hello --command hello && cd $HOME/nix-share && nix-share r -c $(pwd)/ns-track.json'
* * * * * sudo -u github-runner bash -i -c 'sudo $(which sx-go) arp --json $subnet | jq -r .ip | while read -r line; do echo "\$line" | nix-share s --host "$(hostname)" "${publicKeyPath}"; done'
* * * * * sudo -u github-runner bash -i -c 'sleep 5 && sudo $(which sx-go) arp --json $subnet | jq -r .ip | while read -r line; do echo "\$line" | nix-share s --host "$(hostname)" "${publicKeyPath}"; done'
* * * * * sudo -u github-runner bash -i -c 'sleep 10 && sudo $(which sx-go) arp --json $subnet | jq -r .ip | while read -r line; do echo "\$line" | nix-share s --host "$(hostname)" "${publicKeyPath}"; done'
* * * * * sudo -u github-runner bash -i -c 'sleep 15 && sudo $(which sx-go) arp --json $subnet | jq -r .ip | while read -r line; do echo "\$line" | nix-share s --host "$(hostname)" "${publicKeyPath}"; done'
* * * * * sudo -u github-runner bash -i -c 'sleep 20 && sudo $(which sx-go) arp --json $subnet | jq -r .ip | while read -r line; do echo "\$line" | nix-share s --host "$(hostname)" "${publicKeyPath}"; done'
* * * * * sudo -u github-runner bash -i -c 'sleep 25 && sudo $(which sx-go) arp --json $subnet | jq -r .ip | while read -r line; do echo "\$line" | nix-share s --host "$(hostname)" "${publicKeyPath}"; done'
* * * * * sudo -u github-runner bash -i -c 'sleep 30 && sudo $(which sx-go) arp --json $subnet | jq -r .ip | while read -r line; do echo "\$line" | nix-share s --host "$(hostname)" "${publicKeyPath}"; done'
* * * * * sudo -u github-runner bash -i -c 'sleep 35 && sudo $(which sx-go) arp --json $subnet | jq -r .ip | while read -r line; do echo "\$line" | nix-share s --host "$(hostname)" "${publicKeyPath}"; done'
* * * * * sudo -u github-runner bash -i -c 'sleep 40 && sudo $(which sx-go) arp --json $subnet | jq -r .ip | while read -r line; do echo "\$line" | nix-share s --host "$(hostname)" "${publicKeyPath}"; done'
* * * * * sudo -u github-runner bash -i -c 'sleep 45 && sudo $(which sx-go) arp --json $subnet | jq -r .ip | while read -r line; do echo "\$line" | nix-share s --host "$(hostname)" "${publicKeyPath}"; done'
* * * * * sudo -u github-runner bash -i -c 'sleep 50 && sudo $(which sx-go) arp --json $subnet | jq -r .ip | while read -r line; do echo "\$line" | nix-share s --host "$(hostname)" "${publicKeyPath}"; done'
* * * * * sudo -u github-runner bash -i -c 'sleep 55 && sudo $(which sx-go) arp --json $subnet | jq -r .ip | while read -r line; do echo "\$line" | nix-share s --host "$(hostname)" "${publicKeyPath}"; done'
EndOfMessage
)

echo "$cronContent" >>mycron
crontab mycron
rm mycron

# shellcheck disable=SC2016
tmux new -s "nix-serve" -d "NIX_SECRET_KEY_FILE=${secretKeyPath} nix run github:edolstra/nix-serve"

# shellcheck disable=SC2016
tmux new -s "nix-share" -d 'cd "$HOME/nix-share" && nix-share r -c "$(pwd)/ns-track.json"'
