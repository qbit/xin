{ perl }: ''
  #!${perl}/bin/perl

  use strict;
  use warnings;

  use HTTP::Tiny;
  if ($^O eq "openbsd") {
  	require OpenBSD::Pledge;
  	require OpenBSD::Unveil;

  	OpenBSD::Unveil::unveil("/", "") or die;
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
  	my $url = "http://ix.io";
  	my $form = [ 'f:1' => $input ];
  	my $resp = $http->post_form($url, $form)
  		or die "could not POST: $!";
  	$resp->{content};
  }

  my $input = slurp('STDIN');
  my $url = ix($input);
  print $url;
''
