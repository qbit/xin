{ tmux }:
let tmuxBin = "${tmux}/bin/tmux";
in ''
  #!/usr/bin/env sh

  set -e

  SNAME="Main"
  SSES="-s $SNAME"
  IDX=1

  if ${tmuxBin} ls | grep -q "^''${SNAME}:"; then
    ${tmuxBin} -u2 at -t "$SNAME"
  else
    ${tmuxBin} -2 new-session -d $SSES
    if [ -e ~/.tmux.windows ]; then
      count=$IDX
      for n in $(cat ~/.tmux.windows); do
        if [ $n == "_" ]; then
          ${tmuxBin} new-window
        else
          if [ $count -eq $IDX ]; then
            ${tmuxBin} rename-window "$n"
          else
            ${tmuxBin} new-window -n "$n"
          fi
        fi
        ((count=count+1))
      done
    else
      ${tmuxBin} rename-window "IRC"
      ${tmuxBin} new-window -n "Mail"
      ${tmuxBin} new-window -n "Misc"
      ${tmuxBin} new-window
    fi
    ${tmuxBin} select-window -t$IDX
    ${tmuxBin} -2 attach-session -t $SNAME
  fi
''
