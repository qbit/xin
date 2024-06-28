#!/usr/bin/env perl

use strict;
use warnings;

use 5.10.0;

use Mojolicious::Lite -signatures;

get '/' => sub ($c) {
    $c->render( text => 'Hello Thing!' );
};

app->start;
