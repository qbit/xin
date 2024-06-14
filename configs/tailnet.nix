{ config
, pkgs
, lib
, inputs
, xinlib
, ...
}:
let
  tailnetACLs =
    let
      acls = {
        hosts = {
          console = "100.83.166.33";
          nbc = "100.74.8.55";
          startpage = "127.0.0.1";
          gitle = "100.111.162.87";
          faf = "100.80.94.131";
          h = "100.83.77.133";
          box = "100.115.16.150";
          pwntie = "100.84.170.57";
          sputnik = "100.78.154.31";
          europa = "100.64.26.122";
          il = "100.86.182.99";
          tv = "100.118.196.38";
        };

        tagOwners = {
          "tag:admin" = [ "autogroup:admin" ];
          "tag:untrusted" = [ "qbit@tapenet.org" ];
          "tag:ro-service" = [ "qbit@tapenet.org" ];
          "tag:mobile" = [ "qbit@tapenet.org" ];
          "tag:laptop" = [ "qbit@tapenet.org" ];
          "tag:internal-server" = [ "qbit@tapenet.org" ];
          "tag:external-server" = [ "qbit@tapenet.org" ];
          "tag:work" = [ "qbit@tapenet.org" ];
          "tag:dns-server" = [ "qbit@tapenet.org" ];
          "tag:openbsd" = [ "qbit@tapenet.org" ];
        };

        acls = [
          {
            # Allow laptops and mobile devices to ssh to everything
            action = "accept";
            src = [ "tag:mobile" "tag:laptop" ];
            dst = [ "*:*" ];
          }
          {
            "action" = "accept";
            "src" = [ "tag:internal-server" "tag:external-server" "tag:work" "tag:laptop" ];
            "dst" = [ "nbc:443" ];
          }
          {
            "action" = "accept";
            "src" = [ "tag:untrusted" "tag:internal-server" ];
            "dst" = [ "tag:ro-service:443" ];
          }
          {
            "action" = "accept";
            "src" = [ "tag:work" ];
            "dst" = [ "console:2222" "startpage:443" ];
          }
          {
            "action" = "accept";
            "src" = [ "tag:openbsd" ];
            "dst" = [ "box:443" ];
          }
          {
            # prometheus
            "action" = "accept";
            "src" = [ "box" ];
            "dst" = [ "h:9002" "pwntie:9002" ];
          }
          {
            # DNS
            "action" = "accept";
            "src" = [ "*" ];
            "dst" = [ "faf:53" ];
            "proto" = "udp";
          }
          {
            # ollama
            "action" = "accept";
            "src" = [ "europa" "h" ];
            "dst" = [ "pwntie:11434" ];
            "proto" = "tcp";
          }
          {
            # jellyfin for tv
            "action" = "accept";
            "src" = [ "tv" ];
            "dst" = [ "box:443" ];
            "proto" = "tcp";
          }
          {
            "action" = "accept";
            "src" = [ "box" ];
            "dst" = [ "tv:8080" "tv:9090" ];
            "proto" = "tcp";
          }
        ];

        tests = [
          {
            # RO service can't access things
            "src" = "tag:ro-service";
            "deny" = [ "tag:laptop:443" "tag:mobile:80" "tag:laptop:22" ];
          }
          {
            "src" = "tag:external-server";
            "deny" = [ "tag:laptop:22" ];
          }
          {
            "src" = "tag:laptop";
            "allow" = [ "tag:ro-service:443" "tag:ro-service:80" "tag:external-server:22" ];
          }
          {
            "src" = "tag:laptop";
            "allow" = [ "qbit@tapenet.org:22" ];
          }
          {
            "src" = "tag:untrusted";
            "deny" = [ "tag:laptop:22" ];
            "allow" = [ "tag:ro-service:443" ];
          }
          {
            "src" = "tag:laptop";
            "allow" = [ "tag:untrusted:22" "tag:untrusted:2222" "tag:work:22" ];
          }
          {
            "src" = "tag:work";
            "deny" = [ "tag:laptop:22" ];
          }

          # Gitle shouldn't be able to access things, but things should access it
          {
            "src" = "gitle";
            "deny" = [ "tag:laptop:22" ];
          }
          {
            "src" = "tag:laptop";
            "allow" = [ "gitle:22" ];
          }
          {
            "src" = "tag:laptop";
            "allow" = [ "faf:53" ];
          }
          {
            "src" = "tag:internal-server";
            "allow" = [ "nbc:443" "tag:ro-service:443" ];
          }
          {
            "src" = "tag:laptop";
            "allow" = [ "h:8967" ];
          }
          {
            "src" = "h";
            "proto" = "udp";
            "allow" = [ "faf:53" ];
          }
          {
            "src" = "tag:openbsd";
            "proto" = "tcp";
            "allow" = [ "box:443" ];
          }
          {
            "src" = "sputnik";
            "proto" = "tcp";
            "allow" = [ "europa:1714" ];
          }
          {
            "src" = "sputnik";
            "proto" = "udp";
            "allow" = [ "europa:1714" ];
          }
          {
            "src" = "europa";
            "proto" = "tcp";
            "allow" = [ "pwntie:11434" ];
          }
          {
            "src" = "tv";
            "proto" = "tcp";
            "allow" = [ "box:443" ];
          }
        ];
      };
    in
    pkgs.writeTextFile {
      name = "tailnet-acls.json";
      text = builtins.toJSON acls;
    };
  aclUpdateScript = pkgs.writeShellScriptBin
    "tailnet-acl-updater"
    ''
      set -eu

      . ${config.sops.secrets.po_env.path}

      JQ=${pkgs.jq}/bin/jq
      PO=${inputs.po.packages.${pkgs.system}.po}/bin/po

      APIURL="https://api.tailscale.com/api/v2/tailnet/-/acl"
      TOKEN="$(cat ${config.sops.secrets.tailnet_acl_manager.path}):"

      ERROR="$(${pkgs.curl}/bin/curl "$APIURL/validate" -u "$TOKEN" -d @${tailnetACLs} | $JQ -r .message)"

      if [ "$ERROR" = "null" ]; then
        RESP="$(${pkgs.curl}/bin/curl "$APIURL" -u "$TOKEN" -d @${tailnetACLs} | $JQ -r .message)"
        if [ "$RESP" != "null" ]; then
          $PO -title "Failed to update TailNet!" -body "$RESP"
        fi
      fi
    '';
  jobs = [
    {
      name = "update-talenet-acls";
      script = "${aclUpdateScript}/bin/tailnet-acl-updater";
      startAt = "*:30:00";
      path = [ ];
      inherit (config.nixManager) user;
    }
  ];
  enabled = config.nixManager.enable;
in
with lib; {
  sops.secrets = mkIf enabled {
    tailnet_acl_manager = {
      owner = config.nixManager.user;
      sopsFile = config.xin-secrets.manager;
    };
    po_env = {
      owner = config.nixManager.user;
      sopsFile = config.xin-secrets.manager;
    };
  };
  systemd.services = mkIf enabled (listToAttrs (builtins.map xinlib.jobToService jobs));
}
