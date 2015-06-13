use strict;
use warnings;

use utf8;

use Tk;
use Tk::LabFrame;
use Tk::ROText;
#use PAR; Para carregar os arquivos help.txt e sobre.txt quando compilar com PAR::Packer

use Etholog2Ethoseq  qw/ carrega faz_mdf /;

my ($local_para_abrir,
    $dados_log_ref,
    @chaves_ordenadas,
    $local_para_salvar,
    @titulos,
    @escolhidos,
);
  
my $titulo = 0;

#############################
############ GUI ############
#############################

## Cria $mw
my $mw = MainWindow->new();
$mw->geometry( '300x150+250+100' );
$mw->resizable( 'no', 'no' );
$mw->title( 'cria arquivos .MDF para Ethoseq' );

$mw->configure( -menu => my $menu_b = $mw->Menu );
my $label_f = $mw->LabFrame( -labelside => 'bottom' )->pack( -fill => 'x' );


## Menu de Opções
my $sub_menu_b = $menu_b->Menubutton( -text => 'Arquivo', -tearoff => 'no' );

# opção para o menu Sobre e Ajuda
$sub_menu_b->command(
  -label   => 'Sobre',
  -underline => 1,
  -command => \&open_sobre,
);
$sub_menu_b->command(
  -label   => 'Ajuda',
  -underline => 0,
  -command => \&open_help,
);

$sub_menu_b->separator();
$sub_menu_b->command(
  -label   => 'Sair',
  -underline => 0,
  -command => sub { exit( 0 ); },
);


## Apresentação
$label_f->Label( 
  -text        => 'Log2Seq',
  -heigh       => '2', 
  -borderwidth => '2',
  -font        => [ 	-size   => '10',
			-weight => 'bold' ], 
)->pack();


## Entrada dos arquivos .LOG
$mw->Label( 
  -text => 'Selecione uma pasta para pesquisar' 
    )->pack( 
      -side => 'top', 
      -anchor => 'w', 
      -padx => '5', 
  );
# Mostra o local onde pesquisar
my $dir_text = $mw->ROText( 
  -width 	=> '35',
  -height 	=> '1',
  -background 	=> 'white', 
  -foreground 	=> 'blue' 
  )->pack( 
  -side 	=> 'left', 
  -anchor 	=> 'n', 
  -padx 	=> '3', 
  );

# botão de pesquisa  
my $file_b = $mw->Button( 
  -text    	=> '...', 
  -foreground 	=> 'blue',
  -width   	=> '13',
  -height 	=> '0',
  -command 	=> \&open_d );
$file_b->pack( 
  -side 	=> 'left', 
  -anchor 	=> 'n', 
  -padx 	=> '5'
  );

# botão avançar
my $next_b = $mw->Button( 
  -text 	=> 'Avançar', 
  -state => 'disabled',
  -width 	=> '7', 
  -foreground 	=> 'darkgreen', 
  -command 	=> \&listbox,  
  )->place( 
	  -x => 245, -y => 120
  );

# botão sair   
$mw->Button( 
  -text 	=> 'Sair', 
  -width 	=> '7', 
  -foreground 	=> 'darkred', 
  -command 	=> sub { exit } 
  )->place( -x => 190, -y => 120 );

	    
# Cria $mw2    
my $mw2 = $mw->Toplevel( -title => 'CLUSTERS', );
$mw2->geometry( '230x330+350+140' );
$mw2->resizable( 'no', 'no' );
my $lb_f = $mw2->LabFrame( -label => 'Escolha quais grupos processar' )->pack(); 


#esconde $mw2
$mw2->withdraw;

# ALtera o funcionamento do botão [X
$mw2->protocol( 'WM_DELETE_WINDOW' => \&retorna_para_mw );


# Listbox com as opções de grupos  
my $boxPath = $lb_f->Scrolled(
  "Listbox",
  -scrollbars => 'e',
  -background => 'white',
  -foreground => 'darkred',
  -selectforeground => 'blue',
  -height     =>  9,
  -width      =>  29,
  -selectmode => 'multiple',
)->pack();

