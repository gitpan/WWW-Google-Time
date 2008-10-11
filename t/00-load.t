#!/usr/bin/env perl

use Test::More tests => 14;

BEGIN {
    use_ok('LWP::UserAgent');
    use_ok('URI');
    use_ok('Class::Data::Accessor');
	use_ok( 'WWW::Google::Time' );
}

diag( "Testing WWW::Google::Time $WWW::Google::Time::VERSION, Perl $], $^X" );

can_ok('WWW::Google::Time', qw/new ua error get_time where data/);
my $t = WWW::Google::Time->new;
isa_ok($t, 'WWW::Google::Time');

my $res = $t->get_time('Toronto');
SKIP: {
if ( not defined $res ) {
    ok(defined $t->error, "->error() is defined");
    if ( $t->error =~ /^Could not/ ) {
        BAIL_OUT('Did not find time data when we should have. Module seems to be broken. Please email to zoffix@cpan.org');
    }
    else {
        diag($t->error);
        diag("Network error prevents further testing");
        skip "Not doing any more tests.", 7;
        exit;
    }
}
ok(1);
is( ref $res, 'HASH', "return from get_time() is a hashref");
is( scalar(keys %$res), 4, "hashref has 4 keys");
like( $res->{time}, qr/\d?\d:\d\d\w\w/, "{time} key matches expected format [$res->{time}]");
like( $res->{time_zone}, qr/[A-Z]+/, "{time_zone} key matches expected format [$res->{time_zone}]");

my %days_of_week = map { $_ => 1 } qw/Monday Tuesday Wednesday Thursday Friday Saturday Sunday/;

ok( exists $days_of_week{ $res->{day_of_week} }, "{day_of_week} key contains valid day of the week [$res->{day_of_week}]");

is($res->{where}, 'Toronto, Ontario', "{where} key matches the expected [$res->{where}]");
is($t->where, 'Toronto', "where() method returns the right thing");
}