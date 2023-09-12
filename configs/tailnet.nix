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
          europa = "100.92.31.80";
          startpage = "100.120.84.116";
          startdev = "100.92.56.119";
          go = "100.117.47.51";
          nbc = "100.122.61.43"; # nix-binary-cache
          console = "100.87.112.70";
          box = "100.120.151.126";
        };

        tagOwners = {
          "tag:untrusted" = [ "qbit@github" ];
          "tag:minservice" = [ "qbit@github" ];
          "tag:sshonly" = [ "qbit@github" ];
          "tag:apper" = [ "qbit@github" ];
          "tag:golink" = [ "qbit@github" ];
          "tag:lab" = [ "qbit@github" ];
        };

        acls = [
          {
            action = "accept";
            src = [ "tag:untrusted" ];
            dst = [
              "europa:22"
              "europa:12304"
              "startpage:443"
              "startdev:443"
              "go:80"
              "tag:lab:22"
              "nbc:443"
            ];
          }
          {
            action = "accept";
            src = [ "tag:minservice" "tag:sshonly" ];
            dst = [ "*:22" "box:3030" "nbc:443" "console:2222" ];
          }
          {
            action = "accept";
            src = [ "qbit@github" ];
            dst = [ "*:*" ];
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
