{
  config,
  lib,
  pkgs,
  xinlib,
  ...
}:
let
  myOpenSSH = pkgs.pkgsMusl.callPackage ../pkgs/openssh.nix {
    inherit config;
    inherit xinlib;
  };
in
{
  config = {
    programs = {
      ssh = {
        package = lib.mkDefault myOpenSSH;
        agentPKCS11Whitelist = "${pkgs.opensc}/lib/opensc-pkcs11.so";
        knownHosts = {
          "[namish.otter-alligator.ts.net]:2222".publicKey =
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF9jlU5XATs8N90mXuCqrflwOJ+s3s7LefDmFZBx8cCk";
          "[git.tapenet.org]:2222".publicKey =
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOkbSJWeWJyJjak/boaMTqzPVq91wfJz1P+I4rnBUsPW";
          "[xin-store]".publicKey =
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDQAGLPWFv6f/0Lr0ikgoFP/vUGgd2pQzQOZs3dGMrZg";
        };
        knownHostsFiles = [ ./ssh_known_hosts ];
        startAgent = true;
        agentTimeout = "100m";
        extraConfig = ''
          Host *
            controlmaster         auto
            controlpath           /tmp/ssh-%r@%h:%p
            VerifyHostKeyDNS        yes
            AddKeysToAgent          confirm
            CanonicalizeHostname    always
        '';
      };
    };

    services = {
      openssh = {
        enable = true;
        extraConfig = ''
          TrustedUserCAKeys = /etc/ssh/ca.pub
        '';
        settings = {
          UsePAM = lib.mkDefault false;
          PrintMotd = true;
          PermitRootLogin = "prohibit-password";
          PasswordAuthentication = false;
          KexAlgorithms = [
            "sntrup761x25519-sha512"
            "mlkem768x25519-sha256"
            "curve25519-sha256"
            "curve25519-sha256@libssh.org"
          ];
          Macs = [
            "hmac-sha2-512-etm@openssh.com"
            "hmac-sha2-256-etm@openssh.com"
            "umac-128-etm@openssh.com"
          ];
        };
      };
    };
  };
}
