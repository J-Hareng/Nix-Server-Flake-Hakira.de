{pkgs, ...}: {
  
  services.radicale = {
    enable = true;
    settings = {
      server.hosts = [ "127.0.0.1:5232" ];

    };
  };
  }
