# osborne-work — the second machine
{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nvidia.nix
  ];

  networking.hostName = "osborne-work";

  # update this to match whatever the nixos installer set on that machine
  system.stateVersion = "26.05";
}
