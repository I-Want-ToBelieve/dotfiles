{
  pkgs,
  config,
  lib,
  outputs,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  users.mutableUsers = true;
  users.users.I-Want-ToBelieve = {
    description = "Rayhan Pratama";
    isNormalUser = true;
    shell = pkgs.fish;
    initialPassword = "nixos";
    extraGroups =
      [
        "wheel"
        "networkmanager"
        "video"
        "audio"
        "nix"
        "systemd-journal"
      ]
      ++ ifTheyExist [
        "docker"
        "git"
        "libvirtd"
        "mysql"
      ];

    # openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAIaeDlsQNZuf95V5QNjfV8eZncS3J0kV4EWvOlcavjh I-Want-ToBelieve@asus"];
  };
}
