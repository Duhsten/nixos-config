# shared system config — this loads on every machine
# hardware-specific stuff (gpu, hostname) lives in hosts/<name>/default.nix
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./zen.nix
  ];

  # --- boot ---
  # using systemd-boot since we're on uefi everywhere
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # --- nix ---
  # gotta have flakes and nix-command enabled
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # --- locale / timezone ---
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT    = "en_US.UTF-8";
    LC_MONETARY       = "en_US.UTF-8";
    LC_NAME           = "en_US.UTF-8";
    LC_NUMERIC        = "en_US.UTF-8";
    LC_PAPER          = "en_US.UTF-8";
    LC_TELEPHONE      = "en_US.UTF-8";
    LC_TIME           = "en_US.UTF-8";
  };

  # --- networking ---
  networking.networkmanager.enable = true;
  # ssh open so we can hop on remotely
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };
  networking.firewall.allowedTCPPorts = [ 22 ];

  # --- audio ---
  # pipewire handles everything — alsa, pulse compat, the works
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- shell ---
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # --- user ---
  users.users.duhsten = {
    isNormalUser = true;
    description = "duhsten";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
    shell = pkgs.zsh;
    packages = with pkgs; [];
  };

  # no password for sudo, living dangerously
  security.sudo.wheelNeedsPassword = false;

  # --- nixpkgs ---
  nixpkgs.config.allowUnfree = true;

  # --- fonts ---
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
    inter
    material-symbols
  ];

  # --- packages ---
  environment.systemPackages = with pkgs; [
    # basics
    git
    neovim
    wget
    curl

    # desktop apps
    nautilus
    ghostty
    vscode
    firefox        # fallback browser, zen is the daily driver
    fastfetch

    # wayland clipboard + screenshot utils
    wl-clipboard
    grim
    slurp

    # dev stuff
    nodejs_20
    codex
    claude-code

    # misc
    bitwarden-cli
  ];

  # steam — needs its own module, not just a package, for the fhs env to work right
  programs.steam.enable = true;

  # no ssh agent, using something else for git auth
  programs.ssh.startAgent = false;
}