# Frame para os botões Limpar e Todos
my $bp_control_f = $mw2->Frame(
)->pack( 
  -after => $boxPath, 
  -pady => '3' 
  );

# Limpa o boxPath
my $limpar_b = $bp_control_f->Button(
   -text    => 'Limpar',
   -foreground => 'darkred',
   -width => '10',
   -command => sub { $boxPath->selectionClear( 0, 'end' ); }
)->grid (

# Seleciona todas as opções de grupos
my $todos_b = $bp_control_f->Button( 
  -text => 'Todos', 
  -foreground => 'blue', 
  -width => '10',
  -command => sub { $boxPath->selectionSet( 0, 'end' ); } )
);


# Checkbutton: opção de escolher o título
my $chk_f = $mw2->LabFrame( -label => 'Título' )->pack( -ipadx => '42');
my $check_b = $chk_f->Checkbutton( 
  -text => 'escolher os títulos', 
  -variable => \$titulo
  )->pack( -side => 'left' );

my $sv_f = $mw2->LabFrame( -label => 'Selecione onde salvar' )->pack();

# Mostra o local onde salvar 
#$mw2->Label( -text => 'Selecione onde salvar' )->pack( -anchor => 'w', -padx => '18', );
my $dir_text2 = $sv_f->ROText( 
  -width 	=> '24',
  -height 	=> '0',
  -background 	=> 'white', 
  -foreground 	=> 'blue' 
  )->pack( -side => 'left', -anchor => 'n',);

# botão para escolher o local onde salvar  
my $file_b2 = $sv_f->Button( 
  -text    	=> '...', 
  -foreground 	=> 'blue',
  -width   	=> '3',
  -height 	=> '1',
  -command 	=> \&save_d, 
);
$file_b2->pack( -side => 'left', -anchor => 'n', );  
  
# botão de processar  
my $processa_b = $mw2->Button(
   -text    	=> 'Processar',
   -state 	=> 'disabled',
   -width 	=> '7',
   -foreground 	=> 'darkgreen',
   -command 	=> \&processar,
)->place( -x => 163, -y => 295, );

# botão que retorna para $mw
my $fechar_mw2_b = $mw2->Button( 
  -text 	=> 'Fechar', 
  -width 	=> '7', 
  -foreground 	=> 'darkred', 
  -command 	=> \&retorna_para_mw,
  )->place( -x => 106, -y => 295 );
  

