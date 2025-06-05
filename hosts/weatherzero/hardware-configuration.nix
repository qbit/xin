{ pkgs, ... }:
{
  hardware = {
    deviceTree = {
      enable = true;
      overlays = [ "${pkgs.device-tree_rpi.overlays}/hifiberry-dac.dtbo" ];
    };

    enableRedistributableFirmware = true;
    i2c.enable = true;
    firmware = with pkgs; [
      raspberrypiWirelessFirmware
    ];
  };
}
