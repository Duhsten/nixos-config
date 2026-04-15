# osborne-work — the second machine
# hardware config lives at /etc/nixos/hardware-configuration.nix on that machine
# (generated automatically during nixos install, no need to copy it into the repo)
{ ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
    ../../modules/nvidia.nix
  ];

  networking.hostName = "osborne-work";

  # update this to match whatever the nixos installer set on that machine
  system.stateVersion = "26.05";
}
