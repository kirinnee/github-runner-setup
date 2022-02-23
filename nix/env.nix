{ nixpkgs ? import <nixpkgs> { } }:
let pkgs = import ./packages.nix { inherit nixpkgs; }; in
with pkgs;
{
  system = [
    coreutils
  ];

  dev = [
    pls
    git
    docker
  ];

  lint = [
    ansible-lint
    hadolint
    nixpkgs-fmt
    prettier
    shfmt
    shellcheck
  ];


}
