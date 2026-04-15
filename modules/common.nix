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

  # nix-ld — stub dynamic linker so unpatched binaries (e.g. nuget tool binaries,
  # grpc protoc) can run without patchelf or FHS wrappers
  programs.nix-ld.enable = true;

  # --- networking ---
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  services.resolved = {
    enable = true;
    settings.Resolve.DNSSEC = "false";
    settings.Resolve.FallbackDNS = [ "1.1.1.1" "8.8.8.8" ];
  };
  # ssh open so we can hop on remotely
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };
  networking.firewall.allowedTCPPorts = [ 22 ];

  # --- bluetooth ---
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

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

  # python 3.11 doc build is broken on nixos-unstable (sphinx/docutils incompatibility)
  # google-cloud-sdk pulls it in — strip the doc output to unblock builds
  nixpkgs.overlays = [
    (final: prev: {
      python311 = prev.python311.overrideAttrs (old: {
        outputs = builtins.filter (o: o != "doc") (old.outputs or [ "out" "lib" ]);
      });
    })
  ];

  # --- fonts ---
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
    inter
    material-symbols
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "Inter" "Noto Sans" ];
      serif     = [ "Noto Serif" ];
      monospace = [ "JetBrainsMono Nerd Font" "Noto Sans Mono" ];
      emoji     = [ "Noto Color Emoji" ];
    };
  };

  # --- packages ---
  environment.systemPackages = with pkgs; [
    # basics
    git
    neovim
    wget
    curl

    # python — withPackages gives a single env; add common libs here
    # for project-specific deps use: python -m venv .venv && source .venv/bin/activate
    (python3.withPackages (ps: with ps; [
      pip setuptools wheel
      requests
      pyyaml
      python-dotenv
    ]))

    # desktop apps
    nautilus
    nautilus-open-any-terminal  # right-click → open terminal
    file-roller                 # archive support (zip, tar, etc.)
    sushi                       # spacebar quick preview
    gvfs                        # trash, network shares, mtp, smb
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
    antigravity
    discord
    # misc
    linux-wallpaperengine
    bitwarden-cli
    (with pkgs.dotnetCorePackages; combinePackages [
      sdk_9_0
      sdk_10_0
    ])
    google-cloud-sdk
    spotify
    pwvucontrol
    gemini-cli
    
  ];

  # gvfs — virtual filesystem daemon for nautilus (trash, network, mtp, smb)
  services.gvfs.enable = true;

  # steam — needs its own module, not just a package, for the fhs env to work right
  programs.steam.enable = true;

  # no ssh agent, using something else for git auth
  programs.ssh.startAgent = false;
}
