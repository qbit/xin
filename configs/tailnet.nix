{
  config,
  pkgs,
  lib,
  inputs,
  xinlib,
  ...
}:
let
  tailnetACLs =
    let
      acls = {
        nodeAttrs = [
          {
            target = [
              "immich"
              "readeck"
              "notify"
              "books"
            ];
            attr = [ "funnel" ];
          }
          {
            target = [
              "tag:laptop"
              "tag:mobile"
            ];
            attr = [
              "drive:access"
            ];
          }
          {
            target = [ "tag:internal-server" ];
            attr = [
              "drive:share"
            ];
          }
          {
            target = [ "namish" ];
            attr = [
              "drive:share"
            ];
          }
        ];
        grants = [
          {
            src = [
              "tag:mobile"
              "tag:laptop"
            ];
            dst = [ "box" ];
            app = {
              "tailscale.com/cap/drive" = [
                {
                  shares = [ "*" ];
                  access = "rw";
                }
              ];
            };
          }
        ];
        hosts = {
          books = "100.112.73.99";
          homeassistant = "100.68.29.6";
          immich = "100.90.44.82";
          box = "100.115.16.150";
          europa = "100.64.26.122";
          hole = "100.104.223.100";
          gitle = "100.111.162.87";
          graphy = "100.76.188.108";
          h = "100.83.77.133";
          il = "100.86.182.99";
          namish = "100.86.184.141";
          nbc = "100.74.8.17";
          plq = "100.90.214.142";
          pwntie = "100.84.170.57";
          rimgo = "100.121.77.91";
          skunk = "100.79.26.78";
          sputnik = "100.78.154.31";
          startpage = "127.0.0.1";
          printy = "100.82.59.95";
          readeck = "100.106.16.7";
          surf = "100.66.209.133";
          lroom = "100.79.194.92";
          notify = "100.79.229.34";
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
          "tag:kdeconnect" = [ "qbit@tapenet.org" ];
          "tag:media-client" = [ "qbit@tapenet.org" ];
          "tag:media-server" = [ "qbit@tapenet.org" ];
        };

        acls =
          let
            mkRange =
              start: stop: entry:
              builtins.map (a: "${entry}:${toString a}") (lib.range start stop);
            mkSet = list: entry: builtins.map (a: "${entry}:${toString a}") list;
          in
          [
            {
              # Allow everything to get to DNS
              action = "accept";
              src = [ "*" ];
              dst = [ "tag:dns-server:53" ];
            }
            {
              # Allow everything to get to the nix-binary-cache
              action = "accept";
              src = [
                "*"
              ];
              dst = [ "nbc:443" ];
              proto = "tcp";
            }
            {
              # Allow laptops and mobile devices to ssh to everything and manage DNS
              action = "accept";
              src = [
                "tag:mobile"
                "tag:laptop"
              ];
              dst = [
                "*:22"
                "tag:dns-server:443"
                "tag:dns-server:80"
              ];
            }
            {
              # IRC
              action = "accept";
              src = [
                "pwntie"
                "tag:mobile"
                "tag:laptop"
              ];
              dst = [ "h:6697" ];
            }
            {
              # HomeAssistant talks to octoprint
              action = "accept";
              src = [
                "homeassistant"
              ];
              dst = [ "printy:443" ];
            }
            {
              # KDEConnect
              action = "accept";
              src = [
                "tag:kdeconnect"
              ];
              dst = mkRange 1714 1764 "tag:kdeconnect";
            }
            {
              # Mosh
              action = "accept";
              src = [
                "tag:laptop"
                "tag:mobile"
              ];
              dst = (mkRange 60000 61000 "h") ++ (mkRange 60000 61000 "pwntie");
              proto = "udp";
            }
            {
              action = "accept";
              src = [
                # OpenBSD connecting to the nginx caching proxy
                "tag:openbsd"
                "tag:internal-server"

                # Other things connecting to 443 for nginx reverse proxy
                "tag:laptop"
                "tag:mobile"
              ];
              dst = [ "box:443" ];
            }
            {
              # Prometheus
              action = "accept";
              src = [
                "box"
              ];
              dst = [
                "h:9002"
                "pwntie:9002"
                "box:9001"
              ];
            }
            {
              # Notifications from specific servers
              action = "accept";
              src = [ "h" ];
              dst = [
                "notify:443"
              ];
              proto = "tcp";
            }
            {
              # Let various devices connect to web services and ssh ports
              action = "accept";
              src = [
                "tag:laptop"
                "tag:mobile"
                "tag:internal-server"
              ];
              dst = [ "tag:untrusted:2222" ] ++ (mkSet [ 80 443 22 2222 ] "tag:ro-service");

              proto = "tcp";
            }
            {
              # Allow media things to talk
              action = "accept";
              src = [ "tag:media-client" ];
              dst = [ "tag:media-server:443" ];
            }
          ];

        tests = [
          {
            # Let media clients get to media servers
            src = "tag:media-client";
            allow = [
              "tag:media-server:443"
            ];
          }
          {
            # h can get to notification stuff, hole for dns and nbc for updates
            src = "h";
            allow = [
              "notify:443"
              "nbc:443"
              "hole:53"
            ];
          }
          {
            # RO service can't access things
            src = "tag:ro-service";
            deny = [
              "tag:laptop:443"
              "tag:mobile:80"
              "tag:laptop:22"
            ];
          }
          {
            # Prevent external server from getting to sensitive things
            src = "tag:external-server";
            deny = [ "tag:laptop:22" ];
          }
          {
            # laptop should be able to access various services
            src = "tag:laptop";
            allow = [
              "gitle:22"
              "pwntie:60000"
              "tag:external-server:22"
              "tag:ro-service:443"
              "tag:ro-service:80"
              "tag:untrusted:22"
              "tag:untrusted:2222"
              "tag:work:22"
            ];
          }
          {
            # laptops can access ssh on anything
            src = "tag:laptop";
            allow = [ "qbit@tapenet.org:22" ];
          }
          {
            # untrusted can't access 22 or 443 on ro-service
            src = "tag:untrusted";
            deny = [
              "tag:laptop:22"
              "tag:ro-service:443"
            ];
          }
          {
            # prevent work machine from coming back in
            src = "tag:work";
            deny = [ "tag:laptop:22" ];
          }
          {
            src = "tag:openbsd";
            proto = "tcp";
            allow = [ "box:443" ];
          }
          {
            src = "sputnik";
            proto = "tcp";
            allow = [ "europa:1714" ];
          }
          {
            src = "sputnik";
            proto = "udp";
            allow = [ "europa:1714" ];
          }
          {
            src = "lroom";
            proto = "tcp";
            allow = [ "box:443" ];
          }
        ];
      };
    in
    pkgs.writeTextFile {
      name = "tailnet-acls.json";
      text = builtins.toJSON acls;
    };
  aclUpdateScript = pkgs.writeShellScriptBin "tailnet-acl-updater" ''
    set -eu

    . ${config.sops.secrets.po_env.path}

    JQ=${pkgs.jq}/bin/jq
    PO=${inputs.po.packages.${pkgs.stdenv.hostPlatform.system}.po}/bin/po

    APIURL="https://api.tailscale.com/api/v2/tailnet/-/acl"
    TOKEN="$(cat ${config.sops.secrets.tailnet_acl_manager.path}):"

    ERROR="$(${pkgs.curl}/bin/curl "$APIURL/validate" -s -u "$TOKEN" -d @${tailnetACLs} | $JQ -r .data)"

    if [ "$ERROR" = "null" ]; then
      RESP="$(${pkgs.curl}/bin/curl "$APIURL" -s -u "$TOKEN" -d @${tailnetACLs} | $JQ -r .message)"
      if [ "$RESP" != "null" ]; then
        $PO -title "Failed to update TailNet!" -body "$RESP"
      fi
    else
      $PO -title "Failed to update TailNet!" -body "$ERROR"
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
with lib;
{
  sops.secrets = mkIf enabled {
    tailnet_acl_manager = {
      owner = config.nixManager.user;
      sopsFile = config.xin-secrets.manager;
    };
  };
  systemd.services = mkIf enabled (listToAttrs (builtins.map xinlib.jobToService jobs));
  environment.systemPackages = mkIf enabled [ aclUpdateScript ];
}
