{ config, ... }:
let
  rewriteGitHub = if config.networking.hostName != "stan" then {
    url = { "ssh://git@github.com/" = { insteadOf = "https://github.com/"; }; };
  } else {
    url = { };
  };

in {
  programs.git = {
    enable = true;
    lfs.enable = true;
    config = [
      { init = { defaultBranch = "main"; }; }

      {
        user = {
          name = "Aaron Bieber";
          email = "aaron@bolddaemon.com";
          signingKey =
            "key::sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIB1cBO17AFcS2NtIT+rIxR2Fhdu3HD4de4+IsFyKKuGQAAAACnNzaDpsZXNzZXI=";
        };
      }

      { branch = { sort = "-committerdate"; }; }
      {
        alias = {
          log = "log --color=never";
          diff = "diff --color=always";
          pr = ''"!f() { git fetch-pr upstream $1; git checkout pr/$1; }; f"'';
          fetch-pr = ''
            "!f() { git fetch $1 refs/pull/$2/head:refs/remotes/pr/$2; }; f"'';
        };
      }
      { push = { default = "current"; }; }

      { gpg = { format = "ssh"; }; }
      { commit = { gpgsign = true; }; }

      {
        color = {
          branch = false;
          interactive = false;
          log = false;
          status = false;
          ui = false;
        };
      }

      { safe = { directory = "/home/qbit/src/nix-conf"; }; }

      { transfer = { fsckobjects = true; }; }
      { fetch = { fsckobjects = true; }; }
      { github = { user = "qbit"; }; }

      { inherit (rewriteGitHub) url; }

      {
        sendmail = {
          smtpserver = "mail.messagingengine.com";
          smtpuser = "qbit@fastmail.com";
          smtpauth = "PLAIN";
          smtpencryption = "tls";
          smtpserverport = 587;
          cc = "aaron@bolddaemon.com";
          confirm = "auto";
        };
      }

      { pull = { rebase = false; }; }
      { include = { path = "~/work/git/gitconfig"; }; }
    ];
  };
}

