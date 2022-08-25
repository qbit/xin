{ config, lib, ... }: {
  config = {
    programs.zsh.interactiveShellInit = ''
      export NO_COLOR=1
      # That sweet sweet ^W
      WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

      autoload -Uz compinit && compinit

      set -o emacs

    '';
    programs.zsh.promptInit = ''
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

      k() {
        ''${K_DEBUG}
        if [ -z $1 ]; then
          echo $PWD >> ~/.k
        else
          K=~/.k
          case $1 in
            clean)	sort -u $K -o ''${K};;
            rm)	sed -i -E "\#^''${2:-''${PWD}}\$#d" ''${K};;
            ls)	cat ''${K};;
            *)	cd "$(grep -e "$1" ''${K} | head -n 1)";;
          esac
        fi
      }

      eval "$(direnv hook zsh)"
    '';
  };
}
