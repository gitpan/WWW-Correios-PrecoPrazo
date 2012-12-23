#!perl

use Test::More tests => 4;
use strict;
use warnings;

package LWP::Mock;

sub new { bless {}, 'LWP::Mock' }

sub get {
    my ( $self, $uri ) = @_;
    return {};
}
package main;

use WWW::Correios::PrecoPrazo;

my $cpp = WWW::Correios::PrecoPrazo->new( { user_agent => LWP::Mock->new } );

is_deeply( {}, $cpp->query, 'Query vazia' );
is_deeply( {}, $cpp->query( formato => 'caixa' ), 'Query recebendo Hash' );
is_deeply(
    {},
    $cpp->query( { formato => 'caixa' } ),
    'Query recebendo HashRef'
);

is_deeply(
    {},
    $cpp->query( { formato => 'Batata Baroa' } ),
    'Formato inválido'
);
