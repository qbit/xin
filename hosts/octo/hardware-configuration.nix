{ ... }:
{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  hardware.enableRedistributableFirmware = true;

  #hardware.deviceTree = {
  #  overlays = [
  #    #"${pkgs.raspberrypifw}/share/raspberrypi/boot/overlays/rpi-ft5406.dtbo"
  #    {
  #      name = "rpi4-cma-overlay";
  #      dtsText = ''
  #        // SPDX-License-Identifier: GPL-2.0
  #        /dts-v1/;
  #        /plugin/;
  #        / {
  #          compatible = "brcm,bcm2711";
  #          fragment@0 {
  #            target = <&cma>;
  #            __overlay__ {
  #              size = <(512 * 1024 * 1024)>;
  #            };
  #          };
  #        };
  #      '';
  #    }
  #  ];
  #};
}
