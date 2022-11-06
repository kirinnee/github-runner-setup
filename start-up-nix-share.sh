#!/bin/sh

subnet="$1"

# install required binary to allow for p2p sharing
nix-channel --add https://github.com/kirinnee/test-nix-repo/archive/main.tar.gz atomi-u
nix-channel --update

nix-env -iA nixpkgs.jq
nix-env -iA nixpkgs.sx-go
nix-env -iA atomi-u.nix-share

host=$(hostname)

cd "$HOME" || exit
mkdir nix-share
cd nix-share || exit
nix-store --generate-binary-cache-key "$host-1" ./secret ./public

secretKeyPath="$(pwd)/secret"
publicKeyPath="$(pwd)/public"

cronContent=$(
	cat <<EndOfMessage
@reboot sudo -u github-runner bash -i -c 'NIX_SECRET_KEY_FILE=${secretKeyPath} nix run github:edolstra/nix-serve'
@reboot sudo -u github-runner bash -i -c 'cd "$HOME/nix-share" && nix-share r -c "$(pwd)/ns-track.json"'
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
