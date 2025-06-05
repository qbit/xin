{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    neomutt
    urlview
  ];
  environment.etc."neomuttrc" = {
    text = ''
      ignore *
      unignore from: subject to cc date x-mailer x-url user-agent

      set from = "aaron@bolddaemon.com"
      set realname = "Aaron Bieber"

      set imap_user = "qbit@fastmail.com"
      set imap_pass = `cat /run/secrets/fastmail`

      set smtp_url = "smtps://$imap_user@mail.messagingengine.com"
      set smtp_pass = $imap_pass

      set folder = "imaps://mail.messagingengine.com:993"
      set spoolfile = "+INBOX"

      set header_cache = ~/.mutt/cache/fm/headers
      set message_cachedir = ~/.mutt/cache/fm/bodies

      folder-hook . set from="aaron@bolddaemon.com"

      unmailboxes *
      named-mailboxes Inbox "=INBOX"
      named-mailboxes git "=INBOX.git"
      named-mailboxes OpenBSD/ "=INBOX.OpenBSD"
      named-mailboxes OpenBSD/Hackers "=INBOX.OpenBSD.Hackers"
      named-mailboxes OpenBSD/Tech "=INBOX.OpenBSD.Tech"
      named-mailboxes OpenBSD/Ports "=INBOX.OpenBSD.Ports"
      named-mailboxes OpenBSD/GOT "=INBOX.OpenBSD.GOT"
      named-mailboxes OpenBSD/Bugs "=INBOX.OpenBSD.Bugs"
      named-mailboxes OpenBSD/Misc "=INBOX.OpenBSD.Misc"
      named-mailboxes OpenBSD/ARM "=INBOX.OpenBSD.Arm"
      named-mailboxes OpenBSD/PPC "=INBOX.OpenBSD.ppc"
      named-mailboxes OpenBSD/src-ch "=INBOX.OpenBSD.src-changes"
      named-mailboxes OpenBSD/ports-ch "=INBOX.OpenBSD.ports-changes"
      named-mailboxes 9front "=INBOX.9front"
      named-mailboxes OSS-Sec "=INBOX.OSS-Sec"
      named-mailboxes Archive "=INBOX.Archive"
      named-mailboxes Sent "=INBOX.Sent Items"
      named-mailboxes Drafts "=INBOX.Drafts"
      named-mailboxes Trash "=INBOX.Trash"
      named-mailboxes JunkCan "=INBOX.JunkCan

      set editor = "nvim"

      set certificate_file = ~/.mutt/certificates

      set mail_check = 120
      set mail_check_stats = yes
      set timeout = 300
      set imap_keepalive = 300
      set imap_passive
      set imap_check_subscribed = yes
      set ispell = "aspell --mode=email --add-email-quote=%,#,:,} --check"
      set message_cache_clean = yes
      set user_agent = no
      set smart_wrap = yes

      set attach_format="%u%D%I %t%2n %T%.20d  %> [%.7m/%.10M, %.6e%?C?, %C?, %s]                               "
      set date_format="!%a, %d %b %Y at %H:%M:%S %Z"
      set forward_format="fwd: %s"
      set index_format="%[%m-%d] [%Z] %-54.54s %F"
      set pager_format=" %f: %s"
      set sidebar_format="%B%*  %?N?(%N)?"
      set status_format=" %h: %f (msgs:%?M?%M/?%m %l%?n? new:%n?%?o? old:%o?%?d? del:%d?%?F? flag:%F?%?t? tag:%t?%?p? post:%p?%?b? inc:%b?%?l??) %> %_v "

      set move = no

      set askcc

      set sort = 'threads'
      set sort_aux = 'last-date-received'

      set mailcap_path="~/.mailcap"

      set sidebar_visible = yes
      set sidebar_width = 30
      set sidebar_format = "%B%?F? [%F]?%* %?N?%N/?%S"

      bind index,pager \Ck sidebar-prev
      bind index,pager \Cj sidebar-next
      bind index,pager \Co sidebar-open

      set pager_index_lines=10

      set spoolfile = "="
      set record="=INBOX.Sent Items"
      set postponed="=INBOX.Drafts"
      set trash = "=INBOX.Trash"

      mono attachment bold
      mono body underline "(https?|t?ftp|mailto|gopher|ssh|telnet|finger)://[^ ]+"
      mono body underline "[-a-z_0-9.]+@[-a-z_0-9.]+[a-z]"      # email addresses
      mono body bold "-----Original Message-----"
      mono body bold "[;:]-[)/(|]"
      mono header none .
      mono header bold "^From: "
      mono header bold "^Resent-From: "
      mono header bold "^To: "
      mono header bold "^Subject: "
      mono header bold "^Organi[zs]ation: "
      mono header bold "^Priority: Urgent"
      mono header bold "^Importance: high"
      mono index bold '~U'
      mono index bold '~F'
      mono signature bold
      mono tilde bold
      mono tree bold
      mono quoted bold

      color normal default default
      color attachment brightdefault default
      color body brightdefault default "(http|https|ftp|mailto|gopher|telnet|finger)://[^ ]+"
      color body brightdefault default "[-a-z_0-9.]+@[-a-z_0-9.]+[a-z]"
      color body brightdefault default "-----Original Message-----"
      color body brightdefault default "[;:]-[)/(|]"
      color header default default .
      color header brightdefault default "^From: "
      color header brightdefault default "^Resent-From: "
      color header brightdefault default "^To: "
      color header brightdefault default "^Subject: "
      color header brightdefault default "^Organi[zs]ation: "
      color header brightdefault default "^Priority: Urgent"
      color header brightdefault default "^Importance: high"
      color header brightdefault default '~U'
      color header brightdefault default '~F'
      color signature brightdefault default
      color tilde brightblack default
      color quoted brightblack default

      color index red default '~F'
      color index brightblack default '~D'
      color index default default '~U'
      color index red default '~z 500000-'

      # make diffs pop
      color body	brightblack	default '^(Index: |\+\+\+ |--- |diff ).*$'
      color body	red		default '^-.*$'
      color body	green		default '^\+.*$'
    '';
  };
}
