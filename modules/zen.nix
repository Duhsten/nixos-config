# zen browser — firefox-based, sideways tabs, way cleaner ui
# wraps the unwrapped zen package so we can bake in extensions + policies
# extensions auto-install on first launch, no manual clicking around
{ inputs, pkgs, lib, ... }:

let
  # helper to build the extension entry from the addon short id + guid
  # find short id in the addon url on addons.mozilla.org
  # find guid at addons.mozilla.org/api/v5/addons/addon/<short-id>/
  ext = shortId: guid: {
    name = guid;
    value = {
      install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
      installation_mode = "normal_installed";
    };
  };

  extensions = [
    (ext "ublock-origin"              "uBlock0@raymondhill.net")
    (ext "bitwarden-password-manager" "{446900e4-71c2-419f-a6a7-df9c091e268b}")
    (ext "sponsorblock"               "sponsorBlocker@ajay.app")
  ];

  zenPkg = pkgs.wrapFirefox
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser-unwrapped
    {
      extraPolicies = {
        DisableTelemetry = true;
        ExtensionSettings = builtins.listToAttrs extensions;
      };
    };
in
{
  environment.systemPackages = [ zenPkg ];
}
