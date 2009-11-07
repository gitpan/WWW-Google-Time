#!/usr/bin/env perl

use strict; 
use warnings;
use lib qw(lib ../lib);
use WWW::Google::Time;

@ARGV
    or die "Use: perl $0 'location of time'\n";

my $t = WWW::Google::Time->new;

$t->get_time(shift)
    or die $t->error;

printf "It is %s, %s (%s) in %s\n",
    @{ $t->data }{ qw/day_of_week  time  time_zone  where/ };


=pod

Usage: perl time.pl 'location of time'

=cut