use Test::More tests => 3;
use strict;
use warnings;

use WWW::Correios::PrecoPrazo;

ok( WWW::Correios::PrecoPrazo->new, 'Construtor Vazio' );
ok( WWW::Correios::PrecoPrazo->new( formato => 'caixa' ),
    'Construtor recebendo Hash' );
ok( WWW::Correios::PrecoPrazo->new( { formato => 'caixa' } ),
    'Construtor recebendo HashRef' );
