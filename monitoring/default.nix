{ config, ... }:

{
  config = {
    sops.secrets = {
      monit_cfg = {
        sopsFile = config.xin-secrets.deploy;
        owner = "root";
        mode = "400";
      };
    };
    services.monit = {
      enable = true;
      config = builtins.readFile ./monitrc;
    };
  };
}
