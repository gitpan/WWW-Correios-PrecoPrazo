use 5.008008;
use strict;
use warnings FATAL => 'all';
use inc::Module::Install;

name     'WWW-Correios-PrecoPrazo';
all_from 'lib/WWW/Correios/PrecoPrazo.pm';
author   q{Breno G. de Oliveira <garu@cpan.org>};
license  'artistic';

perl_version 5.008008;

tests_recursive('t');

resources (
   license    => 'http://www.perlfoundation.org/artistic_license_1_0',
   repository => 'https://github.com/garu/WWW-Correios-PrecoPrazo.git',
   bugtracker => 'https://github.com/garu/WWW-Correios-PrecoPrazo/issues',
);

configure_requires (
   'Module::Install' => 0,
);

build_requires (
   'Test::More' => 0,
);

requires (
        'LWP::UserAgent' => 0,
        'Const::Fast'    => 0.012,
        'URI'            => 0,
        'URI::Escape'    => 0,
);

install_as_cpan;
auto_install;
WriteAll;
