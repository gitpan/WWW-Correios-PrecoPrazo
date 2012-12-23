package WWW::Correios::PrecoPrazo;

use strict;
use warnings;

use Const::Fast;
use URI;

our $VERSION = '0.000002';

const our %INPUT_KEYS => (
    'codigo_empresa'    => 'nCdEmpresa',
    'senha'             => 'sDsSenha',
    'codigo_servico'    => 'nCdServico',
    'cep_origem'        => 'sCepOrigem',
    'cep_destino'       => 'sCepDestino',
    'peso'              => 'nVIPeso',
    'formato'           => 'nCdFormato',
    'comprimento'       => 'nVlComprimento',
    'altura'            => 'nVlAltura',
    'largura'           => 'nVlLargura',
    'diametro'          => 'nVlDiametro',
    'mao_propria'       => 'sCdMaoPropria',
    'valor_declarado'   => 'nVlValorDeclarado',
    'aviso_recebimento' => 'sCdAvisoRecebimento',
    'formato_retorno'   => 'StrRetorno',
);

const our %OUTPUT_KEYS => (
    'entrega_domiciliar'      => 'EntregaDomiciliar',
    'erro'                    => 'Erro',
    'valor'                   => 'Valor',
    'msg_erro'                => 'MsgErro',
    'valor_mao_propria'       => 'ValorMaoPropria',
    'prazo_entrega'           => 'PrazoEntrega',
    'codigo_servico'          => 'Codigo',
    'valor_declarado'         => 'ValorValorDeclarado',
    'valor_aviso_recebimento' => 'ValorAvisoRecebimento',
    'entrega_sabado'          => 'EntregaSabado',
);

const our %DEFAULTS => (
    'codigo_empresa'    => '',
    'senha'             => '',
    'codigo_servico'    => '40010',
    'cep_origem'        => '',
    'cep_destino'       => '',
    'peso'              => 0.1,
    'formato'           => 'caixa',
    'comprimento'       => 16,
    'altura'            => 2,
    'largura'           => 11,
    'diametro'          => 5,
    'mao_propria'       => 'N',
    'valor_declarado'   => '0',
    'aviso_recebimento' => 'N',
    'formato_retorno'   => 'XML',
    'base_url' => 'http://ws.correios.com.br/calculador/CalcPrecoPrazo.aspx',
);

const our %PACKAGING_FORMATS => (
    'caixa'    => 1,
    'pacote'   => 1,
    'rolo'     => 2,
    'prisma'   => 2,
    'envelope' => 3,
);

sub new {
    my $class = shift;
    my $args  = ref $_[0] ? $_[0] : {@_};
    my $atts  = {
        user_agent => _init_user_agent($args),
        map { $_ => $args->{$_} || $DEFAULTS{$_} } keys %DEFAULTS,
    };

    return bless $atts, $class;
}

sub query {
    my $self = shift;
    my $args = ref $_[0] ? $_[0] : {@_};

    my $params = {
        map { $INPUT_KEYS{$_} => $args->{$_} || $self->{$_} }
          keys %INPUT_KEYS
    };

    $params->{ $INPUT_KEYS{formato} } =
      exists $args->{formato}
      ? _pkg_format_code( $args->{formato} )
      : _pkg_format_code( $self->{formato} );

    my $uri = URI->new( $self->{base_url} );
    $uri->query_form($params);

    return $self->{user_agent}->get( $uri->as_string );
}

sub _init_user_agent {
    my $args = shift;

    my $ua = $args->{user_agent};

    unless ($ua) {
        require LWP::UserAgent;
        $ua = LWP::UserAgent->new;
    }

    return $ua;
}

sub _pkg_format_code {
    my $format = shift;

    return exists $PACKAGING_FORMATS{$format} ? $PACKAGING_FORMATS{$format} : 1;
}

1;

__END__

=head1 NAME

WWW::Correios::PrecoPrazo - Serviço de cálculo de preços e prazos de entrega
de encomendas (Brazilian Postal Object Tracking Service)

=head1 DESCRIPTION

This module provides a way to query the Brazilian Postal Office (Correios) via
WebService, regarding fees and deadlines. Since the main target for this module
is Brazilian developers, the documentation is provided in portuguese only. If
you need help with this module please contact the author.

=head1 DESCRIÇÃO

Os Correios oferecem uma API destinada a qualquer um que deseje calcular,
de forma personalizada, o preço e o prazo de entrega de uma encomenda.

Os preços apresentados são os mesmos praticados no balcão da agência, a menos
que você possua contrato de SEDEX, e-SEDEX ou PAC. Nesses casos, você pode
informar código da empresa e senha e solicitar consultas com contrato.

Este módulo visa ser extremamente leve a fim de não introduzir dependências
extras em sua aplicação. Você pode adequá-lo ao seu ambiente e suas necessidades
através da injeção de dependências (I<dependency injection>) durante a criação
do objeto.

A documentação completa sobre o webservice dos Correios pode ser encontrada em
L<http://www.correios.com.br/webServices/PDF/SCPP_manual_implementacao_calculo_remoto_de_precos_e_prazos.pdf>

=head1 MÉTODOS

=head2 new

=head2 new( %parametros )

Construtor do objeto. Recebe os seguintes parâmetros, todos opcionais:

=over 4

