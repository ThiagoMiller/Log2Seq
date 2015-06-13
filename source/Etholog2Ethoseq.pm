use strict;
use warnings;
use diagnostics;
use Encode qw/ decode encode /;

use autodie;
  
use v5.10;
use File::Find;
use File::Spec::Functions 'catdir';

use base 'Exporter';
our @EXPORT_OK = qw/ carrega faz_mdf  /;
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

our $VERSION = '1.03';

{
# Faz busca recursiva no diretório escolhido. Os arquivos .LOG encontrados
#são processados e introduzidos na hash %dados_log.
#  $dados_log{ 'cluster' } { número do arquivo .LOG } <- endereço arquivo .LOG
my %dados_log;

sub carrega {
  undef %dados_log; #reseta a variavel
  my $local_para_abrir = decode( 'cp1252', shift );
  find( \&_wanted, encode( 'cp1252', $local_para_abrir ) );
  return \%dados_log;
}

sub _wanted { 
  if ( $_ =~ /^([[:alpha:]]+)(\d+)\.LOG$/i ) {
    $dados_log{ $1 }{ $2 } = $File::Find::name;
  }
}

}



sub faz_mdf {
	my ( $dados_escolhidos_href, $local_para_salvar, $dados_log_href ) = @_;
	my %dados_log = %{ $dados_log_href };
	my @escolhidos =  keys %{ $dados_escolhidos_href };
	my $escolhido = shift @escolhidos or return;
	my $titulo = delete $dados_escolhidos_href->{ $escolhido } or return;
	
	my $dado_log_ref = delete $dados_log{ $escolhido };
	my $arquivo_mdf = catdir( $local_para_salvar, "$titulo.mdf" );
	
	open my $fh, ">" => $arquivo_mdf;
	_principal( $fh, $titulo, $dado_log_ref );
	close $fh;
	
	return faz_mdf( $dados_escolhidos_href, $local_para_salvar, \%dados_log );
}

sub _principal {
	my ( $fh, $titulo, $dado_log_ref ) = @_;
	say $fh $titulo;
	
	
	my @dados_extraidos;
	
	foreach ( sort { $a <=> $b } keys %{ $dado_log_ref } ) {
	
		open my $logh, "<:encoding(cp1252)" => $dado_log_ref->{ $_ };
		my $numero = $_;
		my $numero_dado;
		if ( $numero - 100  >= 0 ) { $numero_dado = $numero / 100 } else { $numero_dado = $numero };
		@dados_extraidos = _extrai_os_dados( $logh );
		close $logh;
		
		_escreve_mdf( \@dados_extraidos, $titulo, $numero_dado, $fh );	
	}
}

sub  _extrai_os_dados {
	my $logh = shift;
  
   	my $dados_regex = qr{
      			^                                                   
      			\".+\#\d+\"                                         
      			,                                          
      			\"( [[:graph:]+\s]+? )\s*\"                         
  	}xi;
	my $quebra_de_linha_regex = qr{ End_Session }x;
    	my $pausa_regex = qr{ 
      			^
      			\".+\#\d+\"
     			 ,
      			\"( pausa )                                         
    			}xi;
  
  	#Cria uma array de arraies contendo as variáveis na sequência em que aparecem.
  	#Se houver mais dados depois de "End_Session", estes são salvos numa array contida
  	#na posição seguinte a da primeira.
	my $contador = 0;
	my @dados_para_extrair;
	while ( my $linha = <$logh> ) {
		if ( $linha =~ $quebra_de_linha_regex and @dados_para_extrair ) {
			$contador ++;
    		}
    		if ( $linha =~ $dados_regex or $linha =~ $pausa_regex ) { 
      			push @{ $dados_para_extrair[ $contador ] } => $1;
   	 	}
  	}
	return @dados_para_extrair;
}

sub _escreve_mdf {
	my ( $dados_extraidos_ref, $titulo, $numero_dado, $fh ) = @_;
	
	my $data_file = $titulo;
	my $acm = 1;
	foreach my $dado_extraido_ref ( @$dados_extraidos_ref ) {
		if ( scalar @$dados_extraidos_ref != 1 ){
			$titulo = $data_file . "-parte$acm-";
			$acm ++;
		}

		my $cabecalho = <<"EOF";


Observational data file .....: $data_file$numero_dado.odf
Title .......................: $titulo$numero_dado
From ........................: Start of observation
To ..........................: End of observation

      Time Captura  
  -----------------
EOF

		print $fh $cabecalho;
	
		for my $i ( 0..$#$dado_extraido_ref ) {
			my $contador = sprintf "%.1f" => ( $i + 10 ) / 10;	
			say $fh "$contador " . "$dado_extraido_ref->[ $i ]";

			say $fh $contador + 0.1, " " . "{end}" if $i == $#$dado_extraido_ref;
		}
	}
}



1; #FIM


























