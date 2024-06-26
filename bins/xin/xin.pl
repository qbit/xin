#!/usr/bin/env perl

use strict;
use warnings;

use v5.38;
use feature "switch";

use MIME::Base64;
use JSON qw{ decode_json encode_json };

my $VERSION = 'v0.0.1';

my @command_list;
my @ssh_cmd;

if ( defined $ENV{SSH_ORIGINAL_COMMAND} ) {
    @ssh_cmd = split( " ", $ENV{SSH_ORIGINAL_COMMAND} );
    shift @ssh_cmd;
}

if ( @ARGV > @ssh_cmd ) {
    @command_list = @ARGV;
}
else {
    @command_list = @ssh_cmd;
}

my $command = shift @command_list || "status";

sub is_root {
    my $cmd = shift;
    if ($<) {
        say "$cmd: must be run as root";
        exit 1;
    }
}

if ( $command =~ /^status$/ ) {
    my $info = decode_json(`nixos-version --json`);
    $info->{needs_restart} =
      system('check-restart >/dev/null') == 0 ? JSON::false : JSON::true;
    my $sys_diff =
      `nix store diff-closures /run/booted-system /run/current-system`;
    $sys_diff =~ s/\e\[[0-9;]*m(?:\e\[K)?//g;

    $info->{system_diff} = encode_base64($sys_diff);
    $info->{uname_a}     = `uname -a`;
    $info->{uptime}      = `uptime`;
    $info->{ssh_command} = $ENV{SSH_ORIGINAL_COMMAND} || "NO COMMAND PASSED";

    chomp $info->{uname_a};
    chomp $info->{uptime};

    print encode_json $info;
}
elsif ( $command =~ /^update$/ ) {
    is_root("update");
    exit system(qq{nixos-rebuild switch --flake github:qbit/xin --refresh});
}
elsif ( $command =~ /^ci$/ ) {
    if (   -e "/etc/systemd/system/xin-ci.service"
        && -e "/etc/systemd/system/xin-ci-update.service" )
    {
        my $subcmd = shift @command_list || "status";
        if ( $subcmd =~ /^start$/ ) {
            exit system(qq{systemctl start xin-ci.service});
        }
        elsif ( $subcmd =~ /^update$/ ) {
            exit system(qq{systemctl start xin-ci-update.service});
        }
        else {
            say "unknown subcommand: $subcmd";
            exit 1;
        }
    }
    else {
        say "not running on ci machine";
        exit 1;
    }
}
elsif ( $command =~ /^reboot$/ ) {
    is_root("reboot");
    exit system("reboot");
}
else {
    say "unknown command: $command";
    exit 1;
}