=item * codigo_empresa

Código administrativo de sua empresa junto à ECT. Este código está disponível
no corpo do contrato firmado com os Correios. O valor padrão é uma string
vazia, ''.

=item * senha

Senha associada ao seu código administrativo (acima), necessária para acesso
autenticado ao serviço. O valor padrão é uma string vazia, ''.

=item * codigo_servico

Infelizmente a documentação dos Correios é escassa e dá o mesmo nome para
serviços diferentes. Para evitar confusão, este módulo trabalha apenas com os
códigos numéricos dos serviços.

Até a data de publicação deste módulo, os seguintes códigos eram vigentes:

    +--------+----------------------------------+
    | Código | Serviço                          |
    +--------+----------------------------------+
    | 40010  | SEDEX sem contrato               |
    | 40045  | SEDEX a Cobrar, sem contrato     |
    | 40096  | SEDEX com contrato               |
    | 40126  | SEDEX a Cobrar, com contrato     |
    | 40215  | SEDEX 10, sem contrato           |
    | 40290  | SEDEX Hoje, sem contrato         |
    | 40436  | SEDEX com contrato               |
    | 40444  | SEDEX com contrato               |
    | 40568  | SEDEX com contrato               |
    | 40606  | SEDEX com contrato               |
    | 41068  | PAC com contrato                 |
    | 41106  | PAC sem contrato                 |
    | 81019  | e-SEDEX, com contrato            |
    | 81027  | e-SEDEX Prioritário, com conrato |
    | 81035  | e-SEDEX Express, com contrato    |
    | 81833  | (Grupo 2) e-SEDEX, com contrato  |
    | 81850  | (Grupo 3) e-SEDEX, com contrato  |
    | 81868  | (Grupo 1) e-SEDEX, com contrato  |
    +--------+----------------------------------+

=item * cep_origem

CEP de origem, sem hífen. O valor padrão é I<''>.

=item * cep_destino

CEP de destino, sem hífen. O valor padrão é I<''>.

=item * peso

Peso físico da encomenda, incluindo peso da embalagem, em quilogramas (KG).
O valor padrão é C<0.1>, indicando peso de 100 gramas. O limite de peso
é de 30Kg tanto para PAC quanto para os serviços da família SEDEX, exceto
pelo "SEDEX Hoje", cujo limite é de 10Kg.

=item * formato

Formato da encomenda, incluindo embalagem. A especificação do formato é
exigida pelos correios para precificação e validação de dimensões mínimas
e máximas permitidas. Valores possíveis são:
C<'caixa'> (ou C<'pacote'>) e C<'rolo'> (ou C<'prisma'>).

O valor padrão é I<'caixa'>.

B<Importante>: para o formato caixa/pacote, os seguintes limites precisam
ser respeitados:

  +-------+-----------------------------------+--------+--------+
  | tipo  | regra                             | mínimo | máximo |
  +-------+-----------------------------------+--------+--------+
  | caixa | comprimento + altura + largura    |   -    | 160 cm | 
  | rolo  | comprimento + duas vezes diâmetro |  28 cm | 104 cm |
  +-------+-----------------------------------+--------+--------+

=item * altura

Obrigatório para os formatos C<'caixa'> e C<'pacote'>. O valor máximo
é de 90cm. Caso não seja informada, assume o valor mínimo de 2cm. A
altura não pode ser maior que o comprimento.

=item * largura

Obrigatório para os formatos C<'caixa'> e C<'pacote'>. O valor máximo
é de 90cm. Caso não seja informada, assume o valor mínimo de 5cm,
ou 11cm caso o comprimento seja menor que 25 cm.

=item * comprimento

Obrigatório para todos os formatos. O valor máximo é de 90cm. Caso
não seja informada, assume o valor mínimo, que é de 16cm para
caixa/pacote e 18cm para rolo/prisma.

=item * diametro

Obrigatório para os formatos C<'caixa'> e C<'pacote'>. O valor máximo
é de 90cm. Caso não seja informada, assume o valor mínimo de 5cm.

=item * mao_propria

Booleano. Indica se o serviço adicional "mão própria" será utilizado.
O valor padrão é falso.

=item * aviso_recebimento

Booleano. Indica se a encomenda será entregue com o serviço adicional
de aviso de recebimento. O valor padrão é falso.

=item * valor_declarado

Indica se a encomenda será entregue com o serviço adicional de
valor declarado. Para utilizar o serviço, basta definir neste campo o
valor declarado desejado, em Reais, até o limite máximo de 10_000,00.
O valor padrão é 0, indicando que o serviço não será utilizado.

=back

=head2 query()

=head2 query( %parametros )

Realiza a consulta de preço e prazo, consultando o WebService dos
Correios conforme necessário. Recebe os mesmos parâmetros do construtor
(veja acima).


=head1 CONFIGURATION AND ENVIRONMENT

Net::Correios requires no configuration files or environment variables.


=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
C<bug-net-correios@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AGRADECIMENTOS

Este módulo não existiria sem o serviço gratuito de preços e prazos dos Correios.

L<< http://www.correios.com.br/webservices/ >>


=head1 AUTHORS

Breno G. de Oliveira  C<< <garu@cpan.org> >>
Blabos de Blebe  C<< <blabos@cpan.org> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2011, Estante Virtual. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
