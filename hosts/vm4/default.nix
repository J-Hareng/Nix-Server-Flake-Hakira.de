{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./server-networking.nix
    ../../modules/a_defaults.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.hostName = "hakira";

  time.timeZone = "Europe/Berlin";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "de-latin1";
  };

  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];

    shell = pkgs.fish;
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/admin/nix-config";
  };

  programs.fish.enable = true;

  virtualisation.docker.enable = true;

  system.stateVersion = "26.05";
}