## Sub-rotinas principais
sub listbox {
## Chama a função 'carrega' que devolve uma referência para
# os clusters encontrados
  $dados_log_ref = carrega( $local_para_abrir );
  @chaves_ordenadas = sort keys %{ $dados_log_ref };
  unless ( @chaves_ordenadas ) { $mw->messageBox( -message => 'Não foi possível encontrar arquivos .LOG no diretório escolhido!', -type => 'ok' )
   } else {
 # mostra $mw2
  $mw2->deiconify();
  $mw2->raise();
  #desativa botões da $mw
  $next_b->configure( -state => 'disabled', );
  $file_b->configure( -state => 'disabled', );
  
  #insere os clusters no boxlist
  $boxPath->insert( 'end', @chaves_ordenadas );
  }
}
  
    
sub processar {
## Carrega as opções selecionadas pelo usuário
  my @inds = $boxPath->curselection();
  push @escolhidos => $boxPath->get( $_ ) for @inds;
  
  # Se o usuário escolheu pelo menos um grupo, ele é 
# mandado para a próxima etapa. Se não, ele recebe um
# pop-up informando que deve fazer a escolha.
  if ( scalar @escolhidos > 0 ) {
    my %dados_log_escolhidos; 
    map { $dados_log_escolhidos{ $_ } = $_ } @escolhidos;
    
    # Caso o usuário queira escolher os títulos dos arquivos
    if ( $titulo == 1 ) {
  
      trava_mw2();
      
      # Cria $mw3 para conter as entradas dos títulos
      my $mw3 = $mw->Toplevel( -title => 'títulos' );
      $mw3->geometry( '+350+160' );
      # configura o botão [X
      $mw3->protocol( 'WM_DELETE_WINDOW' => sub { $mw3->destroy; return retorna_para_mw2() } );
      $mw2->protocol( 'WM_DELETE_WINDOW' => sub { return; } );
      # Frame para o botão finalizar
      my $final_f = $mw3->Frame(
      )->pack( 
	-side => 'bottom', 
	-anchor => 'e', 
	-padx => '5', 
	-pady => '5', 
	);
      # Frame para as entradas	
      my $entry_f = $mw3->Frame(
      )->pack( 
	-side => 'top', 
	-anchor => 'w', 
	-pady => '5', 
	-padx => '5', 
	);
      # Corrige a concordância nominal para o texto informativo
      my $text;
      if ( scalar @escolhidos == 1 ) { $text = 'Insira o título:' } else { $text = 'Insira os títulos:' }
	$mw3->Label( 
	  -textvariable => \$text 
	)->pack( 
	  -before => $entry_f, 
	  -side => 'top', 
	  -anchor => 'w', 
	  -pady => '5', 
	  -padx => '5', 
	);
      #  A hash %opcoes conterá nas chaves as opções escolhidas
      # e, nos valores, referências para as entradas. 
      my %opcoes;
      map { $opcoes{ $_ } = '' } @escolhidos;
      for ( @escolhidos ) {
	$entry_f->Label( -text => $_ )->grid(
	$opcoes{ $_ } = $mw3->Entry( 
	  -background => 'white', 
	  -foreground => 'blue', 
	)
	);
      }
      # Cria o botão de finalização
      $final_f->Button( 
	-text => 'Finalizar', 
	-foreground => 'darkgreen', 
	-command => sub { # Sub-rotina que captura os títulos digitados e verifica se todos foram
			  # preenchidos, se não, o usuário recebe um pop-up informando
			  foreach my $opcao ( keys ( %opcoes ) ) {
			  push @titulos =>  $opcoes{ $opcao }->get();
			  # Mantém os dados escolhidos e seus títulos na mesma hash
			  $dados_log_escolhidos{ $opcao } = $opcoes{ $opcao }->get();
			   } 
			  for ( @titulos ) {
			    unless ( /\w+/ ) { #Verifica se todos foram preenchidos
			      $mw3->messageBox( -message => 'Você precisa escolher todos os títulos!' ); 
			      undef @titulos;    #reseta @titulos
			      undef @escolhidos; #reseta @escolhidos
			      return 
			    }
			  }
			  undef @escolhidos;	#reseta @escolhidos
			  # Função que cria os arquivos mdf
			  faz_mdf( \%dados_log_escolhidos, $local_para_salvar, $dados_log_ref );
			  $mw3->messageBox( -message => 'Pronto!' );
			  $mw3->destroy;
			  retorna_para_mw2();
			  }
	)->pack();
	
    } else { # sem $titulo
	undef @escolhidos;
	faz_mdf( \%dados_log_escolhidos, $local_para_salvar, $dados_log_ref );
	$mw2->messageBox( -message => 'Pronto!', -type => 'ok' )
    }
    
    
  } else { # scalar @escolhidos -> caso nenhum grupo tenha sido escolhido
    $mw2->messageBox( 
      -message => 'Você precisa escolher pelo menos um grupo!', 
      -type => 'ok' 
    );
  }
}


## Sub-rotinas que administram os call-back

# Escolhe diretório de pesquisa
sub open_d {
  my $state = $local_para_abrir;
  $local_para_abrir = $mw->chooseDirectory( 
    -initialdir => '.',
    -title      => 'Selecione uma pasta para pesquisar.',
  );
 
  if ( defined $local_para_abrir ) {
	$dir_text->delete( '1.0', 'end'  ); #reinicia o mostrador
	$dir_text->insert( 'end', $local_para_abrir ); #mostra a opção selecionada
	$next_b->configure( -state => 'normal' ); #disponibiliza o botão de avançar
  } else {
	$local_para_abrir = $state;
  }
}

