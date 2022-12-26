inputs: let
  inherit (inputs) self;
  inherit (self.lib) nixosSystem;

  sharedModules = [
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {inherit inputs self;};
        users.I-Want-ToBelieve = ../home/I-Want-ToBelieve;
      };
    }
  ];
in {
  asus = nixosSystem {
    modules =
      [
        ./asus
        {networking.hostName = "asus";}
        inputs.hyprland.nixosModules.default
      ]
      ++ sharedModules;

    specialArgs = {inherit inputs;};
    system = "x86_64-linux";
  };
}
