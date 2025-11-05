{
  pkgs,
  ...
}:
{
  config = {
    environment = {
      systemPackages = [ pkgs.foot ];
      etc."xdg/foot/foot.ini".text = pkgs.lib.generators.toINI { } {
        main = {
          font = "Go Mono:size=11";
        };
        colors = {
          background = "ffffea";
          foreground = "000000";
        };
      };
    };
  };
}