# Escolhe local onde salvar
sub save_d {
  $local_para_salvar = $mw2->chooseDirectory(
    -initialdir => '.',
    -title => 'Selecione o local onde salvar.',
  );
  $dir_text2->delete( '1.0', 'end' ); #reinicia o mostrador
  $dir_text2->insert( 'end', $local_para_salvar );  #mostra a opção selecionada
  return verificadora_mw2();
}

# configurações necessárias para retornar a $mw
sub retorna_para_mw {
  $file_b->configure( -state => 'normal' ); 	#disponibiliza o botão de carregar
  undef $local_para_abrir;  			#reseta o local_para_abrir
  undef $local_para_salvar; 			#reseta o local_para_salvar
  $dir_text->delete( '1.0', 'end' ); 		#reinicia o mostrador
  $next_b->configure( -state => 'disabled' );	#desativa o botão de avançar
  $dir_text2->delete( '1.0', 'end' );		#limpa o mostrador do local onde salvar
  $boxPath->delete( 0, 'end' );		#reseta o boxlist
  $mw2->withdraw;				#esconde a $mw2
  verificadora_mw2();
}

# Quando é criada a $mw3, trava-se a $mw2 para se evitarem possíveis bugs
sub trava_mw2 {
   $processa_b->configure( 	-state => 'disabled' ); #botão de processar
   $fechar_mw2_b->configure( 	-state => 'disabled' );	 #botões de fechar
   $file_b2->configure( 	-state => 'disabled' );	 #botão de selecionar onde salvar
   $limpar_b->configure( 	-state => 'disabled' ); #botão de limpar o boxlist
   $todos_b->configure( 	-state => 'disabled' ); #botão de selecionar tudo na boxlist
   $check_b->configure( 	-state => 'disabled' ); #Checkbutton para título
   $boxPath->configure( 	-state => 'disabled' ); #boxlist
}

# Quando se fecha a $mw3, esta função retoma $mw2
sub retorna_para_mw2 {
   undef @escolhidos;					#reseta os escolhidos pelo boxlist
   $processa_b->configure( 	-state => 'normal' );	#reativa botão de processar
   $fechar_mw2_b->configure( 	-state => 'normal' );	#reativa botão de fechar
   $file_b2->configure( 	-state => 'normal' );	#reativa botão .../
   $limpar_b->configure( 	-state => 'normal' );	#reativa botão de limpar
   $todos_b->configure( 	-state => 'normal' );	#reativa botão todos
   $check_b->configure( 	-state => 'normal' ); 	#reativa opção de título 
   $boxPath->configure( 	-state => 'normal' );	#reativa boxlist
   $mw2->protocol( 'WM_DELETE_WINDOW' => \&retorna_para_mw );
   return verificadora_mw2();				#chama função verificadora
}

sub verificadora_mw2() {
  #Verifica se há um local onde salvar para só então 
  #disponibilizar o botão de processar
  if ( not defined $local_para_salvar  ) {
    $processa_b->configure( -state => 'disabled' );
  } else { 
  $processa_b->configure( -state => 'normal' ) 
  }
}


## Sub-rotinas para carregar os .txt de 'ajuda' e 'sobre'
sub open_sobre {
	my $caminho = "sobre.txt";
	my $sobre = $mw->Toplevel( -title => 'SOBRE' );
	$sobre->geometry( '480x120' );
	my $text = $sobre->ROText()->pack();
	open my $fh, '<', $caminho or die "não foi possível abrir: $!\n";
	$text->delete( '1.0', 'end' );
	while ( <$fh> ) {
		$text->insert( 'end', $_ );
	}
}

sub open_help {
	my $caminho = "help.txt";
	my $help = $mw->Toplevel( -title => 'AJUDA' );
	my $text = $help->Scrolled("ROText", -width => '90', -height => '20')->pack();
	$text->delete( '1.0', 'end' );
	open my $fh, '<', $caminho or die "não foi possível abrir: $!\n";
	$text->delete( '1.0', 'end' );
	while ( <$fh> ) {
		$text->insert( 'end', $_ );
	}
}


# Mostra MainWindow
MainLoop();




