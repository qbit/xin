{ config, lib, ... }:

with lib; {
  options = {
    buildConsumer = { enable = mkEnableOption "Use remote build machines"; };
  };

  config = mkIf config.buildConsumer.enable {
    programs.ssh.knownHosts = {
      pcake = {
        hostNames = [ "pcake" "pcake.tapenet.org" "10.6.0.202" ];
        publicKey =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHgqVw3QWNG6Ty5o2HwW+25Eh59W3lZ30+wMqTEkUZVH";
      };
    };
    programs.ssh.extraConfig = ''
      Host pcake
      	HostName 10.6.0.202
      	IdentitiesOnly yes
      	IdentityFile /root/.ssh/nix_remote
    '';
    nix.buildMachines = [{
      hostName = "pcake";
      systems = [ "x86_64-linux" "aarch64-linux" ];
      maxJobs = 2;
      speedFactor = 4;
      supportedFeatures = [ "kvm" "big-parallel" "nixos-test" "benchmark" ];
      mandatoryFeatures = [ ];
    }];

    nix.distributedBuilds = true;
    nix.extraOptions = ''
      builders-use-substitutes = true
    '';
  };
}
