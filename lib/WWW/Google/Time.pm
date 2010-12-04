package WWW::Google::Time;

use warnings;
use strict;

our $VERSION = '0.0117';

use LWP::UserAgent;
use URI;
use base 'Class::Data::Accessor';
__PACKAGE__->mk_classaccessors qw/
    error
    data
    where
    ua
/;

sub new {
    my ( $class, %args ) = @_;

    my $self = bless {}, $class;
    $self->ua( $args{ua} || LWP::UserAgent->new( agent => "Mozilla", timeout => 30, ) );

    return $self;
}

sub get_time {
    my ( $self, $where ) = @_;
    my $uri = URI->new("http://google.com/search");

    $self->$_(undef)
        for qw/error data/;

    $self->where( $where );

    $uri->query_form(
        num     => 100,
        hl      => 'en',
        safe    => 'off',
        btnG    => 'Search',
        meta    => '',
        'q'     => "time in $where",
    );
    my $response = $self->ua->get($uri);
    unless ( $response->is_success ) {
        return $self->_set_error( $response, 'net' );
    }

open my $fh, '>', 'out.txt' or die;
print $fh $response->decoded_content.'\n';
close $fh;

    my %data;
    @data{ qw/time day_of_week time_zone where/ } = $response->content
    =~ m{<td\s+style=\"font-size:[^"]+\"><b>([^<]+)<\/b> (\S+) \((\w+)\) - <b>Time<\/b> in (.+?)<(?:\/table|br)>}
#         <td style="font-size:medium"><b>7:26</b> Saturday (EST) - <b>Time</b> in <b>Toronto, ON, Canada</b></table>
    or do {
        return $self->_set_error("Could not find time data for that location");
    };

    $data{where} =~ s{</?em>|</?b>}{}g;

    return $self->data( \%data );
}

sub _set_error {
    my ( $self, $error_or_response, $is_response ) = @_;
    
    if ( $is_response ) {
        $self->error( "Network error: " . $error_or_response->status_line );
    }
    else {
        $self->error( $error_or_response );
    }
    return;
}

1;
__END__

=head1 NAME

WWW::Google::Time - get time for various locations via Google

=head1 SYNOPSIS

    use strict;
    use warnings;

    use WWW::Google::Time;

    my $t = WWW::Google::Time->new;

    $t->get_time("Toronto")
        or die $t->error;

    printf "It is %s, %s (%s) in %s\n",
        @{ $t->data }{ qw/day_of_week  time  time_zone  where/ };

=head1 DESCRIPTION

Module is very simple, it takes a name of some place and returns the current time in that place
(as long as Google has that information).

=head1 CONSTRUCTOR

=head2 C<new>

    my $t = WWW::Google::Time->new;

    my $t = WWW::Google::Time->new(
        ua => LWP::UserAgent->new( agent => "Mozilla", timeout => 30 )
    );

Creates and returns a new C<WWW::Google::Time> object. So far takes one key/value pair argument
- C<ua>. The value of the C<ua> argument must be an object akin to L<LWP::UserAgent> which
has a C<get()> method that returns an L<HTTP::Response> object. The default object for the
C<ua> argument is C<< LWP::UserAgent->new( agent => "Mozilla", timeout => 30 ) >>

=head1 METHODS

=head2 C<get_time>

    $t->get_time('Toronto')
        or die $t->error;

Instructs the object to fetch time information for the given location. Takes one mandatory
argument which is a name of the place for which you want to obtain time data. On failure
returns either undef or an empty list, depending on the context, and the reason for
failure can be obtained via C<error()> method. On success returns a hashref with
the following keys/values:

    $VAR1 = {
          'time' => '7:00am',
          'time_zone' => 'EDT',
          'day_of_week' => 'Saturday',
          'where' => 'Toronto, Ontario'
    };

=head3 C<time>

    'time' => '7:00am',

The C<time> key contains the time for the location as a string.

=head3 C<time_zone>

    'time_zone' => 'EDT',

The C<time_zone> key contains the time zone in which the given location is.

=head3 C<day_of_week>

    'day_of_week' => 'Saturday',

The C<day_of_week> key contains the day of the week that is right now in the location given.

=head3 C<where>

    'where' => 'Toronto, Ontario'

The C<where> key contains the name of the location to which the keys described above correlate.
This is basically how Google interpreted the argument you gave to C<get_time()> method.

=head2 C<data>

    $t->get_time('Toronto')
        or die $t->error;

    my $time_data = $t->data;

Must be called after a successful call to C<get_time()>. Takes no arguments.
Returns the exact same hashref the last call to C<get_time()> returned.

=head2 C<where>

    $t->get_time('Toronto')
        or die $t->error;

    print $t->where; # prints 'Toronto'

Takes no arguments. Returns the argument passed to the last call to C<get_time()>.

=head2 C<error>

    $t->get_time("Some place that doesn't exist")
        or die $t->error;
    ### dies with "Could not find time data for that location"

When C<get_time()> fails (by returning either undef or empty list) the reason for failure
will be available via C<error()> method. The "falure" is both, not being able to find time
data for the given location or network errors. The error message will say which one it is.

=head2 C<ua>

    my $ua = $t->ua;
    $ua->proxy('http', 'http://foobarbaz.com');

    $t->ua( LWP::UserAgent->new( agent => 'Mozilla' ) );

Takes one optional argument which must fit the same criteria as the C<ua> argument to the
contructor (C<new()> method). Returns the object currently beign used for accessing Google.

=head1 EXAMPLES

The C<examples/> directory of this distribution contains an executable script that uses this
module.

=head1 TO DO

Sometimes Google returns multiple times.. e.g. "time in Norway" returns three results.
Would be nice to be able to return all three results in an arrayref or something

=head1 AUTHOR

Zoffix Znet, C<< <zoffix at cpan.org> >>
(L<http://zoffix.com/>, L<http://haslayout.net/>, L<http://zofdesign.com/>)

Patches by Neil Stott and Zach Hauri (L<http://zach.livejournal.com/>)

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-google-time at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Google-Time>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Google::Time

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Google-Time>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-Google-Time>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-Google-Time>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-Google-Time>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2008 Zoffix Znet, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

