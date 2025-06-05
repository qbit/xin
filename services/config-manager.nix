{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfgMgr = config.configManager;
  cfgRouter = config.configManager.router;
  pfConf = pkgs.writeTextFile {
    name = "pf.conf";
    text = ''
      # Auto generated pf.conf for ${cfgRouter.hostName}

      table <martians> { 0.0.0.0/8 10.0.0.0/8 127.0.0.0/8 169.254.0.0/16     \
      	 	   172.16.0.0/12 192.0.0.0/24 192.0.2.0/24 224.0.0.0/3 \
      	 	   192.168.0.0/16 198.18.0.0/15 198.51.100.0/24        \
      	 	   203.0.113.0/24 }
      # Tables defined in `extraTables`;
      ${cfgRouter.extraTables}

      set block-policy drop
      set loginterface egress
      set skip on lo
      set optimization aggressive

      match in all scrub (no-df random-id max-mss 1440)

      match out on egress inet from !(egress:network) to any nat-to (egress:0)

      block out on vlan10 from !vlan10:network
      block out on vlan6 from !vlan6:network

      antispoof quick for { egress, em, vlan, wg }

      block in quick on egress from <martians> to any
      block return out quick on egress from any to <martians>
      block all

      pass out quick inet

      #pass in on { em1, vlan2, vlan5, vlan6, vlan10, vlan11, wg0  } inet
      pass in on { vlan20, vlan2, vlan5, vlan6, vlan10, vlan11, wg0 } inet

      ${optionalString cfgRouter.pfAllowUnifi ''
        # cfgRouter.pfAllowUnifi.enabled = true;
        pass in on { em1 } inet
        pass proto tcp from em1:network to vlan5:network
      ''}

      pass in on egress proto udp from any to port 7121

      pass proto tcp from vlan20:network to vlan5:network
      pass proto tcp from wg0:network to vlan5:network

      pass in on egress inet proto tcp from any to (egress) port { 80, 443, 2222 } rdr-to 10.20.30.15
      pass in log proto tcp from vlan5:network to (egress) port 2222 divert-to 127.0.0.1 port 2222
      pass in log proto tcp from vlan5:network to (egress) port 443 divert-to 127.0.0.1 port 443
      pass in log proto tcp from vlan5:network to (egress) port 80 divert-to 127.0.0.1 port 80

      anchor "relayd/*"
    '';
  };

  interfaceOptions = mkOptionType { name = "interface text"; };

  interfaceFiles = mapAttrs' (
    name: value:
    nameValuePair "configManager/router/hostname.${name}" {
      text = value.text + "\n";
    }
  ) cfgRouter.interfaces;
in
{
  options = {
    configManager = {
      enable = lib.mkEnableOption "Manage configurations for non-nix machines.";

      router = {
        enable = lib.mkEnableOption "Manage an OpenBSD router.";
        hostName = mkOption {
          type = types.str;
          description = ''
            Host to sync router configs with.
          '';
        };

        extraTables = mkOption {
          type = types.lines;
          default = "";
          description = ''
            Extra pf.conf tables to add to the generated pf.conf.
          '';
        };

        services = mkOption {
          type = types.listOf types.str;
          default = [ ];
          example = [
            "dhcpd"
            "unbound"
          ];
          description = ''
            Services to run on the router (rcctl enable XXX, rcctl start XXX).
          '';
        };

        keepClean = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Keep host configuration clean. This means any non-managed hostname.if files will be
            removed, non-managed services will be stopped and disabled, non-managed packages will
            be removed.. etc.
          '';
        };

        interfaces = mkOption {
          default = { };
          type = types.attrsOf interfaceOptions;
          description = ''
            Interfaces to create hostname.if files for.
          '';
          example = literalExpression ''
            {
              em0 = {
                text = "inet autoconf inet6 autoconf";
              };
              vlan1 {
                text = "inet 10.12.0.1 255.255.255.0 10.12.0.255 vnetid 1 parent em1 up";
              };
            }
          '';
        };

        pfAllowUnifi = mkOption {
          type = types.bool;
          description = ''
            Whether to allow the Ubiquiti Unifi stuff to have access to the greater internet.
          '';
        };
      };
    };
  };

  config = lib.mkIf cfgMgr.enable {
    environment.etc = {
      "configManager/router/pf.conf".text = builtins.readFile pfConf;
      "configManager/router/managed_interfaces".text =
        (concatMapStringsSep "\n") (h: "hostname.${h}") (
          builtins.attrNames config.configManager.router.interfaces
        )
        + "\n";
    } // interfaceFiles;
  };
}
