use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WWW::Google::Time',
    license             => 'perl',
    dist_author         => 'Zoffix Znet <zoffix@cpan.org>',
    dist_version_from   => 'lib/WWW/Google/Time.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'LWP::UserAgent'        => 2.036,
        'URI'                   => 1.35,
        'Class::Data::Accessor' => 0.04001,
        'perl' => '5.006',
    },
    configure_requires => { 'Module::Build' => 0 },
    add_to_cleanup      => [ 'WWW-Google-Time-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
