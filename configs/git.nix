{ config, ... }:
let
  rewriteGitHub =
    if config.networking.hostName != "stan" then
      {
        url = {
          "ssh://git@github.com/" = {
            insteadOf = "https://github.com/";
          };
        };
      }
    else
      {
        url = { };
      };
in
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    config = [
      {
        init = {
          defaultBranch = "main";
        };
      }
      { advice.detachedHead = false; }
      {
        user = {
          name = "Aaron Bieber";
          email = "aaron@bolddaemon.com";
          signingKey = "key::ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOA5iEi4IxSIHXBMdrRlBWHbGtmMNnmBl4qiBPc+eJu9 signer";
        };
      }

      {
        branch = {
          sort = "-committerdate";
        };
      }
      {
        alias = {
          log = "log --color=never";
          diff = "diff --color=always";
          pr = ''!f() { git fetch-pr upstream $1; git checkout pr/$1; }; f'';
          fetch-pr = ''!f() { git fetch $1 refs/pull/$2/head:refs/remotes/pr/$2; }; f'';
        };
      }
      {
        push = {
          default = "current";
        };
      }

      {
        gpg = {
          format = "ssh";
        };
      }
      {
        tag = {
          forceSignAnnotated = true;
        };
      }

      {
        color = {
          branch = false;
          interactive = false;
          log = false;
          status = false;
          ui = false;
        };
      }

      {
        transfer = {
          fsckobjects = true;
        };
      }
      {
        fetch = {
          fsckobjects = true;
        };
      }
      {
        github = {
          user = "qbit";
        };
      }

      { inherit (rewriteGitHub) url; }

      {
        sendemail = {
          smtpserver = "mail.messagingengine.com";
          smtpuser = "qbit@fastmail.com";
          smtpauth = "PLAIN";
          smtpencryption = "tls";
          smtpserverport = 587;
          cc = "git@bolddaemon.com";
          confirm = "auto";
        };
      }

      {
        pull = {
          rebase = false;
        };
      }
      {
        include = {
          path =
            let
              homeDir = config.users.users."${config.defaultUserName}".home;
            in
            "${homeDir}/work/git/gitconfig";
        };
      }
    ];
  };
}
