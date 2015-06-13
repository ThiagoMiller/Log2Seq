# Log2Seq

Converte a saída de [EthoLog](http://www.ip.usp.br/docentes/ebottoni/EthoLog/ethohome.html) para [EthoSeq](http://www2.assis.unesp.br/cats/ethoseq.htm)

# Instalação

* **Windows**: O programa roda sem a necessidade de instalação. Basta executar `.\Log2Seq.exe`. 
* **Linux**: Pode-se executar o script GUI.pl: `$ perl GUI.pl`. Há a necessidade de se instalar a biblioteca Tk: `$ cpan -i Tk`.

# Motivação

Os arquivos `.LOG` gerados pelo [EthoLog](http://www.ip.usp.br/docentes/ebottoni/EthoLog/ethohome.html) necessitam ser agrupados num arquivo `.MDF` para que possam ser analisados pelo [EthoSeq](http://www2.assis.unesp.br/cats/ethoseq.htm).

É preciso extrair dos Arquivos `.LOG` a coluna com as *TAG's* atribuídas a cada comportamento. Estas colunas são então inseridas, com
seus respectivos cabeçalhos, num arquivo `.MDF` que conterá todas as colunas extraídas de um determinado *CLUSTER*. Só então, é possível carregar a informção no programa [EthoSeq](http://www2.assis.unesp.br/cats/ethoseq.htm).

Para esse fim, foi desenvolvido o programa **Log2Seq** que possibilita
gerar quantos arquivos `.MDF` forem necessários de uma única vez.

# Como Funciona

1. 	Selecione um diretório para pesquisar.

	O programa irá buscar, recursivamente ( *pasta e subpastas* ), no diretório especificado
	por arquivos `.LOG`. Estes serão agrupados pela **raiz** de seus nomes como *CLUSTERS*.

		PASTA
		|______ABELHA101
		|______ABELHA102
		|______RATO103
		|______RATO104
	
	Há 2 *CLUSTERS*: ABELHA (101, 102) e RATO (103,104)
	
	Fica a cargo do usuário se vai querer processar os dois grupos (ABELHA e RATO).

	É importante ressaltar que o programa incluirá **todos** os arquivos `.LOG` de um determinado
	grupo no arquivo `.MDF`, de modo que não é possível processar apenas **RATO103**, exemplo, e deixar
	o **104** de fora. 
	*obs: A não ser, é claro, que se mova o arquivo* **RATO103** *para outra pasta e* 
	*selecione-a pelo programa.*

2. 	Selecione o(s) grupo(s) a ser(em) processado(s).

3. 	(opcional) - Marque a opção `escolher títulos`, caso queira escrever o nome
	do fututo arquivo `.MDF`. Do contrário, o programa **tomará** como título o próprio nome do grupo.

4. 	Indique uma pasta onde salvar os arquivos `.MDF`.

	Caso a opção `escolher título` tenha sido marcada, ao clicar no botão `Processar`
	o usuário será levado a outra janela onde poderá escrever os títulos individualmente.

## Dúvidas, Sugestões, Questões

Entre em contato ( thiago_leisrael@hotmail.com ) para o esclarecimento de quaisquer dúvidas.

# Desenvolvedores

O **Log2Seq** foi desenvolvido por Thiago L. A. Miller 
sob a orientação da Dra. Juliana de Oliveira ( juliana@assis.unesp.br ).
Laboratório de Bioinformática
UNESP - *Assis* - 2015. 


