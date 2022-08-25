{ config, lib, pkgs, ... }: {
  #environment.systemPackages = with pkgs; [ gitmux ];
  environment.etc."gitmux.conf" = {
    text = ''
      tmux:
          symbols:
              branch: '⎇ '
              hashprefix: ':'
              ahead: ↑·
              behind: ↓·
              staged: '● '
              conflict: '✖ '
              modified: '✚ '
              untracked: '… '
              stashed: '⚑ '
              clean: ✔
          styles:
              clear: '#[fg=default]'
              state: '#[fg=default]'
              branch: '#[fg=default]'
              remote: '#[fg=default]'
              staged: '#[fg=default]'
              conflict: '#[fg=default]'
              modified: '#[fg=default]'
              untracked: '#[fg=default]'
              stashed: '#[fg=default]'
              clean: '#[fg=default]'
              divergence: '#[fg=default]'
          layout: [branch, .., remote-branch, divergence, ' - ', flags]
          options:
              branch_max_len: 0
              branch_trim: right
    '';
  };
}
