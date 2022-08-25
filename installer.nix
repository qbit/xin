{ config, lib, options, pkgs, ... }:

let
  managementKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDM2k2C6Ufx5RNf4qWA9BdQHJfAkskOaqEWf8yjpySwH Nix Manager";
in {
  imports = [ ./configs/colemak.nix ./configs/tmux.nix ./configs/neovim.nix ];

  options.myconf = {
    hwPubKeys = lib.mkOption rec {
      type = lib.types.listOf lib.types.str;
      default = [
        managementKey
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIB1cBO17AFcS2NtIT+rIxR2Fhdu3HD4de4+IsFyKKuGQAAAACnNzaDpsZXNzZXI="
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDEKElNAm/BhLnk4Tlo00eHN5bO131daqt2DIeikw0b2AAAABHNzaDo="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBB/V8N5fqlSGgRCtLJMLDJ8Hd3JcJcY8skI0l+byLNRgQLZfTQRxlZ1yymRs36rXj+ASTnyw5ZDv+q2aXP7Lj0="
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIHrYWbbgBkGcOntDqdMaWVZ9xn+dHM+Ap6s1HSAalL28AAAACHNzaDptYWlu"
      ];
      example = default;
      description = "List of hardwar public keys to use";
    };
    zshPrompt = lib.mkOption rec {
      type = lib.types.lines;
      example = default;
      description = "Base zsh prompt";
      default = ''
        autoload -U promptinit && promptinit
        autoload -Uz vcs_info
        autoload -Uz colors && colors

        setopt prompt_subst
        #setopt prompt_sp

        zstyle ':vcs_info:*' enable git hg cvs
        zstyle ':vcs_info:*' get-revision true
        zstyle ':vcs_info:git:*' check-for-changes true
        zstyle ':vcs_info:git:*' formats '(%b)'

        precmd_vcs_info() { vcs_info }
        precmd_functions+=( precmd_vcs_info )

        prompt_char() {
          if [ -z "$IN_NIX_SHELL" ]; then
            echo -n "%#"
          else
            echo -n ";"
          fi
        }

        PROMPT='%n@%m[%(?.%{$fg[default]%}.%{$fg[red]%})%?%{$reset_color%}]:%~$vcs_info_msg_0_$(prompt_char) '

        eval "$(direnv hook zsh)"

      '';
    };
    zshConf = lib.mkOption rec {
      type = lib.types.lines;
      example = default;
      description = "Base zsh config";
      default = ''
        export NO_COLOR=1
        # That sweet sweet ^W
        WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

        autoload -Uz compinit && compinit

        set -o emacs

      '';
    };
  };

  config = {
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    # from https://github.com/dylanaraps/neofetch
    users.motd = ''

                ::::.    ':::::     ::::'
                ':::::    ':::::.  ::::'
                  :::::     '::::.:::::
            .......:::::..... ::::::::
           ::::::::::::::::::. ::::::    ::::.
          ::::::::::::::::::::: :::::.  ::::'
                 .....           ::::' :::::'
                :::::            '::' :::::'
       ........:::::               ' :::::::::::.
      :::::::::::::                 :::::::::::::
       ::::::::::: ..              :::::
           .::::: .:::            :::::
          .:::::  .....
          :::::   :::::.  ......:::::::::::::'
           :::     ::::::. ':::::::::::::::::'
                  .:::::::: '::::::::::
                 .::::'''::::.     '::::.
                .::::'   ::::.     '::::.
               .::::      ::::      '::::.

    '';
    boot.cleanTmpDir = true;

    environment.systemPackages = with pkgs; [ apg inetutils nixfmt ];

    environment.interactiveShellInit = ''
      alias vi=nvim
    '';

    time.timeZone = "US/Mountain";

    programs = {
      zsh.enable = true;
      ssh = {
        startAgent = true;
        extraConfig = "";
      };
    };

    users.users.root = {
      openssh.authorizedKeys.keys = config.myconf.hwPubKeys;
    };

    services = {
      openntpd.enable = true;
      pcscd.enable = true;
      openssh = {
        enable = true;
        # This is set in modules/profiles/installation-device.nix, but it is set to 'yes' :(
        #permitRootLogin = "prohibit-password";
        passwordAuthentication = false;
      };
    };
  };
}
