# osborne-home — the main desktop, RTX 3060, Intel CPU
# only stuff that's specific to this machine lives here
# shared config is in modules/
{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nvidia.nix
  ];

  networking.hostName = "osborne-home";

  # keep this matching what was set during install
  system.stateVersion = "25.11";
}
