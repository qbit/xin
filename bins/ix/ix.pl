use strict;
use warnings;

use HTTP::Tiny;
if ( $^O eq "openbsd" ) {
    require OpenBSD::Pledge;
    require OpenBSD::Unveil;

    OpenBSD::Unveil::unveil( "/", "" )                  or die;
    OpenBSD::Pledge::pledge(qw( stdio dns inet rpath )) or die;
}

my $http = HTTP::Tiny->new();

sub slurp {
    my ($fh) = @_;
    local $/;
    <$fh>;
}

sub ix {
    my ($input) = @_;
    my $url     = "http://okturing.com";
    my $form    = [
        a_body => $input,
        submit => "submit",
        fake   => "fake",
        a_func => "add_post"
    ];
    my $resp = $http->post_form( $url, $form )
      or die "could not POST: $!";
    $resp->{content};
}

my $input = slurp('STDIN');
my $out   = ix($input);
foreach my $line ($out) {
    if ( $line =~ m/href="(.+okturing\.com\/src.+\/body)\"/ ) {
        print $1, "\n";
        last;
    }
}
