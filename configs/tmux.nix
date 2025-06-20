{ ... }:
{
  programs.tmux = {
    enable = true;
    extraConfig = ''
      unbind C-b
      set-option -g prefix C-o

      set-window-option -g mode-keys emacs
      set-window-option -g automatic-rename off
      set-window-option -g base-index 1

      bind-key \\ split-window -h -c '#{pane_current_path}' # vertical pane
      bind-key - split-window -v -c '#{pane_current_path}' # horizontal pane

      bind-key C-r source-file /etc/tmux.conf \; \
      	display-message "source-file done"

      bind-key m set mouse \; \
      	display-message "toggle mouse"

      bind-key C-s set synchronize-panes \; \
      	display-message "toggle synchronize-panes"

      # stolen from jca
      bind o send-prefix
      bind C-o last-window

      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      set -g bell-action any

      set -g default-terminal "tmux-256color"

      set -g set-titles on

      set -g automatic-rename
      set-option -g status-bg colour253
      set-window-option -g clock-mode-colour colour246
      set -g clock-mode-style 12
      set-window-option -g window-status-bell-style fg=white,bg=red

      # Change the default escape-time to 0 (from 500) so emacs will work right
      set -g escape-time 0

      set -g window-status-current-format '#[bg=colour250]#I:#W•'

      set -g status-left '#[fg=green][#[fg=red]#S:#(~/bin/beat)#[fg=black,dim]#[fg=green]] '
      set -g status-right-length 50

      set -g status-right '#[fg=green][#[fg=black]#(basename "#{pane_current_path}")#[fg=green]][#[fg=black]%Y-%m-%d #[fg=black]%I:%M %p#[default]#[fg=green]]'

      set -g window-style 'bg=#DEDEFF'
      set -g window-active-style 'bg=terminal'
    '';
  };
}
