{ inputs, ... }:

{
  imports = [ inputs.degoog.nixosModules.default ];
  services.degoog = {
    enable = true;

    environment = {
      PORT = "4444";
      DEGOOG_PUBLIC_INSTANCE = false;
      DEGOOG_BIND_ADDRESS = "127.0.0.1";
      DEGOOG_BASE_URL = "https://search.hakira.de";
      DEGOOG_DISTRUST_PROXY = false;
    };
  };
}
