use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'WWW::Correios::PrecoPrazo',
    AUTHOR        => 'Breno G. de Oliveira <garu@cpan.org>',
    VERSION_FROM  => 'lib/WWW/Correios/PrecoPrazo.pm',
    ABSTRACT_FROM => 'lib/WWW/Correios/PrecoPrazo.pm',
    PL_FILES      => {},
    PREREQ_PM     => {
        'Test::More'     => 0,
        'LWP::UserAgent' => 0,
        'Const::Fast'    => 0,
        'URI'            => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'WWW-Correios-PrecoPrazo-*' },
);
