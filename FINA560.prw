#INCLUDE "FINA560.CH"
#INCLUDE "PROTHEUS.CH"

STATIC nTamCaso := NIL


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FINA560  ³ Autor ³ Leonardo Ruben        ³ Data ³ 14.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Ingresso de Comprovantes do Caixinha           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FINA560()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAFIN													  ³±±     
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
                                                                         
Function FINA560(nPosArotina)
Local lPanelFin := If (FindFunction("IsPanelFin"),IsPanelFin(),.F. )
Local   aHlpPor1    :=  {"Não é possível apontar despesas para"," viagens planejadas"}
Local   aHlpIng1    :=  {"It is not possible to point"," expenditures to planned trips."}
Local   aHlpEsp1    :=  {"No es posible incluir gastos"," para viajes planeadas."}
Local lCXJurFin	:= If(FindFunction("FVldJurxFin"),FVldJurxFin(),.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aCores    := {{ 'EU_TIPO="00" .AND. Empty(EU_BAIXA) .AND. Empty(EU_NROADIA)'	, 'ENABLE' },; // Despesas nao baixadas
{  'EU_TIPO="00" .AND. Empty(EU_BAIXA) ', 'BR_AZUL'},;		// Despesas de adiantamento nao baixadas
{  'EU_TIPO="01" .AND. EU_SLDADIA>0'   	, 'BR_AMARELO'},;	// Adiantamento com saldo (em aberto)
{  'EU_TIPO="03"       '	, 'BR_MARRON'},;    // Complemento de adiantamento
{  '!Empty(EU_BAIXA)' 					, 'DISABLE'} }	// despesas baixadas e outros movimentos

LOCAL cFilSEU  			//Expressao de filtro da mBrowse
Local lMntTms    := ( SuperGetMV( "MV_NGMNTMS",,'N') == 'S' )

Private nValorPrest := 0
Private aDiario     := {}
Private cCodDiario  := ""


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra/Altera lancamentos contabeis mv_par01 Sim/Nao         ³
//³ Aglutina lancamentos contabeis      mv_par02 Sim/Nao         ³
//³ Lancamento contabil On-Line         mv_par03 Sim/Nao         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega funcao Pergunte	                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey (VK_F12,{|a,b| AcessaPerg("FIA550",.T.)})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada F560PRG              							³
//³ Ponto de entrada para inibir o F12 para determinados usuarios   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("F560PRG")
	ExecBlock("F560PRG",.F.,.F.)
Endif

Pergunte("FIA550",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private aRotina := MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro :=OemtoAnsi(STR0011 )  //"Movimento de Caixinhas"

dbSelectArea("SEU")
dbSetOrder(1)

If ExistBlock("FA550VERIF",.T.) .And. Fa550Verif()
	aRotina:=Asize(aRotina,Len(aRotina)+1)
	aRotina:=Ains(aRotina,5)
	aRotina[5]:={"Reposicion", "FA560Rep",0,4}
	Aadd(aCores,{'EU_TIPO="91"'	, 'BR_CINZA'})	 	// Reposicao: aguardando liberacao
	Aadd(aCores,{'EU_TIPO="92"'	, 'BR_PINK'})		// Reposicao: aguardando compensacao do cheque
	Aadd(aCores,{'EU_TIPO="90"'	, 'BR_PRETO'})		// Reposicao cancelada
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta o SXs                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AjustaSX3()
AjustaSX()

//Ajuste de Novos Helps
PutHelp("PFA560TIPVI",aHlpPor1,aHlpIng1,aHlpEsp1,.F.)

aHlpPor1 :=	{	"Não é possível excluir esse movimento." }
aHlpIng1 :=	{	"It is not possible to delete this movement." } 
aHlpEsp1 :=	{	"No es posible borrar este movimiento."}

//ajuste do help FA560BAIXA                    
PutHelp("PFA560BAIXA",aHlpPor1,aHlpIng1,aHlpEsp1,.T.)


//Arquivo de rateios juridicos de despesas do caixinha
If lCXJurFin
	dbSelectArea("FJ4")
	dbSetOrder(1)
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a existencia de Filtros na mBrowse                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("FT560FIL")
	cFilSEU := ExecBlock("FT560FIL",.f.,.f.)
	If !Empty(cFilSEU)
		dbSetFilter( { || &cFilSEU}, cFilSEU )
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT nPosArotina := 0
If nPosArotina > 0 // Sera executada uma opcao diretamento de aRotina, sem passar pela mBrowse
	dbSelectArea("SEU")
	bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPosArotina,2 ] + "(a,b,c,d,e) }" )
	Eval( bBlock, Alias(), (Alias())->(Recno()),nPosArotina)
Else
	DbSelectArea("SEU")
	DbSetOrder(1)
	DbSeek(xFilial())
	mBrowse( 6, 1,22,75,"SEU",,,,,,FA560Legend())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cFilSEU)
	dbClearFilter()
	RetIndex("SEU")
EndIf

Set Key VK_F12 To
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA560Inclui³ Autor³ Leonardo Ruben        ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inclusao de Comprovantes do Caixinha                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³FA560Inclui()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo									  ³±±
±±³			 ³ ExpN1 = N£mero do registro 								  ³±±
±±³			 ³ ExpN2 = N£mero da op‡„o selecionada 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA560                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa560Inclui(cAlias,nReg,nOpc,cFilOri,cViagem)
Local lPanelFin		:= If(FindFunction("IsPanelFin"),IsPanelFin(),.F.)
Local aArea			:= GetArea()
Local nOpcA			:= 0
Local nCntFor		:= 0
Local aPosEnch		:= {}
Local aVisual		:= {}
Local nRecSEU		:= 0
Local nSaveSx8		:= GetSx8Len()
Local cCpoSEU		:= ""
Local lFa550IncI	:= ExistBlock("FA550INI")
Local lFa550IncF	:= ExistBlock("FA550INF")
Local lResp			:= .T. 
Local aSize			:= {}
Local aObjects		:= {}
Local aInfo			:= {}
Local aPosObj		:= {}

// Variaveis para Integração SIGATMS x SIGAMNT
Local lGerOs     := .F.
Local lMntTms    := ( SuperGetMV( "MV_NGMNTMS",,'N') == 'S' )//-- Ativa integracao TMS X MNT.
Local cSerDesp   := ( SuperGetMV('MV_SERDESP',,'' ) )
Local lR5        := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao    := Val(GetVersao(.F.))     // Indica a versao do Protheus
Local lExeIntTms := ((nVersao == 11 .And. lR5) .Or. nVersao > 11) //-- Verificação de Release .5 do Protheus 11

Local lCXJurFin	:= If(FindFunction("FVldJurxFin"),FVldJurxFin(),.F.)

Private aFolTms     := {}
Private aFolTmsBkp  := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aTELA[0][0],aGETS[0]
Private ADIANTAMENTO :=	.F.

DEFAULT cFilOri		:= ''
DEFAULT cViagem		:= ''

If lPanelFin  //Chamado pelo Gestor Financeiro - PFIN
   Inclui := .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia para processamento dos Gets          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Enchoice ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCpoSEU:="EU_BCOREP.EU_AGEREP.EU_CTAREP.EU_TITULO."+If(FieldPos("EU_TIPDEB") > 0, "EU_TIPDEB.", "")
cCpoSEU+="EU_SERCOMP."
DbSelectArea("SX3")
DbSetOrder(1)
MsSeek(cAlias)
While  !Eof() .And. X3_ARQUIVO == cAlias
	If	x3uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
		If Alltrim(X3_CAMPO)$cCpoSEU
			Aadd( aVisual, "NOUSER" )
			DbSkip()
			Loop
		Endif
		cCampo := SX3->X3_CAMPO
		If	( SX3->X3_CONTEXT == "V"  .Or. Inclui )
			M->&(cCampo) := CriaVar(SX3->X3_CAMPO)
		Else
			M->&(cCampo) := SET->(FieldGet(FieldPos(SX3->X3_CAMPO)))
		EndIf
		Aadd( aVisual, SX3->X3_CAMPO )
	EndIf
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Integracao com o Modulo de Transporte (TMS)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If IntTMS() .And. nModulo == 43 .And. !Empty(cFilOri) .And. !Empty(cViagem)
	M->EU_FILORI := cFilOri	
	M->EU_VIAGEM := cViagem
Endif

If lFa550IncI
	ExecBlock("FA550INI",.F.,.F.,)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia lancamento no PCO                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PcoIniLan("000359")

If lPanelFin  //Chamado pelo Painel Financeiro
	dbSelectArea("SEU")
	RegToMemory("SEU",.T.,,,FunName())
	oPanelDados := FinWindow:GetVisPanel()
	oPanelDados:FreeChildren()
	aDim := DLGinPANEL(oPanelDados)

	DEFINE MSDIALOG oDlg OF oPanelDados:oWnd FROM 0, 0 TO 0,0 PIXEL STYLE nOR( WS_VISIBLE, WS_POPUP )	

	aPosEnch := {,,,}
	oEnc01:= MsMGet():New( cAlias, nReg, nOpc,,,,aVisual,aPosEnch,,3,,,,oDlg,,,.F.) 	
	oEnc01:oBox:Align := CONTROL_ALIGN_ALLCLIENT
			
	// define dimenção da dialog
  	oDlg:nWidth := aDim[4]-aDim[2]

	ACTIVATE MSDIALOG oDlg  ON INIT ( FaMyBar(oDlg,{||nOpca:=1,If(F560TudoOk(aGets,aTela) ,oDlg:End(),nOpca:=0)},{||nOpca:=0,oDlg:End()}),	oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1])) 
Else
	//+------------------------------------------------------+
	//| Faz o calculo automatico de dimensoes de objetos     |
	//+------------------------------------------------------+
	aSize := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 100, 100, .t., .t. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

   	Define MSDialog oDlg Title cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd Pixel
       oEnc01 := MsMGet():New( 	cAlias, nReg, nOpc,,,,aVisual,aPosObj[1],,3,,,,oDlg,,,.F.) 	
   	   oEnc01:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(F560TudoOk(aGets,aTela) .And. Fa560Valor() ,oDlg:End(),nOpca:=0)},{||nOpca:=0,oDlg:End()})
Endif

If nOpcA == 1

	Begin Transaction
	RecLock(cAlias,.T.)
	For nCntFor := 1 TO FCount()
		If "FILIAL"$Field(nCntFor)
			FieldPut(nCntFor,xFilial())
		Else
			cCampo :=  FieldName(nCntFor)
			If TYPE("M->"+cCampo) != "U"
				FieldPut(nCntFor,M->&(cCampo))
			EnDIf
		EndIf
	Next nCntFor  

    //Grava Status de aguardando liberação do título se o campo existir.
	If FieldPos("EU_STATUS") > 0
		Replace SEU->EU_STATUS With "01"
	EndIf
	
	SEU->(DbCommit())
	nRecSEU := SEU->(RECNO())
	dbSelectArea("SET")
	dbSetOrder(1)
	dbSeek( xFilial()+SEU->EU_CAIXA)
	//Gravo o numero de sequencial de caixa aberto.....
	RecLock("SEU",.F.)
	Replace EU_SEQCXA  With SET->ET_SEQCXA
	MsUnlock()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua os lancamentos no PCO e CTB e abate o saldo do caixinha   ³
	//³ Este processo foi transformado em funcao para ser executado apos ³
	//³ a aprovacao do movimento no controle de alcada (MV_FINCTAL=2)    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SuperGetMV("MV_FINCTAL", .T., "1") == "1"
		FA560Lanc()
	EndIf

	//CAIXINHA x JURIDICO
	//Grava registro de pre-faturamento no SIGAPFS
	//Se caixinha integrado com SIGAPFS
	//Se eh despesa juridica
	//Se sera reembolsado pelo cliente
	//Se nao sofrera rateio
	If lCXJurFin .and. SEU->EU_TIPO == '00' .and. SEU->EU_DESPJUR == '1' .and. SEU->EU_FATJUR == '1' .and. SEU->EU_RATJUR == '2'
		cCodFat := GeraPFS(3,SEU->EU_NUM,,SEU->EU_CLIENTE,SEU->EU_LOJACLI,SEU->EU_CASO,SEU->EU_PROFISS,SEU->EU_EMISSAO,,SEU->EU_VALOR,SEU->EU_TIPDESP,SEU->EU_MEMDSCR)
		If !Empty(cCodFat)
			RecLock("SEU",.F.)
			SEU->EU_SEQJUR := cCodFat
			SEU->(MsUnLock()) 
		EndIf
	Endif

	While (GetSx8Len() > nSaveSx8 )
		ConfirmSX8()
	Enddo
	
	End Transaction

	//CAIXINHA x JURIDICO
	//Grava registro de pre-faturamento no SIGAPFS
	//Se caixinha integrado com SIGAPFS
	//Se eh despesa juridica
	//Se sofrera rateio
	If lCXJurFin .and. SEU->EU_TIPO == '00' .and. SEU->EU_DESPJUR == '1' .and. SEU->EU_RATJUR == '1'

    	If MsgYesNo (STR0104+CRLF+STR0105,STR0106)	//"Deseja realizar o rateio jurídico da despesa neste momento ?"###"(É possivel digitar o rateio posteriormente.)"###"Rateio Jurídico"
			aArea := GetArea()
			xRet := FWExecView( STR0106 , "FINA562", 4, /*oDlg*/, {|| .T. }/*bCloseOnOk*/, /*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ )		//"Rateio Jurídico"
			RestArea(aArea)
		Endif    	
	
	Endif


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada que permite ao usuario exibir ou nao a mensagem de impressao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If ExistBlock("F560IMRC")	   
		lResp := ExecBlock("F560IMRC",.F.,.F.) //	     
	endif   
	If lResp == .T.
		If IW_MsgBox(STR0030+ IIF(M->EU_TIPO == "00", STR0031,STR0032),STR0033,"YESNO") //"Deseja Imprimir Recibo "###"desta Despesa ?"###"deste Adiantamento ?"###"Impressão de recibo"
			SEU->(dbGoto(nRecSEU))
			If ExistBlock("F560RECB")
				ExecBlock("F560RECB",.F.,.F.) //Relatorio de recibo do Caixinha customizado
			Else
				Finr565()  //Relatório de recibo do Caixinha padrao
			Endif
		Endif			
	Endif

Else
	While ( GetSx8Len() > nSaveSx8 )
		RollBackSX8()
	EndDO
EndIf

If lFa550IncF
	ExecBlock("FA550INF",.F.,.F.,)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a gravacao dos lancamentos do SIGAPCO            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PcoFinLan("000359")
PcoFreeBlq("000359")
dbSelectArea(cAlias)
RestArea(aArea)

SEU->(DBGOTO(SEU->(LASTREC())))


Return /*Function Fa560Inclui*/

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA560Deleta³ Autor³ Leonardo Ruben        ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclusao de comprovantes do Caixinha                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FA560Deleta(ExpC1,ExpN1,ExpN2)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³			 ³ ExpN2 = N£mero da op‡„o selecionada 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA560                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION FA560Deleta(cAlias,nReg,nOpc)
Local lPanelFin := If (FindFunction("IsPanelFin"),IsPanelFin(),.F.)
LOCAL nOpcA
LOCAL lOk   := .T., lRet := .T.
LOCAL oDlg
Local nVlrDel, cMens, cNroAdia, dBaixa
Local aArea      := GetArea()
Local lF560Del   := ExistBlock("F560DEL")
LOCAL lPermiss   := .F.
Local nHdlPrv    := 0
Local lDigita    := Iif(mv_par01 ==1,.T.,.F.)
Local lAglutina  := Iif(mv_par02 ==1,.T.,.F.)
Local lGeraLanc  := Iif(mv_par03 ==1,.T.,.F.)
Local cArquivo
Local lPadrao579 := VerPadrao("579")
Local nTotal     := 0
Local lBlock 	  := .F.      
Local aFlagCTB   := {}
Local lUsaFlag	  := SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/) 
Local aSize 	  := {}
Local aObjects   := {}
Local aInfo 	  := {}
Local aPosObj 	  := {}                                              
Local nRecnoSEU   := 0                                             

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Variaveis utilizadas na Integração SIGATMS X SIGAMNT	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lMntTms    := ( SuperGetMV( "MV_NGMNTMS",,'N') == 'S' )//-- Ativa integracao TMS X MNT.
Local cIntmov	 := "" 
Local lR5        := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao    := Val(GetVersao(.F.))     // Indica a versao do Protheus
Local lExeIntTms := ((nVersao == 11 .And. lR5) .Or. nVersao > 11) //-- Verificação de Release .5 do Protheus 11
Local aCab       := {}
Local aItem      := {}
Local aItens     := {}                                                         
Local lClasNF	 := (SuperGetMV("MV_CLASSNF") == "1")
Local lCXJurFin	 := If(FindFunction("FVldJurxFin"),FVldJurxFin(),.F.)
Local lPctCaix 	 := SuperGetMV("MV_PCTCAIX",.F.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cLote :=""
PRIVATE aTELA[0][0],aGETS[0]
PRIVATE ADIANTAMENTO	:=	.F.
PRIVATE aDiario := {}
PRIVATE cCodDiario := ""
PRIVATE lMSErroAuto := .F. 
PRIVATE lMSHelpAuto := .F. // para mostrar os erros na tela

bCampo := {|nCPO| Field(nCPO) }

SET->(dbSetOrder(1))
SET->(dbSeek( xFilial()+SEU->EU_CAIXA))
lClosedCx := IIF(SET->ET_SITUAC == "0" , .F. , .T.)

// Ponto de entrada que definira a permissao ou nao de exclusao de movimentos do caixinha
If lF560Del
	lPermiss := ExecBlock("F560DEL",.F.,.F.)
Endif

If ExistBlock("F560BLOCK")
	lBlock:= ExecBlock("F560BLOCK",.F.,.F.) 
EndIf
If !lBlock	
	// Nao excluo movimentos baixados, exceto com permissao
	// Nao excluo devolucao de adiantamento, movimento banco/caixinha ou movimento caixinha/Banco
	// Nao excluo se o Caixinha estiver fechado
	// Nao excluo movimentos de reposicao
	// Nao excluo movimentos gerados por faturas de entrada
	If(FieldPos("EU_TIPDEB")) > 0 .and. SEU->EU_TIPDEB == "_NF_"   //CHILE
			lRet := .F.
			Help(,,STR0054,,STR0088,1,0)		//"Este movimento foi gerado por uma fatura de entrada, somente poderá ser anulado pela exclusão dessa fatura."
		Else
		If SEU->EU_TIPO>="90" .Or. (!Empty(SEU->EU_BAIXA) .and. !lPermiss) .OR. SEU->EU_TIPO $ "02#10#11" .or. lClosedCx ;
				.Or. (SEU->EU_TIPO $ "01" .and. SEU->EU_SLDADIA<>SEU->EU_VALOR .and. lPctCaix == "2")
				Help(" ",1,"FA560BAIXA")
				lRet := .F.
			Endif

		//Caixinha x Juridico
		If lRet .and. lCXJurFin .and. !F560CanDel()	
			Help(" ",1,"NODELJUR",,STR0107,1,0)		//"Não é possivel excluir este registro pois o mesmo possui movimentos de pré-faturamento de serviços (módulo SIGAPFS) e os mesmos já foram faturados."
			lRet := .F.
		Endif
	Endif

	If lRet .and. lPadrao579   .And. lGeraLanc
		If nHdlPrv <= 0
			LoteCont("FIN")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa Lancamento Contabil                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nHdlPrv := HeadProva( cLote,;
			                      	"FINA560" /*cPrograma*/,;
			                      	Substr( cUsuario, 7, 6 ),;
			                      	@cArquivo )
		Endif
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia lancamento no PCO                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		PcoIniLan("000359")
	Endif

	While lRet
		If SEU->EU_TIPO == "00" // Reembolso
			cMens := OemToAnsi(STR0013)  //"Quanto … exclus„o?"
		Else
			dbSelectArea("SEU")
			dbSetOrder(3)  // filial + nroadia
			If dbSeek( xFilial() + EU_NUM)
				cMens := OemToAnsi(STR0018)  //"Serao excluidos comprovantes do adiantamento. Continua?"
			Else
				cMens := OemToAnsi(STR0013)  //"Quanto … exclus„o?"
			EndIf
			RestArea(aArea)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envia para processamento dos Gets          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nOpcA:=0
		SoftLock(cAlias)

		If lPanelFin  //Chamado pelo Painel Financeiro
			dbSelectArea("SEU")
			RegToMemory("SEU",.F.,.F.,,FunName())                                       
			oPanelDados := FinWindow:GetVisPanel()
			oPanelDados:FreeChildren()
			aDim := DLGinPANEL(oPanelDados)
			DEFINE MSDIALOG oDlg OF oPanelDados:oWnd FROM 0, 0 TO 0, 0 PIXEL STYLE nOR( WS_VISIBLE, WS_POPUP )	
			aPosEnch := {,,,}
			oEnc01:= MsMGet():New( cAlias, nReg, nOpc,,"AC",cMens,,,,,,,,oDlg,,,.F.) 						
			oEnc01:oBox:Align := CONTROL_ALIGN_ALLCLIENT
					
			// define dimenção da dialog
			oDlg:nWidth := aDim[4]-aDim[2]
		
			ACTIVATE MSDIALOG oDlg  ON INIT ( FaMyBar(oDlg,{||nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()}),	oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1]))

		Else		
			aSize := MsAdvSize()
			aObjects := {}
			AAdd( aObjects, { 100, 100, .t., .t. } )

			aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
			aPosObj := MsObjSize( aInfo, aObjects )

			DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 to aSize[6],aSize[5] of oMainWnd Pixel
			nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",cMens, , aPosObj[1])
			nOpca := 1
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})
		Endif
		
		DbSelectArea(cAlias)
		
		If lOk .And. nOpcA == 2
			If SEU->EU_TIPO == "00"
				nRecnoSEU := SEU->(Recno())
				If SEU->(FieldPos("EU_NFISCAL")) > 0 .and. SEU->(FieldPos("EU_SERIE")) > 0
			   		If ! Empty(SEU->EU_NFISCAL)	

						SF1->(dbSetOrder(1))
						SF1->(dbSeek(xFilial("SF1")+SEU->EU_NFISCAL+SEU->EU_SERIE+SEU->EU_FORNECE+SEU->EU_LOJA))
						
          				aCab := {}
         				AADD(aCab,{"F1_DOC"    ,SF1->F1_DOC    ,".T."})   
         				AADD(aCab,{"F1_SERIE"  ,SF1->F1_SERIE  ,".T."})   
         				AADD(aCab,{"F1_FORNECE",SF1->F1_FORNECE,".T."})     
         				AADD(aCab,{"F1_LOJA"   ,SF1->F1_LOJA   ,".T."})    
         				AADD(aCab,{"F1_TIPODOC",SF1->F1_TIPODOC,".T."})   
         				AADD(aCab,{"F1_MOEDA"  ,SF1->F1_MOEDA  ,".T."})   
         				AADD(aCab,{"F1_TXMOEDA",SF1->F1_TXMOEDA,".T."})   

						SD1->(dbSetOrder(1))
						SD1->(dbSeek(xFilial("SD1")+SEU->EU_NFISCAL+SEU->EU_SERIE+SEU->EU_FORNECE+SEU->EU_LOJA))
                        While SD1->(!Eof()) .and. SD1->D1_FILIAL == xFilial("SD1") .and.;
                        	  SD1->D1_DOC == SEU->EU_NFISCAL .and. SD1->D1_SERIE == SEU->EU_SERIE .and.; 
                        	  SD1->D1_FORNECE == SEU->EU_FORNECE .and. SD1->D1_LOJA == SEU->EU_LOJA  
                        	aItem:={}
            				AADD(aItem,{"D1_DOC"    ,SD1->D1_DOC    ,".T."})
            				AADD(aItem,{"D1_SERIE"  ,SD1->D1_SERIE  ,".T."})
            				AADD(aItem,{"D1_FORNECE",SD1->D1_FORNECE,".T."})
            				AADD(aItem,{"D1_LOJA"   ,SD1->D1_LOJA   ,".T."})
            				AADD(aItens,ACLONE(aItem))
                            SD1->(dbSkip())
                        End 
  
                   		MsgRun(OemToAnsi(STR0080),,{||MSExecAuto({|x,y,z| MATA101N(x,y,z)},aCab,aItens,5)})
					    If lMSErroAuto  
    	   					MostraErro()       
       						Return .F.
    					EndIf
	      			EndIf
         		EndIf										
				If  nHdlPrv > 0 .And. lGeraLanc
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Prepara Lancamento Contabil                                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil 
							aAdd( aFlagCTB, {"EU_LA", "S", "SEU", SEU->( Recno() ), 0, 0, 0} )
						Endif
						nTotal += DetProva( nHdlPrv,;
						                    "579" /*cPadrao*/,;
						                    "FINA560" /*cPrograma*/,;
						                    cLote,;
						                    /*nLinha*/,;
						                    /*lExecuta*/,;
						                    /*cCriterio*/,;
						                    /*lRateio*/,;
						                    /*cChaveBusca*/,;
						                    /*aCT5*/,;
						                    /*lPosiciona*/,;
						                    @aFlagCTB,;
						                    /*aTabRecOri*/,;
						                    /*aDadosProva*/ )
						 
		
						                    
				Endif	  
				SEU->(dbGoTo(nRecnoSEU))	  
				cIntMov := SEU->EU_NUM			
				Fa560FcAdi( SEU->(Recno()), SEU->EU_VALOR, GetSx8Len(),, .T.)
				
				//Integração caixinha x juridico
				If lCXJurFin .and. SEU->EU_DESPJUR == '1'
					SEU->(dbGoTo(nRecnoSEU))
					F560DelJur(SEU->EU_NUM,SEU->EU_SEQJUR)
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de entrada F560DEL1              			 	³
				//³ Destina-se a gravacoes complementares da exclusao  ³
				//³ do movimento do caixinha 	      						 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("F560DEL2")
					ExecBlock("F560DEL2",.F.,.F.)
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Estorna o Movim. de Custo de Transporte                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If IntTMS() .And. nModulo == 43  				
					If (!Empty(SEU->EU_CODVEI) .And. !Empty(SEU->EU_CODDES) .And. Posicione("DA3",1,xFilial("DA3")+SEU->EU_CODVEI,"DA3_FROVEI") == StrZero(1,Len(DA3->DA3_FROVEI))) .Or. ;
					   (!Empty(SEU->EU_FILORI) .And. !Empty(SEU->EU_VIAGEM) .And. !Empty(SEU->EU_CODDES))
						SDG->(dbSetOrder(5))
						SDG->(MsSeek(cSeek:=xFilial("SDG")+SEU->EU_FILORI+SEU->EU_VIAGEM+SEU->EU_CODVEI))
						Do While SDG->(!Eof()) .And. SDG->(DG_FILIAL+DG_FILORI+DG_VIAGEM+DG_CODVEI) == cSeek
							If SDG->DG_ORIGEM == "SEU" .And. SDG->DG_CODDES == SEU->EU_CODDES
								If lExeIntTms  .And. SDG->DG_INTMOV == cIntMov
									RecLock('SDG',.F.)
									dbDelete()
									MsUnLock()
									Exit
								Else									
									RecLock('SDG',.F.)
									dbDelete()
									MsUnLock()
									Exit
								EndIf	
							EndIf
							SDG->(dbSkip())
						EndDo
					EndIf						
					If lExeIntTms .And. lMntTms 
						TmsMntEsOs('2',SEU->EU_FILORI,SEU->EU_VIAGEM,SEU->EU_CODVEI,SEU->EU_CODDES,cIntMov)
					EndIf      
				EndIf	
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ apos passar por todas as verificacoes , deleta o registro    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Begin Transaction
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Caso tipo adiantamento, exclui seus comprovantes primeiro       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SEU->EU_TIPO == "01" // Adiantamento
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Devolve valor do adiantamento para o saldo do caixinha      ³
					//³ mesma quando ja' foi reposto o valor do caixinha e sequencia³
					//³ do SET e SEU nao coincidem mais.                            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					
					cNroAdia := SEU->EU_NUM
					aAreaSEU := GetArea()
					
					dbSelectArea("SEU")
					dbSetOrder(3)  // EU_FILIAL + EU_NROADIA + EU_NUM
					SEU->( dbSeek( xFilial() + cNroAdia ) )
					
					While		!SEU->(Eof()) .and.;
								(SEU->EU_FILIAL == xFilial()) .and.;
								(SEU->EU_NROADIA == cNroAdia) .and.;
								(SEU->EU_LA == "S")
								
						If  nHdlPrv > 0
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Prepara Lancamento Contabil                                      ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil 
									aAdd( aFlagCTB, {"EU_LA", "S", "SEU", SEU->( Recno() ), 0, 0, 0} )
								Endif
								nTotal += DetProva( nHdlPrv,;
								                    "579" /*cPadrao*/,;
								                    "FINA560" /*cPrograma*/,;
								                    cLote,;
								                    /*nLinha*/,;
								                    /*lExecuta*/,;
								                    /*cCriterio*/,;
								                    /*lRateio*/,;
								                    /*cChaveBusca*/,;
								                    /*aCT5*/,;
								                    /*lPosiciona*/,;
								                    @aFlagCTB,;
								                    /*aTabRecOri*/,;
								                    /*aDadosProva*/ )
						Endif
					   SEU->( dbSkip() )
					Enddo					

					RestArea(aAreaSEU)
					If ( SEU->EU_SLDADIA > 0 ) .And. ( SEU->EU_SEQCXA < SET->ET_SEQCXA   )
						Fa560FcAdi(SEU->(Recno()),SEU->EU_SLDADIA,GetSx8Len())
					Endif
										   
					dbSelectArea("SEU")
					dbSetOrder(1)  // filial + nroadia
					While dbSeek( xFilial() + cNroAdia)					

						//Integração caixinha x juridico
						If lCXJurFin .and. SEU->EU_DESPJUR == '1'
							F560DelJur(cNroAdia)
						Endif


						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Ponto de entrada F560DEL3              				 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If ExistBlock("F560DEL3")
							ExecBlock("F560DEL3",.F.,.F.)
						Endif

						RecLock(cAlias,.F.,.t.) 
						dbDelete()
						MsUnlock()
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Gravacao dos lancamentos do SIGAPCO                       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						PcoDetLan("000359","02","FINA560", .T.)
						
					EndDo
					RestArea(aArea)										
					
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de entrada F560DEL1              				 ³
				//³ Destina-se a gravacoes complementares da exclusao  ³
				//³ do movimento do caixinha 							 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("F560DEL1")
					ExecBlock("F560DEL1",.F.,.F.)
				Endif
				
				DbSelectArea(cAlias)
				RecLock(cAlias,.F.,.t.)
				nVlrDel  := EU_VALOR
				cNroAdia := EU_NROADIA
				dBaixa   := EU_BAIXA
				If  nHdlPrv > 0 .And. SEU->EU_LA == "S"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Prepara Lancamento Contabil                                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil 
							aAdd( aFlagCTB, {"EU_LA", "S", "SEU", SEU->( Recno() ), 0, 0, 0} )
						Endif
						nTotal += DetProva( nHdlPrv,;
						                    "579" /*cPadrao*/,;
						                    "FINA560" /*cPrograma*/,;
						                    cLote,;
						                    /*nLinha*/,;
						                    /*lExecuta*/,;
						                    /*cCriterio*/,;
						                    /*lRateio*/,;
						                    /*cChaveBusca*/,;
						                    /*aCT5*/,;
						                    /*lPosiciona*/,;
						                    @aFlagCTB,;
						                    /*aTabRecOri*/,;
						                    /*aDadosProva*/ )
				Endif
				dbDelete()
				MsUnlock()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gravacao dos lancamentos do SIGAPCO                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PcoDetLan("000359","02","FINA560", .T.)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza saldo do caixinha se nao for      ³
				//³ comprovante de adiantamento, caso contrario³
				//³ atualiza saldo do adiantamento             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				If Empty(cNroAdia)
					If Empty(dBaixa) .or. lPermiss // somente atualiza se nao for baixado/rendido
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza saldo do caixinha e niveis superiores, se houverem ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

						If FindFunction( "FXMultSld()" ) .AND. FXMultSld()
							AtuSalCxa( SEU->EU_CAIXA , dDataBase , SEU->EU_VALOR )
						EndIf
						
						dbSelectArea("SET")
						dbSetOrder(1)
						dbSeek( xFilial()+SEU->EU_CAIXA)
						
					If lPctCaix == "1"
						nSldAtu := ET_SALDO + SEU->EU_SLDADIA //Fa570AtuSld( SET->ET_CODIGO) - Reprocessava todos os saldos do caixinha para retornar o valor da devolução - desnecessário, o valor a devolver está posicionado (SEU->EU_VALOR)
						RecLock("SET",.F.)
						REPLACE ET_SALDO WITH nSldAtu  
					Else
					    nSldAtu := ET_SALDO + SEU->EU_VALOR
					    RecLock("SET",.F.) 
						REPLACE ET_SALDO WITH nSldAtu  	
					Endif	
						MsUnlock()
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Gravacao dos lancamentos do SIGAPCO                       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						PcoDetLan("000359","01","FINA560")
						
					EndIf
				Else
					dbSelectArea("SEU")
					dbSetOrder(1)
					dbSeek( xFilial()+cNroAdia)
					If Empty( EU_BAIXA) .or. lPermiss  // somente atualiza se nao for baixado/rendido
						RecLock("SEU",.F.)
						REPLACE EU_SLDADIA WITH EU_SLDADIA + nVlrDel
						If !Empty(EU_BAIXA)
							REPLACE EU_BAIXA WITH CTOD("//")
						Endif
						MsUnlock()
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Gravacao dos lancamentos do SIGAPCO                       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						PcoDetLan("000359","02","FINA560")
						
						RestArea(aArea)
					EndIf
				EndIf
				End Transaction
			EndIf
	
			If nHdlPrv > 0 .and. lPadrao579  .And. lGeraLanc
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Efetiva Lan‡amento Contabil                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RodaProva( nHdlPrv,;
				           nTotal )
				If ( FindFunction( "UsaSeqCor" ) .And. UsaSeqCor() )
					cCodDiario := CTBAVerDia() 
					AADD(aDiario,{"SEU",SEU->(recno()),cCodDiario,"EU_NODIA","EU_DIACTB"})
				Endif   
				If lUsaFlag .And. !EMPTY(SEU->EU_NUM) // Armazena em aFlagCTB para atualizar no modulo Contabil 
					aAdd( aFlagCTB, {"EU_LA", "S", "SEU", SEU->( Recno() ), 0, 0, 0} )
				Endif                            
				cA100Incl( cArquivo,;
				           nHdlPrv,;
				           3 /*nOpcx*/,;
				           cLote,;
				           lDigita,;
				           lAglutina /*lAglut*/,;
				           /*cOnLine*/,;
				           /*dData*/,;
				           /*dReproc*/,;
				           @aFlagCTB,;
				           /*aDadosProva*/,;
				           aDiario )
				aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
			
     			If !lUsaflag .And. !Empty(SEU->EU_NUM)
					Reclock("SEU",.F.)
					Replace EU_LA	With "S"
					MsUnLock()
				EndIf
		    EndIf
		Else
			MsUnLock()
		ENDIF
		EXIT
	EndDo       

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a gravacao dos lancamentos do SIGAPCO            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		PcoFinLan("000359")
	Endif

EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada F560DEL3              				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("F560DEL4")
	ExecBlock("F560DEL4",.F.,.F.)
Endif

dbSelectArea(cAlias)
Return /*FUNCTION FA560Deleta*/


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA560Valor³ Autor ³ Leonardo Ruben        ³ Data ³ 28.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao do campo EU_VALOR                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Fa560Valor()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA560                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa560Valor(nValor,cCaixa,lTela)
Local aAreaAnt := GetArea()
Local lRet     := .T.
Local nx
Local nPosValor := 0
Local lRetValor :=.T.
Local lVlPrtCM:= GetNewPar("MV_PCTCXMA","2")=="1"  // Permite prestacao de contas a maior no adiantamento

DEFAULT nValor := M->EU_VALOR
DEFAULT cCaixa := IIF(Type("M->EU_CAIXA")=="C",M->EU_CAIXA, SEU->EU_CAIXA)
DEFAULT lTela  := .T.

If ExistBlock("F560VALOR")
	lRetValor:=ExecBlock("F560VALOR",.F.,.F.)
Endif

If nValor <= 0
	Help(" ",1,"FA560VALOR")
	lRet := .F.
ElseIf ValType("cCaixa")=="C" .And. Empty(cCaixa)
	// No caso de adiantamento, o acols nao contem o campo EU_CAIXA
	Help(" ",1,"FA560CXVAZ")
	lRet := .F.
ElseIf  ValType("cCaixa")=="C" .And. Type("OSALDO")!="O"
	dbSelectArea("SET")
	dbSetOrder(1)
	dbSeek( xFilial()+cCaixa)
	If SET->ET_SALDO < nValor .and. lRetValor   // Valor informado e' superior ao saldo
		Help(" ",1,"FA560SALDO")
		lRet := .F.
	EndIf
EndIf

nValorPrest := 0

If lTela .And. Type("OSALDO")!="U"
	// Validacao do valor digitado no aCols (caso de adiantamentos)
	// Remonta o saldo do adiantamento de acordo com o aCols
	nPosValor := Ascan( aHeader, {|x| AllTrim(x[2])=="EU_VALOR" } )
	nFa560sld  := nSldOrig
	For nx := 1 To Len(aCols)
		If !aCols[nx,Len(aCols[nx])]  // not deleted
			If n == nx
				nFa560sld -= M->EU_VALOR
				nValorPrest := nValorPrest + M->EU_VALOR
			Else
				nFa560sld -= aCols[nx][nPosValor]
				nValorPrest := nValorPrest + aCols[nx][nPosValor]
			EndIf
		EndIf
	Next nx
	oSaldo:Refresh()

	
	If lVlPrtCM						
	    If nValorPrest > (SET->ET_SALDO + nSldOrig)
 	 	   Help(" ",1,"F560PDMAAD",,STR0049+chr(10)+STR0050,1,1) // "A prestacao de contas supera" # "o saldo limite do caixinha"
			lRet := .F.						 	 	 	
 	    EndIf		
		
	ElseIf nFa560sld < 0     // saldo negativo
		Help(" ",1,"FA560SLDAD")
		lRet := .F.
	EndIf
EndIf

RestArea(aAreaAnt)
Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA560Adian³ Autor ³ Leonardo Ruben        ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Baixa de ingressos tipo Adiantamento (Caixinha)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FA560Adian(ExpC1,ExpN1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo							    ³±±
±±³			 ³ ExpN1 = N£mero do registro 					    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA560                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa560Adian(cAlias,nReg)
Local lPanelFin := If (FindFunction("IsPanelFin"),IsPanelFin(),.F.)
Local lGravaOK 	:= .T.
Local nOpca		:= 0
Local nUsado 	:= 0
Local oDlg, oGet
Local lContinua := .T.
Local cCampos   := ""
Local cNroAnt   := SEU->EU_NUM
Local oFont
Local nRecnoSEU := SEU->(Recno())
Local cCaption
Local lF560Cpos := ExistBlock("F560CPOS")
Local nSaveSx8  := GetSx8Len()
Local nY := 0
Local lFa550Adia:=	ExistBlock("FA550ADF")            

Local nTimeOut  := SuperGetMv("MV_FATOUT",,900)*1000 	// Estabelece 15 minutos para que o usuarios selecione
Local nTimeMsg  := SuperGetMv("MV_MSGTIME",,120)*1000 	// Estabelece 02 minutos para exibir a mensagem para o usuário
Local oTimer

Local lPadrao579 := VerPadrao("579")
Local lPadrao572 := VerPadrao("572")
Local lGeraLanc  := Iif(mv_par03 ==1,.T.,.F.)
Local lDigita    := Iif(mv_par01 ==1,.T.,.F.)
Local lAglutina  := Iif(mv_par02 ==1,.T.,.F.)
Local aSEUCont	  :={}             
Local nHdlPrv    := 0  
Local cArquivo
Local nTotal     := 0
Local aFlagCTB := {}
Local lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/) 
Local lCXJurFin	:= If(FindFunction("FVldJurxFin"),FVldJurxFin(),.F.)
Local cBenef := SEU->EU_BENEF 
Local lRepSald := .F.

Private 	cLote    	:= ""
PRIVATE 	aHeader 	:= {}
PRIVATE 	aCols   	:= {}
PRIVATE 	aNroCols	:= {}
Private 	bNumRel
Private 	oSaldo  	:= NIL
PRIVATE ADIANTAMENTO:=	.T.

Private aFolTms     := {}
Private aFolTmsBkp  := {}

If SEU->EU_TIPO <> "01" //somente adiantamentos
	Help(" ",1,"FA560TIPO")
	dbSelectArea(cAlias)
	Return /*Function Fa560Adian*/
ElseIf SEU->EU_SLDADIA <= 0 //somente adiantamentos com saldo
	Help(" ",1,"FA560SALDO")
	dbSelectArea(cAlias)
	Return/*Function Fa560Adian*/
EndIf

If SEU->EU_EMISSAO > dDataBase  //somente adiantamentos com data anterior ou igual a data base
	MsgStop(STR0041,STR0040)  // "Adiantamento com data superior a data do sistema" ## "Data"
	dbSelectArea(cAlias)
	Return /*Function Fa560Adian*/
EndIf
               
If cPaisLoc $ "ARG|BOL"
	If SEU->(FieldPos("EU_STATUS")) > 0 .And. !(SEU->EU_STATUS $ '03|05') //Somente adiantamento aprovados
		Help(" ",1,"Fa560Adian",,STR0082,1,0) //"Adiantamento pendente de aprovacao."
		dbSelectArea(cAlias)
		Return
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a montagem do aHeader a partir dos campos SX3.           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCampos := "EU_NRREND|EU_HISTOR|EU_FORNECE|EU_LOJA|EU_NOME|EU_CGC|EU_EMISSAO|EU_NRCOMP|EU_VALOR|EU_CONTA|EU_CCD|EU_CCC|EU_ITEMD|EU_ITEMC|"

//Pe para possibilitar a inclusao de outros campos na tela de Prestação de Cotnas
If ExistBlock("FT560CPC")
	aCmpPE := ExecBlock("FT560CPC",.f.,.f.)
	For nY = 1 to Len(aCmpPE) 
		If SEU->(FieldPos(aCmpPE[nY])) > 0 .and. !(aCmpPE[nY] $ cCampos )
			cCampos += aCmpPE[nY] + "|"
		EndIf
	Next nY
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Integracao com o Modulo de Transporte (TMS)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If IntTMS() .And. nModulo == 43
	cCampos += "EU_FILORI|EU_VIAGEM|EU_CODVEI|EU_DESVEI|EU_CODDES|"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no DTQ (Viagem), pois, o SXB do campo Cod. Veiculo,³
	//³ filtra somente os veiculos utilizados na Viagem posicionada  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DTQ->(dbSetOrder(2))
	DTQ->(MsSeek(xFilial('DTQ')+ Left(cNroAnt,Len(DTQ->(DTQ_FILORI+DTQ_VIAGEM)))   ))
		
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Integracao com o Modulo SIGAPFS/SIGAJURI   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCXJurFin
	//Se foi um movimento de adiantamento juridico
	If SEU->EU_TIPO == '01' .AND. SEU->EU_DESPJUR == '1'
		cCampos += "EU_TIPDESP|EU_PROFISS|EU_NATUREZ|EU_FATJUR|EU_CLIENTE|EU_LOJACLI|EU_CASO|EU_ESCRIT|EU_GRPJUR|EU_MEMDSCR|"
	Endif
Endif

//Ponto de entrada para adicao de campos na getdados.
If lF560Cpos
	cCampos += ExecBlock("F560CPOS",.F.,.F.,cCampos)
Endif

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(cAlias)
While !EOF() .And. (x3_arquivo == cAlias)
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. Trim(x3_campo)$ cCampos
		nUsado++
        AADD(aHeader,{ TRIM(X3Titulo()) ,;
        AllTrim(SX3->X3_CAMPO),;
        SX3->X3_PICTURE ,;
        SX3->X3_TAMANHO ,;
        SX3->X3_DECIMAL ,;
        SX3->X3_VALID ,;
        SX3->X3_USADO ,;
        SX3->X3_TIPO ,;
        SX3->X3_ARQUIVO ,;
        SX3->X3_CONTEXT,;
        SX3->X3_RELACAO } )
	Endif
	If Trim(x3_campo) == "EU_NUM"
		bNumRel := X3_RELACAO	
	EndIf
	dbSkip()
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a montagem do aCols              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
dbSetOrder(3)  // filial+nroadia
aadd(aCols,Array(nUsado+1))    

For ny := 1 to Len(aHeader)
	If ( aHeader[ny][10] != "V")
		aCols[1][ny] := CriaVar(aHeader[ny][2])
	EndIf
	aCols[1][nUsado+1] := .F.  
Next ny


dbSelectArea(cAlias)
dbSetOrder(1)       // volta ao indice original
dbGoto( nRecnoSEU)  // volta ao registro do adiantamento
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do cabecalho e getdados                             ³                           
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private fa560Cod := SEU->EU_CAIXA
Private nFa560sld:= SEU->EU_SLDADIA
Private fa560Nro := SEU->EU_NUM
Private nSldOrig := SEU->EU_SLDADIA
Private fa560Seq := ""
Private dDataAdi := SEU->EU_EMISSAO
Private fa560Apro:= If(SEU->(FieldPos("EU_CODAPRO")) > 0, SEU->EU_CODAPRO, "")
Private fa560Moed:= If(SEU->(FieldPos("EU_MOEDA")) > 0, SEU->EU_MOEDA, "")
Private fa560Ben := SEU->EU_BENEF


fa560Seq := Fa570SeqAtu(fa560Cod)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se ja existem comprovantes, pergunta se deseja fechar o adiantamento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
dbSetOrder(3)  // filial+nroadia
If dbSeek( xFilial()+ cNroAnt)
	// "Deseja fechar o adiantamento e transferir o saldo remanescente?","Adiantamento com comprovantes ja inclusos"
	If nSldOrig >0
		lRepSald := MsgYesNo(OemToAnsi(STR0023),OemToAnsi(STR0024))
		If lRepSald
		   //MsgYesNo(OemToAnsi(STR0023),OemToAnsi(STR0024))
			Fa560FcAdi(nRecnoSEU,nSldOrig,nSaveSx8,,,,,,,lRepSald)
			
			// CONTABILIZAÇÃO DO REGISTRO GERADO DO FECHAMENTO E TRANSFERENCIA DO SALDO REMANESCENTE
			If lPadrao579 .And. lGeraLanc	
				If nHdlPrv <= 0
					nHdlPrv +=HeadProva(cLote,"FINA560",Subs(cUsuario,7,6),@cArquivo)
				Endif
				If  nHdlPrv > 0 .And. Empty(SEU->EU_LA)
					nTotal	:=	DetProva(nHdlPrv,"579","FINA560",cLote)				
				Endif
				RodaProva(nHdlPrv,nTotal)
			Endif	
			
			If nHdlPrv > 0
				If cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,lAglutina)					
					Reclock("SEU",.F.)
					Replace EU_LA	With "S"
					MsUnLock()
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Gravacao dos lancamentos do SIGAPCO                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PcoDetLan("000359","02","FINA560")
				Endif	
			Endif	
			
			dbSelectArea(cAlias)
			Return /*Function Fa560Adian*/
		EndIf
	EndIf
EndIf     

If Len(aRotina) == 2
	//Tratar aRotina para compatibilizar com a execução MsGetDados
	aRotina := { { STR0056, "FA560CpFis",0 ,3 },;  		//"Comprovantes Fiscais"
	       	     { STR0057, "FA560Adian",0 ,4 },;      	//"Outros Comprovantes"
	       	     { STR0057, "FA560Adian",0 ,4}}       	//"Outros Comprovantes"
EndIf
dbSelectArea(cAlias)
dbSetOrder(1)       // volta ao indice original
dbGoto( nRecnoSEU)  // volta ao registro do adiantamento

dbSelectArea("SET")
dbSetOrder(1)
dbSeek( xFilial()+SEU->EU_CAIXA)

dbSelectArea(cAlias)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia lancamento no PCO                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PcoIniLan("000359")

cCaption :=	SEU->EU_CAIXA	+ " - " +SET->ET_NOME
DEFINE FONT oFont NAME "Arial" SIZE 10,12 BOLD

nOpca := 0

aSize := MSADVSIZE()
		
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0015)+" "+fa560Nro From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL

oDlg:lMaximized := .T.

oTimer:= TTimer():New((nTimeOut-nTimeMsg),{|| MsgTimer(nTimeMsg,oDlg) },oDlg) // Ativa timer
oTimer:Activate()

oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20,.T.,.T. )
oPanel:Align := CONTROL_ALIGN_TOP   

@ 002, 003 SAY OemToAnsi(STR0016)+ " : " PIXEL OF oPanel FONT oFont COLOR CLR_GRAY   //"Caixinha"
@ 002, 050 SAY cCaption 				PIXEL OF oPanel FONT oFont 
@ 002, 200 SAY OemToAnsi(STR0017)  	PIXEL OF oPanel FONT oFont COLOR CLR_GRAY  //"Saldo : "
@ 002, 280 SAY oSaldo VAR nFa560sld PICTURE PesqPict("SEU","EU_SLDADIA") ;
												PIXEL OF oPanel FONT oFont  ;
												COLOR If(nFa560sld<0,CLR_RED,CLR_BLUE)

@ 011, 003 SAY OemToAnsi(STR0043) 	PIXEL OF oPanel FONT oFont COLOR CLR_GRAY  //"Data do Adiantamento:"
@ 011, 100 SAY dDataAdi					PIXEL OF oPanel FONT oFont  
oGet := MSGetDados():New(34,5,128,315,3,"FA560LinOK","FA560TudOK",,.T.,,,,300)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT


If lPanelFin
	ACTIVATE MSDIALOG oDlg ON INIT FaMyBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()})
Else	                	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()})
Endif

If nOpcA == 1
	//Se houve prestacao de contas
	If lContinua .and. nFa560Sld != nSldOrig
		lGravaOk := FA560Grava(cAlias,nRecnoSEU,nSaveSx8,,cBenef)		
			
		If !lGravaOk
			Help(" ",1,"A560NAOREG")
		EndIf
		
	Else //Se nao houve prestacao de contas posso devolver o dinheiro ao caixa
		If (nFa560Sld > 0) .And.;
			(MsgYesNo(OemToAnsi(STR0021),OemToAnsi(STR0022))) 	//"Deseja transferir o saldo remanescente para o caixinha?","Adiantamento com saldo remanescente"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza informacoes do registro de adiantamento            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			lRepSald := .T.
			dbSelectArea("SEU")
			dbGoto(nRecnoSEU)
			
			If lPadrao579 .And. lGeraLanc			
				If nHdlPrv <= 0
					LoteCont("FIN")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Inicializa Lancamento Contabil                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nHdlPrv := HeadProva( cLote,;
						                      "FINA560" /*cPrograma*/,;
						                      Substr( cUsuario, 7, 6 ),;
						                      @cArquivo )
				Endif
				If  nHdlPrv > 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Prepara Lancamento Contabil                                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil 
							aAdd( aFlagCTB, {"EU_LA", "S", "SEU", SEU->( Recno() ), 0, 0, 0} )
						Endif
						nTotal += DetProva( nHdlPrv,;
						                    "579" /*cPadrao*/,;
						                    "FINA560" /*cPrograma*/,;
						                    cLote,;
						                    /*nLinha*/,;
						                    /*lExecuta*/,;
						                    /*cCriterio*/,;
						                    /*lRateio*/,;
						                    /*cChaveBusca*/,;
						                    /*aCT5*/,;
						                    /*lPosiciona*/,;
						                    @aFlagCTB,;
						                    /*aTabRecOri*/,;
						                    /*aDadosProva*/ )
					AAdd(aSEUCont,SEU->(RECNO()))
					Reclock("SEU",.F.)
					Replace EU_LA	With "S"
					MsUnLock()				
				Endif
			EndIf				
			
			If nHdlPrv > 0 .And. nTotal > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Efetiva Lan‡amento Contabil                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					RodaProva( nHdlPrv,;
					           nTotal )                               
					If cA100Incl( cArquivo,;
						           nHdlPrv,;
						           3 /*nOpcx*/,;
						           cLote,;
						           lDigita,;
						           lAglutina /*lAglut*/,;
						           /*cOnLine*/,;
						           /*dData*/,;
						           /*dReproc*/,;
						           @aFlagCTB,;
						           /*aDadosProva*/,;
						           aDiario )
							If !lUsaflag
								Reclock("SEU",.F.)
								Replace EU_LA	With "S"
								MsUnLock()
							Endif
					Endif	
					aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
			EndIf
			Fa560FcAdi(nRecnoSEU,nFa560Sld,nSaveSx8,,,,,,,lRepSald)			
		Endif
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada F560ADIA              				 ³
	//³ Destina-se a gravacoes complementares da exclusao  ³
	//³ do movimento do caixinha 							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("F560ADIA")
		ExecBlock("F560ADIA",.F.,.F.)
	Endif
Endif
MsUnLockAll()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa array da Integração com TMS x MNT			 	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFolTms   	:= {}	
aFolTmsBkp 	:= {}



If lFa550Adia
	ExecBlock("FA550ADF",.F.,.F.,{nOpca==1})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a gravacao dos lancamentos do SIGAPCO            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PcoFinLan("000359")

dbSelectArea(cAlias)
Return /*Function Fa560Adian*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA560LinOk³ Autor ³ Leonardo Ruben        ³ Data ³ 15.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se a linha digitada esta' Ok                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fA560LinOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Fina560                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA560LinOk()
Local nx
Local lRet 		 := .T.
Local lDeleted  := .F.
Local aArea		 := GetArea()    
Local aAreaDT7 
Local nValor	 := 0
Local lCpoCus  
Local nPosValor := 0   
Local lUtiCus   := .T.
Local lCXJurFin	:= If(FindFunction("FVldJurxFin"),FVldJurxFin(),.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Integracao com o Modulo de Transporte (TMS)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If IntTMS()
	aAreaDT7 := DT7->(GetArea())
 	lCpoCus  := DT7->(FieldPos('DT7_UTICUS')) > 0
EndIf

nPosValor := Ascan( aHeader, {|x| AllTrim(x[2])=="EU_VALOR" } )

If ValType(aCols[n,Len(aCols[n])]) == "L"
	lDeleted := aCols[n,Len(aCols[n])]      // Verifica se esta Deletado
EndIf


If !lDeleted
	If ExistBlock("F560LOK")
		lRet := ExecBlock("F560LOK",.F.,.F.)
	Endif
	
	If lRet
		For nx := 1 To Len(aHeader)
			If Trim(aHeader[nx][2]) == "EU_EMISSAO" .AND. n == Len(aCols)
				If aCols[n][nx] < dDataAdi
					MsgStop(STR0042,STR0040) //"Data Comprovante nao pode ser menor que o adiantamento" ##"DATA"
					lRet := .F.
					Exit
			    EndIf
			Endif
			
			
			If lRet .And. Trim(aHeader[nx][2]) == "EU_VALOR" .AND. n == Len(aCols)
				If Empty(aCols[n][nx]) .and. n >= 1
					Help(" ",1,"FA560VALOR")
					lRet := .F.
					Exit
				Else
					nValor := aCols[n][nx]
				Endif
			Endif
			If !lRet
				Exit
			Endif
		Next nx
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Integracao com o Modulo de Transporte (TMS)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .And. IntTMS() .And. nModulo == 43
			If lCpoCus .And. !Empty(GdFieldGet('EU_CODDES',n))
				lUtiCus := .T.
		   		DT7->(dbSetOrder(1))
			   	If DT7->(MsSeek(xFilial('DT7')+GdFieldGet('EU_CODDES',n))) .And. DT7->DT7_UTICUS == '2' //-- Não
					lUtiCus := .F.
				EndIf
			EndIf				
			If lUtiCus
    				If Empty(GdFieldGet('EU_CODVEI',n))  .And. Empty(GdFieldGet('EU_VIAGEM',n))
					Help('',1,'FA560NOINF')  // Informe o No. da Viagem ou o Codigo do Veiculo ...
				   	lRet := .F.
			   	EndIf
			Endif			
			If !Empty(GdFieldGet('EU_CODVEI', n)) .And. (!Empty(GdFieldGet('EU_FILORI', n)) .Or. ;
				!Empty(GdFieldGet('EU_VIAGEM', n)) )
				Help('',1,'FA560ESCOL') //A Viagem e o Veiculo nao poderao ser informados simultaneamente ...
			   	lRet := .F.
			EndIf
		EndIf
		
		//Caixinha x Juridico
		//Validacao especifica para integracao caixinha Financeiro x SigaPFS
		If lRet .and. lCXJurFin .and. SEU->EU_DESPJUR == '1'
                   
			cFatJur := GdFieldGet('EU_FATJUR', n)
	
			If Empty(GdFieldGet('EU_PROFISS', n))		
				Help(" ",1,"F560DJURP1",,STR0090+CRLF+STR0091,1,0)	//'Por tratar-se de uma prestação de contas de adiantamento juridico, o campo abaixo tem seu preenchimento como obrigatório.'###'Prof.Favorec'
				lRet := .F.
			Endif

			If lRet .and. Empty(GdFieldGet('EU_TIPDESP', n))		
				Help(" ",1,"F560DJURP2",,STR0090+CRLF+STR0092,1,0)  //'Por tratar-se de uma prestação de contas de adiantamento juridico, o campo abaixo tem seu preenchimento como obrigatório.'###'Tipo Despesa'
				lRet := .F.
			Endif

			If lRet

				cCliente := GdFieldGet('EU_CLIENTE', n)
				clojaCli := GdFieldGet('EU_LOJACLI', n)
				cCaso	 := GdFieldGet('EU_CASO', n)
				cEscrit  := GdFieldGet('EU_ESCRIT', n)
				cGrpJur  := GdFieldGet('EU_GRPJUR', n)
				cDescri  := GdFieldGet('EU_MEMDSCR', n)

				If cFatJur == '1'	//Despesa cobrada do cliente

					If Empty(cCliente) .OR. Empty(cLojaCli) .OR. Empty(cCaso) .OR. Empty(cDescri)
						Help(" ",1,"F560DJURP2",,STR0093+CRLF+STR0094+CRLF+STR0095+CRLF+STR0096+CRLF+"Descrição",1,0) //'Quando a despesa juridica for reembolsável do cliente, é obrigatório o preenchimento dos campos abaixo:'###'Cliente Jur.'###'Loja Cliente'###'Caso'
						lRet := .F.						 	 	 	
					Endif    
	
    			Else
 
					SED->(dbSetOrder(1))
					If MsSeek(xFilial("SED")+GdFieldGet('EU_NATUREZ', n))
						If SED->ED_ESCRIT == '1'
							If Empty(cEscrit)		
								Help(" ",1,"F560DJURP3",,STR0097+CRLF+STR0098,1,0)	//'Devido a configuração da Natureza o campo abaixo tem seu preenchimento como obrigatório.'###'Escritório'
								lRet := .F.
	                    	ElseIf SED->ED_GRPJUR == '1' .and. Empty(cGrpJur)
								Help(" ",1,"F560DJURP4",,STR0097+CRLF+STR0099,1,0)	//'Devido a configuração da Natureza o campo abaixo tem seu preenchimento como obrigatório.'###'Grupo Jurid.'
								lRet := .F.
							Endif
						Endif
					Endif
				Endif

				If lRet
					//Se a despesa nao vai ser cobrada do cliente, limpo os campos de Cliente, Loja e Caso
					If cFatJur == '2' .and. (!Empty(cCliente) .OR. !Empty(cLojaCli) .OR. !Empty(cCaso))
						GDFieldPut('EU_CLIENTE', "", n) 	
						GDFieldPut('EU_LOJACLI', "", n) 	
						GDFieldPut('EU_CASO'   , "", n) 	
					Endif
					
					//Se a despesa vai ser cobrada do cliente, limpo os campos de escritorio e grupo juridico
					If cFatJur == '1' .and. (!Empty(cEscrit) .OR. !Empty(cGrpJur))
						GDFieldPut('EU_ESCRIT', "", n) 	
						GDFieldPut('EU_GRPJUR', "", n) 	
					Endif
				Endif
			Endif			
		Endif
		
	EndIf
	
	// Remonta o saldo do adiantamento de acordo com o aCols
	If lRet
		nFa560sld := nSldOrig
		For nx := 1 To Len(aCols)
			If !aCols[nx,Len(aCols[nx])]  // not deleted
				nFa560sld -= aCols[nx][nPosValor]
			EndIf
		Next nx
	Endif
Else
	GDFieldPut('EU_VALOR', 0, n) 	
EndIf


oSaldo:Refresh()
RestArea(aArea)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Integracao com o Modulo de Transporte (TMS)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If IntTMS()
	RestArea(aAreaDT7)
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA560TudOk³ Autor ³ Leonardo Ruben        ³ Data ³ 15.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se os comprovantes estao todos ok                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Fina560                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA560TudOk()
Local ny 
Local nx
Local nMaxArray
Local lRet 		:= .T.
Local lDeleted 	:= .F.
Local nPosValor	:= Ascan( aHeader, {|x| AllTrim(x[2])=="EU_VALOR" } )
Local aArea		:= GetArea()
Local lVlPrtCM:= GetNewPar("MV_PCTCXMA","2")=="1"  // Permite prestacao de contas a maior no adiantamento

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O processo de verificacao no array eh efetuado novamente pois existe a possibilidade   ³
//³ do usuario ter excluido um titulo, ter lancado outros e antes do momento de confirmar  ³
//³ ter voltado a habilitar o titulo excluido, ai eh necessario revalidar o seu conteudo   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nValorPrest := 0
For nx := 1 To Len(aCols)
	If !aCols[nx,Len(aCols[nx])]  // not deleted
		nValorPrest := nValorPrest + aCols[nx][nPosValor]
	EndIf
Next nx

If lVlPrtCM	
 	If nValorPrest > (SET->ET_SALDO + nSldOrig)
  	   Help(" ",1,"F560PDMAAD",,STR0049+chr(10)+STR0050,1,1) // "A prestacao de contas supera" # "o saldo limite do caixinha"
       lRet := .F.						 	 	 	
 	EndIf
 	
ElseIf nFa560sld < 0     // saldo negativo
	Help(" ",1,"FA560SLDAD")
	lRet := .F.
EndIf

If lRet .And. ExistBlock("F560TOK")
	lRet := ExecBlock("F560TOK",.F.,.F.)
Endif

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ verifica se o ultimo elemento do array esta em branco        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nMaxArray := Len(aCols)
	
	For ny = 1 to nMaxArray
		If ValType(aCols[ny,Len(aCols[ny])]) == "L"
			lDeleted := aCols[ny,Len(aCols[ny])]      // Se esta Deletado
		End
		If !lDeleted
			If Empty(aCols[ny][nPosValor]) .and. Len(aCols) >= 1
				Help(" ",1,"FA560VALOR")
				lRet := .F.
			Endif
		Endif
	Next ny
	
Endif

	If ( FindFunction( "UsaSeqCor" ) .And. UsaSeqCor() )
		cCodDiario := CTBAVerDia() 
	Endif

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA560Grava³Autor  ³ Leonardo Ruben        ³ Data ³ 15.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os itens do aCols - Caixinha                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fA560Grava(ExpC1,ExpN1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo			    			         ³±±
±±³			 ³ ExpN1 = N£mero do registro 				         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Fina560                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA560Grava(cAlias,nRecnoSEU,nSaveSx8,aCompFis,cBenef)

Local nx			:= 0
Local ny			:= 0
Local nValor		:= 0
Local aArea			:= GetArea()
Local lSeek			:= .f.
Local nSldSobra		:= 0
Local nOrder		:= 0
Local cNroAdia		:= ""
Local cNumRel1		:= ""
Local cNumRel2		:= ""
Local aSEUCont		:={}
Local nHdlPrv		:= 0
Local lDigita		:= Iif(mv_par01 ==1,.T.,.F.)
Local lAglutina		:= Iif(mv_par02 ==1,.T.,.F.)
Local lGeraLanc		:= Iif(mv_par03 ==1,.T.,.F.)
Local cArquivo
Local lPadrao572	:= VerPadrao("572")
Local lPadrao579	:= VerPadrao("579")
Local nTotal		:= 0                        
Local nSaldoAdi		:= 0
Local i := 1   
Local lRepSald := .F.

Local aFlagCTB		:= {}
Local lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ variaveis para Integração TMSx x MNT  			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lGerOs 		:= .F.                        
Local lMntTms 		:= ( SuperGetMV( "MV_NGMNTMS",,'N') == 'S' )//-- Ativa integracao TMS X MNT.
Local cSerDesp  	:= ( SuperGetMV('MV_SERDESP',,'' ) )
Local lR5        	:= GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao    	:= Val(GetVersao(.F.))     // Indica a versao do Protheus
Local lExeIntTms 	:= ((nVersao == 11 .And. lR5) .Or. nVersao > 11) //-- Verificação de Release .5 do Protheus 11
Local aCab          := {}
Local aItem         := {}
Local lClasNF		:= (SuperGetMV("MV_CLASSNF") == "1")
Local cProduto      := GetNewPar("MV_FINPDRG","RG499")  //Produto Genérico para Prestação de Contas (Rendicion de Gastos).
Local cTES		    := GetNewPar("MV_FINTERG","499") 	//TES genérico para Prestação de Contas (Rendicion de Gastos).
Local cCondPag      := GetNewPar("MV_FINCPRG","499") 	//Condição de Pagamento (Rendicion de Gastos).
                                                             
Local lCXJurFin	:= If(FindFunction("FVldJurxFin"),FVldJurxFin(),.F.)
                                                             
DEFAULT aCompFis    := {}
DEFAULT cBenef		:= "."

PRIVATE cLote 		:= "" 
PRIVATE aDiario 	:= {}
PRIVATE lMSErroAuto := .F. 
PRIVATE lMSHelpAuto := .F. // para mostrar os erros na tela
        
If Len(aCompFis) > 0

	SA2->(dbSetOrder(1))
	SA2->(dbSeek(xFilial("SA2")+aCompFis[1][3]+aCompFis[1][4]))

	//Posicionar ou criar Codigo do Produto definido do parametro MV_FINPDRG	                           
	SB1->(dbSetorder(1))
	If !SB1->(dbSeek(xFilial("SB1")+cProduto))    
    	Fa560CProd(cProduto)
    EndIf                                   
    cUM    := SB1->B1_UM
    cSegUM := SB1->B1_SEGUM
    cLocal := SB1->B1_LOCPAD	

	//Posicionar ou criar TES definido do parametro MV_FINTERG	                              
	SF4->(dbSetOrder(1))
	If !SF4->(dbSeek(xFilial("SF4")+cTES))  
		Fa560CTes(cTES)
	EndIf	  
    cCFO := SF4->F4_CF           
    
	//Posicionar ou criar Condição de Pagamento definido do parametro MV_FINCPRG	                              
	SE4->(dbSetOrder(1))
	If !SE4->(dbSeek(xFilial("SE4")+cCondPag))  
		Fa560CCond(cCondPag)
	EndIf
                                          
    nValMerc    := aCompFis[2][5]      //ValMerc                     
    nValIVA 	:= aCompFis[3][1]      //IVA
    nPercIB3895 := aCompFis[3][2]      //IBP
    nPercIVA    := aCompFis[3][3]      //IVP
    nPercIB672  := aCompFis[3][4]      //IB2
    nPercSUSS   := aCompFis[3][5]      //PGA
    nOutraPerc  := aCompFis[3][6]      //IV3

    cConta   := aCompFis[3][7]	//Conta Contabil         
	aCab := {}
    AADD(aCab,{"F1_DOC"    ,aCompFis[1][1] , ".T."})   // NUMERO DA NOTA
    AADD(aCab,{"F1_SERIE"  ,aCompFis[1][2] , ".T."})   // SERIE DA NOTA
    AADD(aCab,{"F1_FORNECE",aCompFis[1][3] , ".T."})   // FORNECEDOR  
    AADD(aCab,{"F1_LOJA"   ,aCompFis[1][4] , ".T."})   // LOJA DO FORNECEDOR 
    AADD(aCab,{"F1_TIPO"   ,"N"			   , ".T."})   // TIPO DA NF
    AADD(aCab,{"F1_EMISSAO",aCompFis[1][5] , ".T."})       
    AADD(aCab,{"F1_DESPESA",aCompFis[2][1] , ".T."})
    AADD(aCab,{"F1_DESCONT",aCompFis[2][2] , ".T."})
    AADD(aCab,{"F1_FRETE"  ,aCompFis[2][3] , ".T."})
    AADD(aCab,{"F1_SEGURO" ,aCompFis[2][4] , ".T."})
    AADD(aCab,{"F1_VALMERC",aCompFis[2][5] , ".T."})               
    AADD(aCab,{"F1_VALBRUT",aCompFis[2][6] , ".T."})    
    AADD(aCab,{"F1_COND"   ,cCondPag	   , ".T."})       
    AADD(aCab,{"F1_MOEDA"  ,1 			   , ".T."})               
    AADD(aCab,{"F1_TXMOEDA",1.00		   , ".T."})
    AADD(aCab,{"F1_EST"	   ,SA2->A2_EST	   , ".T."})
    AADD(aCab,{"F1_ESPECIE",If(cPaisLoc=="BRA","NFE","NF"),".T."})	// NOTA FISCAL DE ENTRADA
	AADD(aCab,{"F1_TIPODOC","10"		   , ".T."})
	AADD(aCab,{"F1_STATUS" ,"A"		  	   , ".T."})
	AADD(aCab,{"F1_NATUREZ",aCompFis[1][6] , ".T."})
    If nValIVA > 0  
    	aImposto := Fa560GetImpos("IVA","SF1")
    	AADD(aCab,{aImposto[1]  ,nValMerc      ,".T."}) 
    	AADD(aCab,{aImposto[3]  ,nValIVA       ,".T."})
    EndIf	 
    If nPercIB3895 > 0  
    	aImposto := Fa560GetImpos("IBP","SF1")
    	AADD(aCab,{aImposto[1]  ,nValMerc      ,".T."}) 
    	AADD(aCab,{aImposto[3]  ,nPercIB3895   ,".T."})
    EndIf
    If nPercIVA > 0  
    	aImposto := Fa560GetImpos("IVP","SF1")
    	AADD(aCab,{aImposto[1]  ,nValMerc      ,".T."}) 
    	AADD(aCab,{aImposto[3]  ,nPercIVA		,".T."})
    EndIf           
    If nPercIB672 > 0  
    	aImposto := Fa560GetImpos("IB2","SF1")
    	AADD(aCab,{aImposto[1]  ,nValMerc      ,".T."}) 
    	AADD(aCab,{aImposto[3]  ,nPercIB672	,".T."})
    EndIf           
    If nPercSUSS > 0  
    	aImposto := Fa560GetImpos("PGA","SF1")
    	AADD(aCab,{aImposto[1]  ,nValMerc      ,".T."}) 
    	AADD(aCab,{aImposto[3]  ,nPercSUSS		,".T."})
    EndIf           
    If nOutraPerc > 0  
    	aImposto := Fa560GetImpos("IV3","SF1")
    	AADD(aCab,{aImposto[1]  ,nValMerc   ,".T."}) 
    	AADD(aCab,{aImposto[3]  ,nOutraPerc	,".T."})
    EndIf           
  
    SF4->(dbSetOrder(1))              
    SF4->(dbSeek(xFilial("SF4")+cTES))
    cCFO     := SF4->F4_CF

    aItens := {}
	aItem  := {}
	AADD(aItem,{"D1_ITEM"     ,"0001"			,".T."})  // Item da NF
	AADD(aItem,{"D1_COD"      ,cProduto			,".T."})  // Codigo do produto
   	AADD(aItem,{"D1_UM"       ,cUM		        ,".T."})  // Unidade do produto
   	AADD(aItem,{"D1_VUNIT"    ,aCompFis[2][5]	,".T."})  // Valor unitario do item
    AADD(aItem,{"D1_QUANT"    ,1		        ,".T."})  // Quantidade do produto
  	AADD(aItem,{"D1_OPER"     ,"51"			    ,".T."})  // Código de Operação    ADMIN	
	AADD(aItem,{"D1_TES"      ,cTES		        ,".T."})  // TES                                            
   	AADD(aItem,{"D1_CF"       ,cCFO			    ,".T."})  // Classificacao Fiscal                                                
	AADD(aItem,{"D1_CONTA"    ,aCompFis[3][7]   ,".T."})
	AADD(aItem,{"D1_FORNECE"  ,aCompFis[1][3]   ,".T."})
	AADD(aItem,{"D1_LOJA"     ,aCompFis[1][4]   ,".T."})
	AADD(aItem,{"D1_LOCAL"    ,cLocal           ,".T."})
	AADD(aItem,{"D1_DOC"      ,aCompFis[1][1]   ,".T."})
	AADD(aItem,{"D1_SERIE"    ,aCompFis[1][2] 	,".T."})
	AADD(aItem,{"D1_EMISSAO"  ,aCompFis[1][5]	,".T."})
	AADD(aItem,{"D1_DTDIGIT"  ,dDataBase        ,".T."})               
	AADD(aItem,{"D1_TIPO"     ,"N"				,".T."})     	
	AADD(aItem,{"D1_TIPODOC"  ,"10"				,".T."})
	AADD(aItem,{"D1_TOTAL"    ,aCompFis[2][5]   ,".T."})
   	AADD(aItem,{"D1_PEDIDO"   ,""               ,".T."})	// Pedido de compra
   	AADD(aItem,{"D1_ITEMPC"   ,""               ,".T."})	// Item do Pedido de compra                                                                          
    AADD(aItem,{"D1_ESPECIE"  ,If(cPaisLoc=="BRA","NFE","NF"),".T."})	// NOTA FISCAL DE ENTRADA 
    If nValIVA > 0  
    	aImposto := Fa560GetImpos("IVA","SD1")
    	AADD(aItem,{aImposto[1]  ,nValMerc      ,".T."})  
    	AADD(aItem,{aImposto[2]  ,aImposto[4]   ,".T."})    	
    	AADD(aItem,{aImposto[3]  ,nValIVA       ,".T."})
    EndIf	 
    If nPercIB3895 > 0  
    	aImposto := Fa560GetImpos("IBP","SD1")
    	AADD(aItem,{aImposto[1]  ,nValMerc      ,".T."}) 
    	AADD(aItem,{aImposto[2]  ,aImposto[4]   ,".T."})    	
    	AADD(aItem,{aImposto[3]  ,nPercIB3895   ,".T."})
    EndIf
    If nPercIVA > 0  
    	aImposto := Fa560GetImpos("IVP","SD1")
    	AADD(aItem,{aImposto[1]  ,nValMerc      ,".T."}) 
    	AADD(aItem,{aImposto[2]  ,aImposto[4]   ,".T."})    	
    	AADD(aItem,{aImposto[3]  ,nPercIVA		,".T."})
    EndIf           
    If nPercIB672 > 0  
    	aImposto := Fa560GetImpos("IB2","SD1")
    	AADD(aItem,{aImposto[1]  ,nValMerc      ,".T."}) 
    	AADD(aItem,{aImposto[2]  ,aImposto[4]   ,".T."})    	
    	AADD(aItem,{aImposto[3]  ,nPercIB672	,".T."})
    EndIf           
    If nPercSUSS > 0  
    	aImposto := Fa560GetImpos("PGA","SD1")
    	AADD(aItem,{aImposto[1]  ,nValMerc      ,".T."}) 
    	AADD(aItem,{aImposto[2]  ,aImposto[4]   ,".T."})    	
    	AADD(aItem,{aImposto[3]  ,nPercSUSS		,".T."})
    EndIf           
    If nOutraPerc > 0  
    	aImposto := Fa560GetImpos("IV3","SD1")
    	AADD(aItem,{aImposto[1]  ,nValMerc      ,".T."}) 
    	AADD(aItem,{aImposto[2]  ,aImposto[4]   ,".T."})    	
    	AADD(aItem,{aImposto[3]  ,nOutraPerc	,".T."})
    EndIf           
    AADD(aItens,ACLONE(aItem))

   	MsgRun(OemToAnsi(STR0078),,{||MSExecAuto({|x,y,z| MATA101N(x,y,z)},aCab,aItens,3)}) //"Grabando el comprobante fiscal"

    If lMSErroAuto  
       MostraErro()       
       RestArea(aArea)
       Return .F.
    EndIf
EndIf

Begin Transaction   

For nx = 1 to Len(aCols)
	
	If ValType(aCols[nx,Len(aCols[nx])]) == "L"  /// Verifico se posso Deletar
		lDeleted := aCols[nx,Len(aCols[nx])]      /// Se esta Deletado
	EndIf              
	
	For ny := 1 to Len(aHeader)
		If aHeader[ny][2] $ "EU_CCC|EU_CCD|EU_ITEMC|EU_ITEMD" .And. Empty(aCols[nx][ny]) 
			aCols[nx][ny] := SEU->&(aHeader[ny][2])
		EndIf
	Next ny
	
	If !lDeleted
		lSeek := .f.
		If Len(aNroCols) >= nx
			lSeek := dbSeek( xFilial()+aNroCols[nx][1])
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Insere ou altera comprovantes do adiantamento   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lSeek
			RecLock(cAlias,.T.)
			cNumRel1 := &bNumRel    // Numero sequencial/semaforo (x3_relacao)
			ConfirmSX8()
			cNumRel2 := &bNumRel    // Numero sequencial/semaforo (x3_relacao)
			ConfirmSX8()
			Replace EU_FILIAL  With xFilial("SEU")
			Replace EU_NUM     With cNumRel1
			Replace EU_CAIXA   With fa560Cod
			Replace EU_DTDIGIT With dDataBase
			Replace EU_TIPO    With "00"         // Reembolso
			Replace EU_NROADIA With fa560Nro    // informa a que adiantamento se refere
			Replace EU_SEQCXA  With fa560Seq 
			
			If SEU->(FieldPos("EU_MOEDA")) > 0
				Replace EU_MOEDA   With fa560Moed  
			EndIf
			
			If SEU->(FieldPos("EU_STATUS")) > 0
				Replace EU_STATUS	With "03"
				Replace EU_CODAPRO	With fa560Apro				
			EndIf
				
		Else
			RecLock(cAlias,.F.)
		EndIf
		
			//alimenta a diario ver se posiciona certo
		If ( FindFunction( "UsaSeqCor" ) .And. UsaSeqCor() ) 
			AADD(aDiario,{"SEU",SEU->(recno()),cCodDiario,"EU_NODIA","EU_DIACTB"})
		Endif 	
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza com informacoes do aCols  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For ny = 1 to Len(aHeader)
			If aHeader[ny][10] # "V"
				SEU->(FieldPut( FieldPos( AllTrim(aHeader[ny][2]) ), aCols[nx][ny]))
			Endif
		Next ny
		If Len(aCompFis) > 0 
			If SEU->(FieldPos("EU_NFISCAL")) > 0 .and. SEU->(FieldPos("EU_SERIE")) > 0
				RecLock("SEU",.F.)
				SEU->EU_NFISCAL := aCompFis[1][1]
				SEU->EU_SERIE   := aCompFis[1][2]
				MsUnLock()
			EndIf
		EndIf	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                      
		//³ Integracao com o Modulo de Transporte (TMS)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If IntTMS() .And. nModulo == 43 
			// Grava o Custo de Transporte
			TMA250GrvSDG(cAlias,SEU->EU_FILORI,SEU->EU_VIAGEM,SEU->EU_CODDES,GdFieldGet('EU_VALOR',nX),nX,SEU->EU_CODVEI,,,,,,,SEU->EU_NUM)
			If lExeIntTms //So executar integracao no Release .5 da versao 11 ou versao posterior
				If lMntTms .And. !lGerOs
					// Grava as Ordens de Serviço e Finaliza as mesmas.
					TmsMntGrOs ('2',cSerDesp,aFolTms,aFolTmsBkp,aCols,)
					lGerOs := .T.
				EndIf					
			EndIf	
		EndIf
		
		//CAIXINHA x JURIDICO
		//Grava registro de pre-faturamento no SIGAPFS
		//Se caixinha integrado com SIGAPFS
		//Se eh despesa juridica
		//Se sera reembolsado pelo cliente
		//Se nao sofrera rateio
		If lCXJurFin .and. SEU->EU_TIPO == '00' 
		
			RecLock("SEU",.F.)

			SEU->EU_DESPJUR := '1'
			SEU->EU_RATJUR  := '2'

			If SEU->EU_FATJUR == '1' 

				cCodFat := GeraPFS(3,SEU->EU_NUM,,SEU->EU_CLIENTE,SEU->EU_LOJACLI,SEU->EU_CASO,SEU->EU_PROFISS,SEU->EU_EMISSAO,,SEU->EU_VALOR,SEU->EU_TIPDESP,SEU->EU_MEMDSCR)
				If !Empty(cCodFat)
					SEU->EU_SEQJUR  := cCodFat
				Else
					DisarmTransaction()
					Exit
				Endif	
			Endif
			
			SEU->(MsUnLock()) 

		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravacao dos lancamentos do SIGAPCO                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PcoDetLan("000359","02","FINA560")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza informacoes do registro de adiantamento            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nValor := SEU->EU_VALOR
		If lPadrao572 .And. lGeraLanc
			
			If nHdlPrv <= 0
				LoteCont("FIN")
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inicializa Lancamento Contabil                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nHdlPrv := HeadProva( cLote,;
					                      "FINA560" /*cPrograma*/,;
					                      Substr( cUsuario, 7, 6 ),;
					                      @cArquivo )
			Endif
			If  nHdlPrv > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Prepara Lancamento Contabil                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil 
						aAdd( aFlagCTB, {"EU_LA", "S", "SEU", SEU->( Recno() ), 0, 0, 0} )
					Endif
					nTotal += DetProva( nHdlPrv,;
					                    "572" /*cPadrao*/,;
					                    "FINA560" /*cPrograma*/,;
					                    cLote,;
					                    /*nLinha*/,;
					                    /*lExecuta*/,;
					                    /*cCriterio*/,;
					                    /*lRateio*/,;
					                    /*cChaveBusca*/,;
					                    /*aCT5*/,;
					                    /*lPosiciona*/,;
					                    @aFlagCTB,;
					                    /*aTabRecOri*/,;
					                    /*aDadosProva*/ )
				AAdd(aSEUCont,SEU->(RECNO()))
				Reclock("SEU",.F.)
				Replace EU_LA	With "S"
				MsUnLock()							
			Endif
		EndIf
		If ExistBlock("F560GRV2")
			ExecBlock("F560GRV2",.F.,.F.,{})		
		Endif
		dbSelectArea("SEU")
		dbGoto(nRecnoSEU)       // posiciona no registro tipo adiantamento
		RecLock("SEU",.F.)
		Replace EU_SLDADIA With EU_SLDADIA-If(!lSeek,nValor,nValor-aNroCols[nx][2])
		MsUnlock()

 		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravacao dos lancamentos do SIGAPCO                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PcoDetLan("000359","02","FINA560")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada para gravacao de dadaos complementares dos itens apos a prestacao ³
		//³ de contas do caixinha                                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If ExistBlock("F560PCCX")
			ExecBlock("F560PCCX",.F.,.F.,{})		
		Endif		
		
	Else  // deletados
		
		// apenas aqueles itens que foram carregados inicialmente no aCols
		If Len(aNroCols) >= nx
			If dbSeek( xFilial()+aNroCols[nx][1])
				If ExistBlock("F560DEL5")		
					ExecBlock("F560DEL5",.F.,.F.,{})		
				Endif
				RecLock(cAlias,.F.,.t.)
				dbDelete()
				MsUnlock()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gravacao dos lancamentos do SIGAPCO                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PcoDetLan("000359","02","FINA560", .T.)
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza informacoes do registro de adiantamento            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SEU")
			dbGoto(nRecnoSEU)       // posiciona no registro tipo adiantamento
			RecLock("SEU",.F.)
			Replace EU_SLDADIA With EU_SLDADIA+aNroCols[nx][2]
			MsUnlock()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravacao dos lancamentos do SIGAPCO                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PcoDetLan("000359","02","FINA560")
		EndIf
	EndIf
	dbSelectArea(cAlias)
Next nx

nSaldoAdi:=EU_SLDADIA
If nSaldoAdi < 0              
		RecLock("SEU",.F.)                 
		dbGoto(nRecnoSEU)       // posiciona no registro tipo adiantamento
		RecLock("SEU",.F.)
		MsUnlock()
		RegToMemory("SEU", .F., .T.)
		RecLock("SEU",.T.)                 
		
		bCampo := {|nCPO| Field(nCPO) }
	

		For i := 1 TO FCount()
		 cNome:=EVAL(bCampo,i)
		 Replace &cNome   With M->&(cNome) 
		Next i
		
		Replace EU_FILIAL  	With xFilial("SEU")
		Replace EU_NUM     	With GetSXENum("SEU","EU_NUM")
		Replace EU_CAIXA   	With fa560Cod
		Replace EU_DTDIGIT 	With dDataBase
		Replace EU_TIPO    	With "03"         // COmp. de Adto.
		Replace EU_NROADIA 	With fa560Nro    // informa a que adiantamento se refere
		Replace EU_SEQCXA  	With fa560Seq
		Replace EU_VALOR  	With (nSaldoAdi*-1)
		Replace EU_HISTOR	with   STR0046 + " " + fa560Nro
		Replace EU_LA		With " "       
		If SEU->(FieldPos("EU_STATUS")) > 0
			Replace EU_STATUS	With "01"
		EndIf	
		MsUnlock()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravacao dos lancamentos do SIGAPCO                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PcoDetLan("000359","02","FINA560")

		//**********************************
		// Atulizacao do saldo do caixinha *
		//**********************************
		If FindFunction( "FXMultSld()" ) .AND. FXMultSld()
			AtuSalCxa( SEU->EU_CAIXA , dDataBase , SEU->EU_VALOR )
		EndIf
		
		ConfirmSX8()
		
		If lPadrao572 .and. lGeraLanc
			If nHdlPrv <= 0
				LoteCont("FIN")
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inicializa Lancamento Contabil                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nHdlPrv := HeadProva( cLote,;
					                      "FINA560" /*cPrograma*/,;
					                      Substr( cUsuario, 7, 6 ),;
					                      @cArquivo )
			Endif
			If  nHdlPrv > 0 .And. Empty(SEU->EU_LA)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Prepara Lancamento Contabil                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil 
						aAdd( aFlagCTB, {"EU_LA", "S", "SEU", SEU->( Recno() ), 0, 0, 0} )
					Endif
					nTotal += DetProva( nHdlPrv,;
					                    "572" /*cPadrao*/,;
					                    "FINA560" /*cPrograma*/,;
					                    cLote,;
					                    /*nLinha*/,;
					                    /*lExecuta*/,;
					                    /*cCriterio*/,;
					                    /*lRateio*/,;
					                    /*cChaveBusca*/,;
					                    /*aCT5*/,;
					                    /*lPosiciona*/,;
					                    @aFlagCTB,;
					                    /*aTabRecOri*/,;
					                    /*aDadosProva*/ )
			Endif
			If nHdlPrv > 0 .And. nTotal > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Efetiva Lan‡amento Contabil                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					RodaProva( nHdlPrv,;
					           nTotal )                               
					If cA100Incl( cArquivo,;
						           nHdlPrv,;
						           3 /*nOpcx*/,;
						           cLote,;
						           lDigita,;
						           lAglutina /*lAglut*/,;
						           /*cOnLine*/,;
						           /*dData*/,;
						           /*dReproc*/,;
						           @aFlagCTB,;
						           /*aDadosProva*/,;
						           aDiario )
							If !lUsaflag
								Reclock("SEU",.F.)
								Replace EU_LA	With "S"
								MsUnLock()
							Endif
					Endif	
					aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
			EndIf
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza saldo do caixinha e niveis superiores, se houverem ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SET")
		dbSetOrder(1)
		dbSeek( xFilial()+SEU->EU_CAIXA)
		nSldAtu := Fa570AtuSld( ET_CODIGO)
		RecLock("SET",.F.)
		REPLACE ET_SALDO WITH nSldAtu
		MsUnlock()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravacao dos lancamentos do SIGAPCO                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PcoDetLan("000359","01","FINA560")

EndIf 


End Transaction
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se sobrou saldo no registro de adiantamento,                ³
//³ pergunta-se se deseja REPASSAR O REMANESCENTE para o saldo  ³
//³ do caixinha e com isso o adiantamento ficara com saldo zero,³
//³ o que permitira que o mesmo seja baixado/rendido.           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SEU")
dbGoto(nRecnoSEU)       // posiciona no registro tipo adiantamento
nSldSobra := SEU->EU_SLDADIA
If nSldSobra > 0
   lRepSald := MsgYesNo(OemToAnsi(STR0023),OemToAnsi(STR0024))	//"Deseja transferir o saldo remanescente para o caixinha?","Adiantamento com saldo remanescente"   
  If lRepSald
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza informacoes do registro de adiantamento            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If lPadrao572 .And. lGeraLanc
		If nHdlPrv <= 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa Lancamento Contabil                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nHdlPrv := HeadProva( cLote,;
				                      "FINA560" /*cPrograma*/,;
				                      Substr( cUsuario, 7, 6 ),;
				                      @cArquivo )
		Endif
		If  nHdlPrv > 0 .And. Empty(SEU->EU_LA)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Prepara Lancamento Contabil                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil 
					aAdd( aFlagCTB, {"EU_LA", "S", "SEU", SEU->( Recno() ), 0, 0, 0} )
				Endif
				nTotal += DetProva( nHdlPrv,;
				                    "572" /*cPadrao*/,;
				                    "FINA560" /*cPrograma*/,;
				                    cLote,;
				                    /*nLinha*/,;
				                    /*lExecuta*/,;
				                    /*cCriterio*/,;
				                    /*lRateio*/,;
				                    /*cChaveBusca*/,;
				                    /*aCT5*/,;
				                    /*lPosiciona*/,;
				                    @aFlagCTB,;
				                    /*aTabRecOri*/,;
				                    /*aDadosProva*/ )
			AAdd(aSEUCont,SEU->(RECNO()))
		Endif
		RodaProva(nHdlPrv,nTotal)
	EndIf	
	Fa560FcAdi(nRecnoSEU,nSldSobra,nSaveSx8,cNumRel2,,,,,,lRepSald)
	// CONTABILIZAÇÃO DO REGISTRO GERADO DA TRANSFERENCIA DO SALDO REMANESCENTE
	If lPadrao579 .And. lGeraLanc	
		If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil 
			aAdd( aFlagCTB, {"EU_LA", "S", "SEU", SEU->( Recno() ), 0, 0, 0} )
		Endif
		If nHdlPrv <= 0
			nHdlPrv +=HeadProva(cLote,"FINA560",Subs(cUsuario,7,6),@cArquivo)
		Endif
		If  nHdlPrv > 0 .And. Empty(SEU->EU_LA)
			nTotal	:=	DetProva(nHdlPrv,"579","FINA560",cLote,,,,,,,,@aFlagCTB)
			AAdd(aSEUCont,SEU->(RECNO()))
		Endif
		RodaProva(nHdlPrv,nTotal)
	Endif	
  Endif		
Elseif (nSldSobra <= 0)
	Begin Transaction
	// Baixa o adiantamento
	RecLock("SEU",.F.)
	Replace	EU_BAIXA With dDataBase
	MsUnlock()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravacao dos lancamentos do SIGAPCO                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PcoDetLan("000359","02","FINA560")
	
	// Baixa as despesas
	nOrder   := IndexOrd()
	cNroAdia := EU_NUM
	dbSetOrder(3)
	IF dbSeek(xFilial()+cNroAdia)
		While ! Eof() .And. SEU->EU_FILIAL == xFilial() ;
			.And. SEU->EU_NROADIA == cNroAdia
			RecLock("SEU",.F.)
			Replace	EU_BAIXA With dDataBase
			MsUnlock()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravacao dos lancamentos do SIGAPCO                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PcoDetLan("000359","02","FINA560")
			dbSkip()
		Enddo
	Endif
	
	dbSetOrder(nOrder)
	dbGoto(nRecnoSEU)
	End Transaction
EndIf

If nHdlPrv > 0
	Begin Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetiva Lan‡amento Contabil                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                               
			If cA100Incl( cArquivo,;
				           nHdlPrv,;
				           3 /*nOpcx*/,;
				           cLote,;
				           lDigita,;
				           lAglutina /*lAglut*/,;
				           /*cOnLine*/,;
				           /*dData*/,;
				           /*dReproc*/,;
				           @aFlagCTB,;
				           /*aDadosProva*/,;
				           aDiario )
				For nX := 1	To Len(aSEUCont)
					SEU->(DbGoTo(aSEUCont[nX]))
					If !lUsaFlag
						Reclock("SEU",.F.)
						Replace EU_LA	With "S"
						MsUnLock()
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Gravacao dos lancamentos do SIGAPCO                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PcoDetLan("000359","02","FINA560")
				Next
			Endif	
			aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
	End Transaction
EndIf

RestArea(aArea)  // restaura ambiente anterior

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA560FcAdi³Autor  ³ Leonardo Ruben        ³ Data ³ 15.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Fecha adiantamento - repassa saldo remanescente            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fA560FcAdi(ExpN1,ExpN2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = N£mero do Registro    							  ³±±
±±³			 ³ ExpN2 = Sobra do Saldo do Adiantamento       			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Fina560                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa560FcAdi(nRecnoSEU,nSldSobra,nSaveSx8,cNumRel2,lEstorno,cForn,cLoja,cFat,cSer,lRepSald)

Local nSldAtu  := 0, nI, cNroAdia
Local aDadAdia := {}
Local lExclMov:=.F.     
Local aArea  
Local lF560FCADI := ExistBlock("F560FCADI")
Local nRecnoDev  := SEU->(Recno())     
Local cNumCxa  := ""
Local nValor   := 0
Local cTipo	:= ""

DEFAULT lEstorno	:= .F.
DEFAULT nSaveSx8	:= GetSx8Len()
DEFAULT lRepSald := .F.
/*
Chile
Quando a prestacao de contas foi gerada por uma fatura de entrada, seus dados serao gravados para identifica-la no movimento de devolucao para a caixinha.
A identificacao e utilizada no momento da exclusao da fatura, para tambem excluir o movimento de devolucao. 
*/
DEFAULT cForn		:= ""
DEFAULT cLoja		:= ""
DEFAULT cFat		:= ""
DEFAULT cSer		:= ""


Private fa560Moed:= If(SEU->(FieldPos("EU_MOEDA")) > 0, SEU->EU_MOEDA, "")
Private fa560Apro:= If(SEU->(FieldPos("EU_CODAPRO")) > 0, SEU->EU_CODAPRO, "")
               
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indicar se eh um movimento de despesa de adiantamento nao baixada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//lAdtNaoBx := ( SEU->EU_TIPO == "00" .And. Empty( SEU->EU_BAIXA ) .And. !Empty( SEU->EU_NROADIA ) )

nRecnoSEU := If( nRecnoSEU == NIL, SEU->(Recno()), nRecnoSEU )
dbSelectArea("SEU")
dbGoto(nRecnoSEU)       // posiciona no registro tipo adiantamento

bNumRel	:=	If( Type("bNumRel")	==	"U",'GetSXENum("SEU","EU_NUM")',bNumRel)
cNumRel2 := If (cNumRel2 == NIL,&bNumRel,cNumRel2)
fa560Nro	:=	If( Type("fa560Nro")	==	"U",SEU->EU_NUM,fa560Nro)

nSldSobra   := If( nSldSobra=NIL,SEU->EU_SLDADIA,nSldSobra)
lExclMov := GetNewPar("MV_PCTCAIX","2")=="1" .And. !Empty(EU_NROADIA)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia lancamento no PCO                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PcoIniLan("000359")

Begin Transaction

If SEU->(DbSeek(xFilial("SEU")+SEU->EU_NROADIA))
	RecLock("SEU",.F.)
	SEU->EU_SLDADIA	+= nSldSobra
	SEU->(MsUnlock())
Endif
SEU->(dbGoto(nRecnoSEU))

If lExclMov
	dbSelectArea("SET")
	dbSetOrder(1)
	dbSeek( xFilial()+SEU->EU_CAIXA)

	dbSelectArea("SEU")
	dbGoto(nRecnoSEU)       // posiciona no registro tipo adiantamento
	cNroAdia := EU_NUM
	cNumCxa  := EU_CAIXA
	nValor   := EU_VALOR
	dbSetOrder(1)
	If dbSeek(xFilial()+cNroAdia) 
		cNroAdia:=EU_NROADIA
		RecLock("SEU",.F.)
		dbDelete()
		MsUnLock()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravacao dos lancamentos do SIGAPCO                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PcoDetLan("000359","02","FINA560", .T.)
	EndIf                         
	If dbSeek(xFilial()+cNroAdia) 
		RecLock("SEU",.F.)
		EU_SLDADIA:=EU_SLDADIA - nSldSobra
		MsUnLock()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravacao dos lancamentos do SIGAPCO                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PcoDetLan("000359","02","FINA560")
	Endif 
	
	If FindFunction( "FXMultSld()" ) .AND. FXMultSld()
		AtuSalCxa( cNumCxa , dDataBase , nSldSobra )
	EndIf 
	
	aArea := GetArea()
	
	// repoe o saldo do caixinha
		
	RecLock("SET",.F.)
	nSldAtu := ET_SALDO + nSldSobra
	REPLACE ET_SALDO WITH nSldAtu
	MsUnlock()
	
	RestArea(aArea)
	
Else
	RecLock("SEU",.F.)
	Replace EU_SLDADIA 	With 0
	Replace	EU_BAIXA 	With dDataBase
	MsUnlock()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravacao dos lancamentos do SIGAPCO                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PcoDetLan("000359","02","FINA560")
	//Guardo os dados do adiantamento para gravar o retorno do adiantamento
	For nI	:=	1	To FCount()
		AAdd(aDadAdia,FieldGet(nI))
	Next
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no caixinha      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SET")
	dbSetOrder(1)
	dbSeek( xFilial()+SEU->EU_CAIXA)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Baixa/Rende gastos do adiantamento  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SEU")
	dbGoto(nRecnoSEU)       // posiciona no registro tipo adiantamento
	cNroAdia := EU_NUM
	dbSetOrder(3)
	If dbSeek(xFilial()+cNroAdia)
		While ! Eof() .And. SEU->EU_FILIAL == xFilial() ;
			.And. SEU->EU_NROADIA == cNroAdia
			RecLock("SEU",.F.)
			Replace	EU_BAIXA With dDataBase
			MsUnlock()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravacao dos lancamentos do SIGAPCO                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PcoDetLan("000359","02","FINA560")
			dbSkip()
		Enddo
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera reg.fechamento de adiantamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock("SEU",.T.)
	For nI	:=	1	To FCount()
		FieldPut(nI,aDadAdia[nI])
	Next
	Replace EU_VALOR 	With	nSldSobra
	Replace EU_TIPO   	With	"02"
	Replace EU_NUM		With	cNumRel2
	Replace EU_NROADIA 	With 	fa560Nro    // informa a que adiantamento se refere
	Replace EU_BAIXA	With	dDataBase
	Replace EU_EMISSAO	With	dDataBase
	Replace EU_DTDIGIT 	With	dDataBase
	Replace EU_LA	    With	"  "
	/*
	Chile
	Identifica a fatura de entrada se o movimento foi gerada por uma.*/
	If !Empty(cForn) .And. !Empty(cLoja) .And. !Empty(cFat)
		Replace EU_FORNECE	With cForn
		Replace EU_LOJA		With cLoja
		Replace EU_NRCOMP	With cFat
		Replace EU_SERCOMP	With cSer
	Endif

	If SEU->(FieldPos("EU_MOEDA")) > 0
		Replace EU_MOEDA	With	fa560Moed 
	EndIf

	If SEU->(FieldPos("EU_STATUS")) > 0
		Replace EU_STATUS	With 	"03"
		Replace EU_CODAPRO	With fa560Apro				
	EndIf	
	If lEstorno
		Replace EU_HISTOR	With   OemtoAnsi(STR0039)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ a devolucao deve ser registrada na seq atual do caixinha  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Replace EU_SEQCXA   With    SET->ET_SEQCXA
	MsUnLock()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravacao dos lancamentos do SIGAPCO                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PcoDetLan("000359","02","FINA560")
	//**********************************
	// Atulizacao do saldo do caixinha *
	//**********************************	
	If FindFunction( "FXMultSld()" ) .AND. FXMultSld()
		AtuSalCxa( SEU->EU_CAIXA , dDataBase , SEU->EU_VALOR )
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza saldo do caixinha se nao for uma despesa de      ³
	//³ adiantamento em aberto                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aArea:=GetArea()
	nRecnoDev:=SEU->(Recno())
	If !lEstorno .OR. (lEstorno .AND. !(SEU->EU_TIPO == "00" .And. Empty( SEU->EU_BAIXA ) .And. !Empty( SEU->EU_NROADIA ) ) ) 
	  
		dbSelectArea("SEU")
		SEU->(dbSetOrder(1))
		If dbSeek(xFilial()+SEU->EU_NROADIA)
			cTipo:=SEU->EU_TIPO
			If dbSeek(xFilial()+SEU->EU_NROADIA)
	  			cTipo:= SEU->EU_TIPO
	  		EndIf
		EndIf	
		RestArea(aArea)
		SEU->(DbGoTo(nRecnoDev))
		If lRepSald .OR. cTipo <> "01"
			RecLock("SET",.F.)
			nSldAtu :=  ET_SALDO + SEU->EU_VALOR //Fa570AtuSld( SET->ET_CODIGO) - Reprocessava todos os saldos do caixinha para retornar o valor da devolução - desnecessário, o valor a devolver está posicionado (SEU->EU_VALOR), ou pode ser usado também a nSldSobra.
			REPLACE ET_SALDO WITH nSldAtu
			MsUnlock()
		Else
			RecLock("SET",.F.)
			nSldAtu :=  ET_SALDO 
			REPLACE ET_SALDO WITH nSldAtu
			MsUnlock()
	  	Endif	
	EndIf	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravacao dos lancamentos do SIGAPCO                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PcoDetLan("000359","01","FINA560")
	While (GetSx8Len() > nSaveSx8 )
		ConfirmSX8()
	Enddo
EndIf

If lF560FCADI
	ExecBlock("F560FCADI",.F.,.F.,{cNroAdia,nSldSobra,lEstorno})
Endif

End Transaction
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a gravacao dos lancamentos do SIGAPCO            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PcoFinLan("000359")

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA560Legend³ Autor ³ Leonardo Ruben       ³ Data ³ 30.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA560                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FA560Legend(nReg)
Local uRetorno := .T.
Local aLegenda := {	{"ENABLE"	, 	STR0026	},;	//"Despesa nao baixada"
					{"BR_AZUL"	, 	STR0027	},;	//"Despesa de adiantamento nao baixada"
					{"BR_AMARELO",	STR0028	},;	//"Adiantamento com saldo (em aberto)"
					{"DISABLE"	, 	STR0029} }	//"Despesa baixada ou outros movimentos"

If ExistBlock("FA550VERIF",.T.) .And. Fa550Verif()
	Aadd(aLegenda,{"BR_CINZA",STR0034})		//"Reposicao: aguardando autorizacao"
	Aadd(aLegenda,{"BR_PINK",STR0035})		//"Reposicao: aguardando debito do titulo"
	Aadd(aLegenda,{"BR_PRETO",STR0036})		//"Reposicao cancelada"
Endif

If  GetNewPar("MV_PCTCXMA","2")=="1"  // Permite prestacao de contas a maior no adiantamento 
	Aadd(aLegenda,{"BR_MARRON",STR0046})  	//Complemento de Adiantamento
EndIf

If nReg = NIL	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}
	Aadd(uRetorno, {'EU_TIPO="00" .AND. Empty(EU_BAIXA) .AND. Empty(EU_NROADIA)', aLegenda[1][1]}) //"Despesa nao baixada"
	Aadd(uRetorno, {'EU_TIPO="00" .AND. Empty(EU_BAIXA) '								 , aLegenda[2][1]} )//"Despesa de adiantamento nao baixada"
	Aadd(uRetorno, {'EU_TIPO="01" .AND. EU_SLDADIA>0'								    , aLegenda[3][1]}) //"Adiantamento com saldo (em aberto)"
	Aadd(uRetorno, {'!Empty(EU_BAIXA)'														 , aLegenda[4][1]}) //"Despesa baixada ou outros movimentos"

	If (ExistBlock("FA550VERIF",.T.) .And. Fa550Verif()) .And. (GetNewPar("MV_PCTCXMA","2")=="1")
		Aadd(uRetorno,{'EU_TIPO="91"'	, aLegenda[5][1]})	 	// Reposicao: aguardando liberacao
		Aadd(uRetorno,{'EU_TIPO="92"'	, aLegenda[6][1]})		// Reposicao: aguardando compensacao do cheque
		Aadd(uRetorno,{'EU_TIPO="90"'	, aLegenda[7][1]})		// Reposicao cancelada
		Aadd(uRetorno,{'EU_TIPO="03"' , aLegenda[8][1]})		// Complemento de adiantamento
	
	
	ElseIf (ExistBlock("FA550VERIF",.T.) .And. Fa550Verif())
	   Aadd(uRetorno,{'EU_TIPO="91"'	, aLegenda[5][1]})	 	// Reposicao: aguardando liberacao
		Aadd(uRetorno,{'EU_TIPO="92"'	, aLegenda[6][1]})		// Reposicao: aguardando compensacao do cheque
		Aadd(uRetorno,{'EU_TIPO="90"'	, aLegenda[7][1]})		// Reposicao cancelada
	  
	
	ElseIf (GetNewPar("MV_PCTCXMA","2")=="1")
		Aadd(uRetorno,{'EU_TIPO="03"' , aLegenda[5][1]}) 	  //"Complemento de adiantamento"
	
   Endif		
	
Else
	BrwLegenda(cCadastro,STR0025,aLegenda) //"Legenda"
Endif


Return uRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fa560Vld()³Autor  ³Patricia A. Salomao    ³ Data ³ 21.06.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao dos Campos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Fa560Vld()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                         									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Fina560                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa560Vld()
Local lRet    := .T.
Local cCampo  := ReadVar()
Local cChave  := ""      
Local cSerDesp:= ( SuperGetMV('MV_SERDESP',,'' ) )
Local nPosFolder := 0    
Local nPosFilOri := 0
Local nPosViagem := 0
Local nPosCodVei := 0
Local nPosCodDes := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacoes se o a versao usada é igual ou superior ³
//³que versão 10 Release 11.5 						   ³	     
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lR5        := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao    := Val(GetVersao(.F.))     // Indica a versao do Protheus
Local lExeIntTms := ((nVersao == 11 .And. lR5) .Or. nVersao > 11) //-- Verificação de Release .5 do Protheus 11

Local lMntTms    := ( SuperGetMV( "MV_NGMNTMS",,'N') == 'S' )//-- Ativa integracao TMS X MNT.

If ADIANTAMENTO
	nPosFilOri := Ascan(aHeader, {|x| AllTrim(x[2]) == "EU_FILORI"})
	nPosViagem := Ascan(aHeader, {|x| AllTrim(x[2]) == "EU_VIAGEM"})
	nPosCodVei := Ascan(aHeader, {|x| AllTrim(x[2]) == "EU_CODVEI"})
	nPosCodDes := Ascan(aHeader, {|x| AllTrim(x[2]) == "EU_CODDES"})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacoes para o Modulo de Transporte (TMS)       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If IntTMS() .And. nModulo == 43
	If cCampo == 'M->EU_FILORI' .Or. cCampo == 'M->EU_VIAGEM'
		If ADIANTAMENTO

			If !Empty(GdFieldGet('EU_CODVEI', n))
				Help('',1,'FA560NOVIA') // A Viagem Nao podera ser informada pois o campo Veiculo ja foi preenchido ...
				lRet := .F.
			EndIf

			If (!lRet .And. cCampo == 'M->EU_FILORI') .Or. (cCampo == 'M->EU_FILORI' .And. Vazio())
				GDFieldPut('EU_VIAGEM',Space(Len(SEU->EU_VIAGEM)),n)
			ElseIf !lRet .Or. Vazio()
				Empty(GdFieldGet('EU_FILORI', n))
			EndIf

			If lRet .And. cCampo == 'M->EU_FILORI'
				cChave := M->EU_FILORI+AllTrim(GdFieldGet('EU_VIAGEM', n))
			ElseIf lRet
				cChave := GdFieldGet('EU_FILORI', n)+M->EU_VIAGEM
			EndIf

     		If lRet .And. !Empty(aFolTmsBkp)
				GDFieldPut('EU_CODDES',Space(Len(SEU->EU_CODDES)),n)
				GDFieldPut('EU_HISTOR',Space(Len(SEU->EU_HISTOR)),n)
			EndIf

		Else

			If !Empty(M->EU_CODVEI)
				Help('',1,'FA560NOVIA') // A Viagem Nao podera ser informada pois o campo Veiculo ja foi preenchido ...
				lRet := .F.
				M->EU_VIAGEM := Space(Len(SEU->EU_VIAGEM))
				M->EU_FILORI := Space(Len(SEU->EU_FILORI))
			EndIf
			If lRet .And. cCampo == 'M->EU_FILORI'
				If Vazio()
					M->EU_VIAGEM := Space(Len(SEU->EU_VIAGEM))
				EndIf
			EndIf
			If lRet .And. cCampo == 'M->EU_VIAGEM'
				If Empty(M->EU_FILORI)
					lRet := .F.
				EndIf
			EndIf
			If lRet
				cChave := M->EU_FILORI+M->EU_VIAGEM
				If !Empty(M->EU_CODDES) .And.  !Empty(M->EU_FILORI) .And. !Empty(M->EU_VIAGEM)
					SDG->(dbSetOrder(5))
					SDG->(MsSeek(cSeek:=xFilial("SDG")+M->EU_FILORI+M->EU_VIAGEM))
					//Nao permite duplicar uma mesma despesa para a mesma viagem
					Do While !SDG->(Eof()) .And. SDG->(DG_FILIAL+DG_FILORI+DG_VIAGEM) == cSeek
						If SDG->DG_ORIGEM == "SEU" .And. SDG->DG_CODDES == M->EU_CODDES
							Help("",1,"JAGRAVADO") //Ja existe registro com esta informacao.
							lRet := .F.
							Exit
						EndIf
						SDG->(dbSkip())
					EndDo
				EndIf
			EndIf
		EndIf
		If ADIANTAMENTO
			If lRet .And. !Empty(AllTrim(GdFieldGet('EU_FILORI', n))) .And. !Empty(AllTrim(GdFieldGet('EU_VIAGEM', n))) ;
																		.And. !ExistCpo("DTQ", cChave, 2)
				lRet := .F.
			EndIf
			If lRet .And. Posicione("DTQ",2,xFilial("DTQ") + cChave,"DTQ_TIPVIA") == StrZero(3,Len(DTQ->DTQ_TIPVIA))
				Help("",1,"FA560TIPVI")
				lRet := .F.
			EndIf
			If lRet
				GDFieldPut( 'EU_VALOR', FA560Pdg(	If(cCampo == 'M->EU_FILORI', M->EU_FILORI, GDFieldGet('EU_FILORI', n)),; 
													If(cCampo == 'M->EU_VIAGEM', M->EU_VIAGEM, GDFieldGet('EU_VIAGEM', n)),;
													GDFieldGet('EU_CODDES',n), GDFieldGet('EU_VALOR',n) ), n)
			EndIf
		Else
			If lRet .And. (!Empty(M->EU_FILORI) .Or. !Empty(M->EU_VIAGEM)) .And. !ExistCpo("DTQ", cChave, 2)
				lRet := .F.
			EndIf
			If lRet .And. Posicione("DTQ",2,xFilial("DTQ") + cChave,"DTQ_TIPVIA") == StrZero(3,Len(DTQ->DTQ_TIPVIA))
				Help("",1,"FA560TIPVI")
				lRet := .F.
			EndIf
     		If lRet .And. !Empty(aFolTmsBkp)
				If	lRet .And. (M->EU_FILORI <> aFolTmsBkp[1,1] .Or. M->EU_VIAGEM <> aFolTmsBkp[1,2])
					M->EU_CODDES := Space(Len(SEU->EU_CODDES))
					M->EU_HISTOR := Space(Len(SEU->EU_HISTOR))
					aFolTms      := {}
					aFolTmsBkp   := {}
				EndIf
			EndIf
		EndIf
		
	ElseIf cCampo == 'M->EU_CODMOT'
		DA4->(dbSetOrder(1))
		DA4->(MsSeek(xFilial('DA4')+ M->EU_CODMOT ))
		M->EU_BENEF := DA4->DA4_NOME
	ElseIf cCampo == 'M->EU_CODDES'
		If !Vazio()
			If (lRet := ExistCpo("DT7"))
				DT7->(dbSetOrder(1))
				DT7->(MsSeek(xFilial('DT7')+ M->EU_CODDES ))
				If ADIANTAMENTO
					M->EU_FILORI := AllTrim(GdFieldGet('EU_FILORI', n))
					M->EU_VIAGEM := AllTrim(GdFieldGet('EU_VIAGEM', n))
					M->EU_CODVEI := AllTrim(GdFieldGet('EU_CODVEI', n))
					If !Empty(M->EU_CODDES) .And. !Empty(M->EU_FILORI) .And. !Empty(M->EU_VIAGEM)
						SDG->(dbSetOrder(5))
						SDG->(MsSeek(cSeek:=xFilial("SDG")+M->EU_FILORI+M->EU_VIAGEM))
						//Nao permite duplicar uma mesma despesa para a mesma viagem/veiculo
						Do While !SDG->(Eof()) .And. SDG->(DG_FILIAL+DG_FILORI+DG_VIAGEM) == cSeek
							If SDG->DG_ORIGEM == "SEU" .And. SDG->DG_CODDES == M->EU_CODDES
								Help("",1,"JAGRAVADO") //Ja existe registro com esta informacao.
									lRet := .F.
								Exit
							EndIf
							SDG->(dbSkip())
						EndDo
					EndIf
					If lRet
						nPosFolder := Ascan( aCols, {|x|	AllTrim(x[nPosFilOri])+AllTrim(x[nPosViagem])+AllTrim(x[nPosCodVei])+AllTrim(x[nPosCodDes])==;
															M->EU_FILORI+M->EU_VIAGEM+M->EU_CODVEI+AllTrim(M->EU_CODDES)} )

						If n > nPosFolder .And. nPosFolder <> 0
							If !GdDeleted(nPosFolder)   //Não Esta deletado
								If lMntTms .And. DT7->(FieldPos("DT7_CODFAM")) > 0 .And. !Empty(DT7->DT7_CODFAM)
									Aviso(STR0054, Iif(!Empty(M->EU_CODVEI),STR0051,STR0052);  //"Atenção",'Veículo e Despesa já informados,"###"Viagem e Despesa já informadas,"
									 + STR0053 + AllTrim(Str(nPosFolder)),{"Ok"}) //" na Linha: "
									lRet := ( .F. )
								EndIf
							EndIf
						EndIf
						If lRet
							GDFieldPut('EU_HISTOR',Posicione("DT7",1,xFilial("DT7")+M->EU_CODDES,"DT7_DESCRI"),n)
							//-- Verificação de Release .5 do Protheus 11
							If lExeIntTms //So executar integracao no Release .5 ou da versao ou 11 ou versao superior
								If lMntTms
									lRet := TmsIntMnt("2", cSerDesp, AllTrim(M->EU_FILORI), AllTrim(M->EU_VIAGEM), AllTrim(M->EU_CODVEI), AllTrim(M->EU_CODDES), @aFolTms, aFolTmsBkp, aCols, ADIANTAMENTO)
								EndIf
							EndIf
						EndIf
					EndIf
				ElseIf lRet
					If !Empty(M->EU_CODDES) .And. !Empty(M->EU_FILORI) .And. !Empty(M->EU_VIAGEM)
						SDG->(dbSetOrder(5))
						SDG->(MsSeek(cSeek:=xFilial("SDG")+M->EU_FILORI+M->EU_VIAGEM))
						//Nao permite duplicar uma mesma despesa para a mesma viagem/veiculo
						Do While !SDG->(Eof()) .And. SDG->(DG_FILIAL+DG_FILORI+DG_VIAGEM) == cSeek
							If SDG->DG_ORIGEM == "SEU" .And. SDG->DG_CODDES == M->EU_CODDES
								Help("",1,"JAGRAVADO") //Ja existe registro com esta informacao.
								lRet := .F.
								Exit
							EndIf
							SDG->(dbSkip())
						EndDo
					EndIf
					If lRet .And. M->EU_TIPO == '01' //-- Despesa
						If !Empty(M->EU_CODDES)
							M->EU_VALOR := FA560Pdg( M->EU_FILORI, M->EU_VIAGEM, M->EU_CODDES,M->EU_VALOR ) //Calcula valor do pedagio
						EndIf
					EndIf
					M->EU_HISTOR := Posicione("DT7",1,xFilial("DT7")+M->EU_CODDES,"DT7_DESCRI")
					If lRet .And. lExeIntTms //So executar integracao no Release .5 ou da versao ou 11 ou versao superior
						If lMntTms
							TmsIntMnt("2", cSerDesp, AllTrim(M->EU_FILORI), AllTrim(M->EU_VIAGEM), AllTrim(M->EU_CODVEI), AllTrim(M->EU_CODDES), @aFolTms, aFolTmsBkp) //Integraçao TMS x MNT
						EndIf
					EndIf
				EndIf
			EndIf
		ElseIf ADIANTAMENTO //Limpar o histórico do caso o campo despesa seja apagada.
			GDFieldPut('EU_HISTOR',Space(Len(SEU->EU_HISTOR)),n)
		Else //Limpar o histórico do caso o campo despesa seja apagado.
			M->EU_HISTOR := Space(Len(SEU->EU_HISTOR))
		EndIf
	ElseIf cCampo == 'M->EU_CODVEI'
		If ADIANTAMENTO
			If !Empty(GdFieldGet('EU_FILORI', n))  .Or. !Empty(GdFieldGet('EU_VIAGEM', n))
				Help('',1,'FA560NOVEI') // O Veiculo Nao podera ser informado pois o campo Viagem ja foi preenchido ...
				lRet := .F.
			EndIf
			If lRet .And. !Empty(aFolTmsBkp)
				GDFieldPut('EU_CODDES',Space(Len(SEU->EU_CODDES)),n)
				GDFieldPut('EU_HISTOR',Space(Len(SEU->EU_HISTOR)),n)
			EndIf
		Else
			If !Empty(M->EU_FILORI) .Or. !Empty(M->EU_VIAGEM)
				Help('',1,'FA560NOVEI') // O Veiculo Nao podera ser informado pois o campo Viagem ja foi preenchido ...
				lRet := .F.
			EndIf
			If lRet .And. !Empty (aFolTmsBkp)
				If M->EU_CODVEI <> aFolTmsBkp[1,3]
					M->EU_CODDES:= Space(Len(SEU->EU_CODDES))
					M->EU_HISTOR:= Space(Len(SEU->EU_HISTOR))
					aFolTms		:= {}
					aFolTmsBkp	:= {}
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
Return ( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA560REP  ºAutor  ³Marcello            ºFecha ³ 01/07/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA560                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa560Rep()
Local lRet:=.T.
Local aSEU:=SEU->(GetArea())
If SEU->EU_TIPO$"91/92" //movimento aguardando autorizacao para reposicao e/ou compensacao de cheque
	Fa550Rep20(SEU->EU_CAIXA,.T.,.T.,,.F.,SEU->(Recno()))
Else
	Aviso(STR0037,STR0038,{'Ok'})   //'Operacion no disponible'###'Esta operacion solo esta disponible para los movimientos de reposicion pendientes de aprobacion'
	lRet	:=	.F.
Endif
SEU->(RestArea(aSEU))
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA560VlRenºAutor  ³Bruno Sobieski      ºFecha ³ 01/07/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o numero da rendicao                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA560                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa560Rend()
Local lRet:=.T.
Local aSEU:=SEU->(GetArea())
Local cCaixa	:=	IIF(Type("M->EU_CAIXA")=="C",M->EU_CAIXA,IIf(Type("cCxCaixa")=="C",cCxCaixa,SEU->EU_CAIXA))
Local cNroRend	:=	&(ReadVar())
If !Empty(cNroRend)
	DbSelectArea('SEU')
	DbSetOrder(8)
	MSSeek(xFilial()+cCaixa+cNroRend)
	While lRet .And.!Eof() .And. SEU->(EU_FILIAL+EU_CAIXA+EU_NRREND)==xFilial()+cCaixa+cNroRend
		If SEU->EU_TIPO$"00/01/02" .And. !Empty(SEU->EU_BAIXA)
			Help(" ",1,"FA560REND")
			lRet	:=	.F.
		Endif
		DbSkip()
	Enddo
Endif
SEU->(RestArea(aSEU))
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F560VerPE ºAutor  ³Paulo Augusto       ºFecha ³ 09/12/2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a existencia do ponto de entrada                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA560                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function  F560VerPE()
Local lRet:= .T.
If ExistBlock("F560VMOV")
	lRet:= 	ExecBlock("F560VMOV",.F.,.F.)
Endif

If lRet .and. SET->ET_SITUAC == "1"
	MsgStop(STR0044,STR0045)
	lRet:=.F. 
Endif	
Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AjustaSX3     ³ Autor ³ Gilson da Silva      ³ Data ³14.06.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Ajusta o X3_RESERV DO CAMPO EU_CODDES                          ³±±
±±³          ³Ajusta o X3 dos campos EU_CONTAD, EU_CONTAC, EU_CCD, EU_CCC,   ³±±
±±³          ³EU_ITEMC, EU_ITEMD e EU_CLVLDB                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AjustaSX3()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function AjustaSX3()

Local aArea   := GetArea()
Local cReserv := ""

DbSelectArea("SX3")
dbSetOrder(2)
If MsSeek("EU_VIAGEM")  .And. ('EXISTCPO('$Upper(SX3->X3_RESERV))
	cReserv := SX3->X3_RESERV
EndIf

DbSelectArea("SX3")
dbSetOrder(2)
If MsSeek("EU_CODDES")
	RecLock('SX3', .F.)
	Replace X3_RESERV With cReserv
	MsUnlock()
EndIf

If DbSeek("EU_CCC")
	RecLock("SX3")
	Replace X3_VALID  With "Vazio() .Or. CTB105CC()"
	Replace X3_F3  	  With "CTT"
	MsUnlock()
EndIf

If DbSeek("EU_CCD")
	RecLock("SX3")
	Replace X3_VALID  With "Vazio() .Or. CTB105CC()"
	Replace X3_F3  	  With "CTT"
	MsUnlock()
EndIf

If DbSeek("EU_CONTAD")
	RecLock("SX3")
	Replace X3_VALID  With "Vazio() .Or. CTB105CTA()"
	Replace X3_F3  	  With "SI1"
	MsUnlock()
EndIf

If DbSeek("EU_CONTAC")
	RecLock("SX3")
	Replace X3_VALID  With "Vazio() .Or. CTB105CTA()"
	Replace X3_F3  	  With "SI1"
	MsUnlock()
EndIf   

If DbSeek("EU_ITEMC")
	RecLock("SX3")
	Replace X3_VALID  With "Vazio() .Or. CTB105ITEM()"
	Replace X3_F3  	  With "CTD"
	MsUnlock()
EndIf

If DbSeek("EU_ITEMD")
	RecLock("SX3")
	Replace X3_VALID  With "Vazio() .Or. CTB105ITEM()"
	Replace X3_F3  	  With "CTD"
	MsUnlock()
EndIf

If DbSeek("EU_CLVLDB")
	RecLock("SX3")
	Replace X3_VALID  With "Vazio() .Or. CTB105CLVL()"
	Replace X3_F3  	  With "CTH"
	MsUnlock()
EndIf
         
If cPaisLoc == "PER"
	If DbSeek("EU_CGC    ") .and. Alltrim(SX3->X3_PICTURE) <> "@R 99999999999999"
		RecLock("SX3")
		Replace X3_PICTURE  With "@R 99999999999999"
		Replace X3_TITSPA  With "RUC"    
		Replace X3_DESCSPA  With "RUC del proveedor"        
		MsUnlock()
	EndIf	
EndIf
RestArea(aArea)
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FINA560_V  ³ Autor ³ Telso Carneiro       ³ Data ³ 02/10/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao utilizada para verificar a ultima versao do fonte   ³±±
±±³			 ³ FINA560.PRW aplicado no rpo do cliente, assim verificando  ³±±
±±³			 ³ a necessidade de uma atualizacao neste fonte.			     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA144Sub 	                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FINA560_V()
Local nRet := 20061002 // 02 de outubro de 2006
Return nRet 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³27/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef() 
Local aPresConta := {}
Local aRotina    := {}
                     
If cPaisLoc $ "ARG|PER|BOL"

	aPresConta := { { STR0056, "FA560CpFis",0 ,3 },;  		//"Comprovantes Fiscais"
		            { STR0057, "FA560Adian",0 ,4}}       	//"Outros Comprovantes"

	aRotina := { {STR0006, "AxPesqui"	  ,0,1,,.F.},;  	//"Pesquisar"
				 {STR0007, "AxVisual"   ,0,2},;  			//"Visualizar"
				 {STR0008, "FA560Inclui",0,3},;  			//"Incluir"
				 {STR0009, "FA560Deleta",0,5},;  			//"Excluir"
				 {STR0010, aPresConta   ,0,4},;  			//"Prestacao de Contas"
				 {STR0025, "FA560Legend",0,2, ,.F.} }  	//"Legenda"

ElseIf cPaisLoc == "CHI"

	aRotina := { {STR0006, "AxPesqui"	  ,0,1,,.F.},;  	//"Pesquisar"
				 {STR0007, "AxVisual"   ,0,2},;  			//"Visualizar"
				 {STR0008, "FB560Inclui",0,3},;  			//"Incluir"
				 {STR0009, "FA560Deleta",0,5},;  			//"Excluir"
				 {STR0010, "FA560Adian" ,0 ,4},;  			//"Prestacao de Contas"
				 {STR0025, "FA560Legend",0,2, ,.F.} }  	//"Legenda"

Else

	aRotina := { {STR0006, "AxPesqui"	  ,0,1,,.F.},;  	//"Pesquisar"
				 {STR0007, "AxVisual"   ,0,2},;  			//"Visualizar"
				 {STR0008, "FA560Inclui",0,3},;  			//"Incluir"
				 {STR0009, "FA560Deleta",0,5},;  			//"Excluir"
				 {STR0010, "FA560Adian" ,0 ,4},;  			//"Prestacao de Contas"
				 {STR0025, "FA560Legend",0,2, ,.F.} }  	//"Legenda"

EndIf	
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ P.E. utilizado para adicionar itens no Menu da mBrowse       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("FA560BRW")
	aRotina := ExecBlock("FA560BRW",.F.,.F.,{aRotina})
EndIf
	
Return(aRotina)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FinA560T   ³ Autor ³ Marcelo Celi Marques ³ Data ³ 04.04.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada semi-automatica utilizado pelo gestor financeiro   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA560                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FinA560T(aParam)
	cRotinaExec := "FINA560"
	ReCreateBrow("SEU",FinWindow)      		
	FinA560(aParam[1])
	FinVisual("SEU",FinWindow,SEU->(Recno()),.T.)
	ReCreateBrow("SEU",FinWindow)      	
	dbSelectArea("SEU")
	
	INCLUI := .F.
	ALTERA := .F.

Return .T.
           

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AjustaSX() ³ Autor ³ Marcos Antunes Berto ³ Data ³ 21.08.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajuste dos Helps de Campo                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA560                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX()


Local aHelpPor := {}
Local aHelpSpa := {}
Local aHelpEng := {}

 
//ÚÄÄÄÄÄÄ¿
//³HELP'S³
//ÀÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Conta Contabil Debito                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Portugues    
Aadd(aHelpPor,"Informar a Conta Contabil de Debito.")

// Espanhol
Aadd(aHelpSpa,"Informar la Cuenta Contable de Debito.")

// Ingles 
Aadd(aHelpEng,"Indicate Debit Ledger Account.")

PutHelp("PEU_CONTAD",aHelpPor,aHelpEng,aHelpSpa,.T.)

aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Conta Contabil Credito                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Portugues    
Aadd(aHelpPor,"Informar a Conta Contabil de Credito.")

// Espanhol
Aadd(aHelpSpa,"Informar la Cuenta Contable de Credito.")

// Ingles 
Aadd(aHelpEng,"Indicate Credit Ledger Account.")

PutHelp("PEU_CONTAC",aHelpPor,aHelpEng,aHelpSpa,.T.)

aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³C. Custo a Debito                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Portugues    
Aadd(aHelpPor,"Informar o Centro de Custo a Debito.")

// Espanhol
Aadd(aHelpSpa,"Informar el Centro de Costo a Debito.")

// Ingles 
Aadd(aHelpEng,"Indicate Debit Cost Center.")

PutHelp("PEU_CCD",aHelpPor,aHelpEng,aHelpSpa,.T.)

aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³C. Custo a Credito                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Portugues    
Aadd(aHelpPor,"Informar o Centro de Custo a Credito.")

// Espanhol
Aadd(aHelpSpa,"Informe el Centro de Costo a Credito.")

// Ingles 
Aadd(aHelpEng,"Indicate Credit Cost Center.")

PutHelp("PEU_CCC",aHelpPor,aHelpEng,aHelpSpa,.T.)

aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Item Contabil a Credito                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Portugues    
Aadd(aHelpPor,"Informar Item Contabil a Credito.")

// Espanhol
Aadd(aHelpSpa,"Informar Item Contable a Credito.")

// Ingles 
Aadd(aHelpEng,"Indicate Credit Accounting Item.")

PutHelp("PEU_ITEMC",aHelpPor,aHelpEng,aHelpSpa,.T.)

aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Item Contabil a Debito                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Portugues    
Aadd(aHelpPor,"Informar Item Contabil a Debito.")

// Espanhol
Aadd(aHelpSpa,"Informar Item Contable a Debito.")

// Ingles 
Aadd(aHelpEng,"Indicate Debit Accounting Item.")

PutHelp("PEU_ITEMD",aHelpPor,aHelpEng,aHelpSpa,.T.)

aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Classe de valor a Debito                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Portugues    
Aadd(aHelpPor,"Informar a Classe de Valor a")
Aadd(aHelpPor,"Debito.")

// Espanhol
Aadd(aHelpSpa,"Informar la Clase de Valor a")
Aadd(aHelpSpa,"Debito.")

// Ingles 
Aadd(aHelpEng,"Indicate Debit Value Class.")

PutHelp("PEU_CLVLDB",aHelpPor,aHelpEng,aHelpSpa,.T.)

aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA560Pdg ³ Autor ³ Vitor Raspa            ³ Data ³ 09.Jan.07³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para realizar o calculo do pedagio                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FA560Pdg( cExpC1, cExpC2 )                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExpC1 - Filial de Origem                                  ³±±
±±³          ³ cExpC2 - Numero da Viagem                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nValPdg - Valor do Pedagio                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA560                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA560Pdg( cFilOri, cViagem, cCodDes,nValPdg )
Local cDesPdg   := SuperGetMV( 'MV_DESPDG',, '' ) //-- Despesa de Pedagio
Local aVeiculos := {}
Local lQtdEix   := DTR->(FieldPos("DTR_QTDEIX")) > 0
Local lQtdEixV  := DTR->(FieldPos("DTR_QTEIXV")) > 0
Local aAreaDTR  := DTR->(GetArea())
Local aAreaDTQ  := DTQ->(GetArea())
Local cCodOpe   := ''
Local lFailPdg  := .F.
Local cSeekDTR  := ''
Default nValPdg := 0

//-- Calcula o Pedagio
If AllTrim(cCodDes) == cDesPdg .And. !Empty(cFilOri) .And. !Empty(cViagem)
	DTR->(dbSetOrder(1))
	DTR->(dbSeek(cSeekDTR := xFilial('DTR')+cFilOri+cViagem))
	While DTR->(!Eof()) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM) == cSeekDTR
		If Empty(cCodOpe)
			cCodOpe := DTR->DTR_CODOPE
		EndIf			
		AAdd( aVeiculos, { DTR->DTR_CODVEI,;
								 Iif(lQtdEix, DTR->DTR_QTDEIX, Posicione("DA3",1,xFilial("DA3")+DTR->DTR_CODVEI,"DA3_QTDEIX")),;
								 Iif(lQtdEixV,DTR->DTR_QTEIXV, 0) })
		
		If !Empty(DTR->DTR_CODRB1) .And. (!lQtdEix .Or. Empty(DTR->DTR_QTDEIX))
			AAdd( aVeiculos, { DTR->DTR_CODRB1,;
								    Posicione("DA3",1,xFilial("DA3")+DTR->DTR_CODRB1,"DA3_QTDEIX"),;
									 0 })
		EndIf
		
		If !Empty(DTR->DTR_CODRB2) .And. (!lQtdEix .Or. Empty(DTR->DTR_QTDEIX))
			AAdd( aVeiculos, { DTR->DTR_CODRB2,;
									 Posicione("DA3",1,xFilial("DA3")+DTR->DTR_CODRB2,"DA3_QTDEIX"),;
									 0 })
		EndIf
		DTR->(DbSkip())
	EndDo
	nValPdg := TmsCalPdg(aVeiculos, Posicione('DTQ',2,xFilial('DTQ')+cFilOri+cViagem,'DTQ_ROTA'), cCodOpe, @lFailPdg)
EndIf

RestArea(aAreaDTQ)
RestArea(aAreaDTR)

Return(nValPdg)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA560Whe ³ Autor ³Leandro Paulino       ³ Data ³ 21/05/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³X3_WHEN do campo EU_VALOR. Nao permite a ALTERACAO do con-  ³±±
±±³          ³teudo deste campo, caso a integração de ativos estiver habi-³±±
±±³          ³litada e existir família na despesa informada.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FA560Whe()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³FINA560 - Integração com SIGATMS x SIGAMNT                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function FA560Whe(cCampo)

Local lRet     := .T.
Local lMntTms  := (SuperGetMV( "MV_NGMNTMS",,'N') == 'S') //-- Ativa integracao TMS X MNT.
Default cCampo := ReadVar()

If AllTrim(cCampo) == "M->EU_VALOR"
	If lMntTms .And. nModulo == 43
		If ADIANTAMENTO
			lRet := Empty(Posicione('DT7',1,xFilial("DT7")+GdFieldGet("EU_CODDES",n),'DT7_CODFAM'))
		Else
			lRet := Empty(Posicione('DT7',1,xFilial("DT7")+M->EU_CODDES,'DT7_CODFAM'))
		EndIf
	EndIf
EndIf

Return ( lRet )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F560VldAprºAutor  ³ Danilo Dias        º Data ³ 02/05/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o campo de código do aprovador EU_CODAPRO caso o    º±±
±±º          ³ controle de alçadas esteja ativado. (MV_FINCTAL = 2)       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA560                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function F560VldApr()
           
Local aArea := GetArea()
Local lRet  := .T.
Local cCtAl := SuperGetMV("MV_FINCTAL", .T., "1")

If cCtAl == "2"
	If Empty(M->EU_CODAPRO)
		Help( " ", 1, "F560VldApr", , STR0055, 1, 0 )	//"O campo 'Cod. Aprov.' é obrigatório quando controle de alçadas está ativo."
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)

Return lRet          

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA560CpFis³ Autor ³ Jose Lucas            ³ Data ³ 21.07.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Baixa de ingressos tipo Comprovante Fiscal.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FA560CpFis(ExpC1,ExpN1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo	   					 	 		  ³±±
±±³			 ³ ExpN1 = N£mero do registro 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA560                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa560CpFis(cAlias,nReg)
Local lPanelFin := If (FindFunction("IsPanelFin"),IsPanelFin(),.F.)
Local lGravaOK 	:= .T.
Local nOpca		:= 0
Local nUsado 	:= 0
Local oDlg, oGet
Local lContinua := .T.
Local cCampos   := ""
Local cNroAnt   := SEU->EU_NUM
Local oFont
Local nRecnoSEU := SEU->(Recno())
Local cCaption
Local lF560Cpos := ExistBlock("F560CPOS")
Local nSaveSx8  := GetSx8Len()
Local nY := 0
Local lFa550Adia:=	ExistBlock("FA550ADF")   
Local lF560APROV  := ExistBlock ('F560APROV')
Local lAprova   := .F.         

Local nTimeOut  := SuperGetMv("MV_FATOUT",,900)*1000 	// Estabelece 15 minutos para que o usuarios selecione
Local nTimeMsg  := SuperGetMv("MV_MSGTIME",,120)*1000 	// Estabelece 02 minutos para exibir a mensagem para o usuário
Local oTimer

Local lPadrao579 := VerPadrao("579")
Local lPadrao572 := VerPadrao("572")
Local lGeraLanc  := Iif(mv_par03 ==1,.T.,.F.)
Local lDigita    := Iif(mv_par01 ==1,.T.,.F.)
Local lAglutina  := Iif(mv_par02 ==1,.T.,.F.)
Local aSEUCont	  :={}             
Local nHdlPrv    := 0  
Local cArquivo
Local nTotal     := 0
Local aFlagCTB := {}
Local lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/) 

Private 	cLote    	:= ""
PRIVATE 	aHeader 	:= {}
PRIVATE 	aCols   	:= {}
PRIVATE 	aNroCols	:= {}
Private 	bNumRel
Private 	oSaldo  	:= NIL
PRIVATE ADIANTAMENTO:=	.T.

Private aFolTms     := {}
Private aFolTmsBkp  := {}

If SEU->EU_TIPO <> "01" //somente adiantamentos
	Help(" ",1,"FA560TIPO")
	dbSelectArea(cAlias)
	Return /*Function Fa560Adian*/
ElseIf SEU->EU_SLDADIA <= 0 //somente adiantamentos com saldo
	Help(" ",1,"FA560SALDO")
	dbSelectArea(cAlias)
	Return/*Function Fa560Adian*/
EndIf

If SEU->EU_EMISSAO > dDataBase  //somente adiantamentos com data anterior ou igual a data base
	MsgStop(STR0041,STR0040)  // "Adiantamento com data superior a data do sistema" ## "Data"
	dbSelectArea(cAlias)
	Return /*Function Fa560Adian*/
EndIf 

If lF560APROV
	lAprova := ExecBlock("F560APROV",.F.,.F.)
EndIf

If SEU->(FieldPos("EU_STATUS")) > 0 .And. !(SEU->EU_STATUS $ '03|05') .And. !lAprova//Somente adiantamento aprovados
	Help(" ",1,"FA560CPFIS",,STR0082,1,0) //"Adiantamento pendente de aprovacao."
	dbSelectArea(cAlias)
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a montagem do aHeader a partir dos campos SX3.           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCampos := "EU_NRREND|EU_HISTOR|EU_FORNECE|EU_LOJA|EU_NOME|EU_CGC|EU_EMISSAO|EU_NRCOMP|EU_VALOR|EU_CONTA|"

//Pe para possibilitar a inclusao de outros campos na tela de Prestação de Cotnas
If ExistBlock("FT560CPC")
	aCmpPE := ExecBlock("FT560CPC",.f.,.f.)
	For nY = 1 to Len(aCmpPE) 
		If SEU->(FieldPos(aCmpPE[nY])) > 0 .and. !(aCmpPE[nY] $ cCampos )
			cCampos += aCmpPE[nY] + "|"
		EndIf
	Next nY
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Integracao com o Modulo de Transporte (TMS)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If IntTMS() .And. nModulo == 43
	cCampos += "EU_FILORI|EU_VIAGEM|EU_CODVEI|EU_DESVEI|EU_CODDES|"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no DTQ (Viagem), pois, o SXB do campo Cod. Veiculo,³
	//³ filtra somente os veiculos utilizados na Viagem posicionada  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DTQ->(dbSetOrder(2))
	DTQ->(MsSeek(xFilial('DTQ')+ Left(cNroAnt,Len(DTQ->(DTQ_FILORI+DTQ_VIAGEM)))   ))
		
EndIf

//Ponto de entrada para adicao de campos na getdados.
If lF560Cpos
	cCampos += ExecBlock("F560CPOS",.F.,.F.,cCampos)
Endif

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(cAlias)
While !EOF() .And. (x3_arquivo == cAlias)
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. Trim(x3_campo)$ cCampos
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
	Endif
	If Trim(x3_campo) == "EU_NUM"
		bNumRel := X3_RELACAO	
	EndIf
	dbSkip()
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a montagem do aCols              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
dbSetOrder(3)  // filial+nroadia
aadd(aCols,Array(nUsado+1))    

For ny := 1 to Len(aHeader)
	If ( aHeader[ny][10] != "V")
		aCols[1][ny] := CriaVar(aHeader[ny][2])
	EndIf
	aCols[1][nUsado+1] := .F.  
Next ny


dbSelectArea(cAlias)
dbSetOrder(1)       // volta ao indice original
dbGoto( nRecnoSEU)  // volta ao registro do adiantamento
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do cabecalho e getdados                             ³                           
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private fa560Cod := SEU->EU_CAIXA
Private nFa560sld:= SEU->EU_SLDADIA
Private fa560Nro := SEU->EU_NUM
Private nSldOrig := SEU->EU_SLDADIA
Private fa560Seq := ""
Private dDataAdi := SEU->EU_EMISSAO
Private fa560Moed:= If(SEU->(FieldPos("EU_MOEDA")) > 0, SEU->EU_MOEDA, "")

Private fa560Apro:= If(SEU->(FieldPos("EU_CODAPRO")) > 0, SEU->EU_CODAPRO, "")

fa560Seq := Fa570SeqAtu(fa560Cod)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se ja existem comprovantes, pergunta se deseja fechar o adiantamento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
dbSetOrder(3)  // filial+nroadia
If dbSeek( xFilial()+ cNroAnt)
	// "Deseja fechar o adiantamento e transferir o saldo remanescente?","Adiantamento com comprovantes ja inclusos"
	If nSldOrig >0 .And. MsgYesNo(OemToAnsi(STR0023),OemToAnsi(STR0024))
		Fa560FcAdi( nRecnoSEU, nSldOrig,nSaveSx8)
		
		// CONTABILIZAÇÃO DO REGISTRO GERADO DO FECHAMENTO E TRANSFERENCIA DO SALDO REMANESCENTE
		If lPadrao579 .And. lGeraLanc	
			If nHdlPrv <= 0
				nHdlPrv +=HeadProva(cLote,"FINA560",Subs(cUsuario,7,6),@cArquivo)
			Endif
			If  nHdlPrv > 0 .And. Empty(SEU->EU_LA)
				nTotal	:=	DetProva(nHdlPrv,"579","FINA560",cLote)				
			Endif
			RodaProva(nHdlPrv,nTotal)
		Endif	
		
		If nHdlPrv > 0
			If cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,lAglutina)					
				Reclock("SEU",.F.)
				Replace EU_LA	With "S"
				MsUnLock()

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gravacao dos lancamentos do SIGAPCO                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PcoDetLan("000359","02","FINA560")
			Endif	
		Endif	
		
		dbSelectArea(cAlias)
		Return /*Function Fa560Adian*/
	EndIf
EndIf     

If Len(aRotina) == 2
	//Tratar aRotina para compatibilizar com a execução MsGetDados
	aRotina := { { STR0056, "FA560CpFis",0 ,3 },;  		//"Comprovantes Fiscais"
	       	     { STR0057, "FA560Adian",0 ,4 },;      	//"Outros Comprovantes"
	       	     { STR0057, "FA560Adian",0 ,4}}       	//"Outros Comprovantes"
EndIf

dbSelectArea(cAlias)
dbSetOrder(1)       // volta ao indice original
dbGoto( nRecnoSEU)  // volta ao registro do adiantamento

dbSelectArea("SET")
dbSetOrder(1)
dbSeek( xFilial()+SEU->EU_CAIXA)

dbSelectArea(cAlias)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia lancamento no PCO                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PcoIniLan("000359")

cCaption :=	SEU->EU_CAIXA	+ " - " +SET->ET_NOME
DEFINE FONT oFont NAME "Arial" SIZE 10,12 BOLD

nOpca := 0

aSize := MSADVSIZE()
		
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0015)+" "+fa560Nro From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL

oDlg:lMaximized := .T.

oTimer:= TTimer():New((nTimeOut-nTimeMsg),{|| MsgTimer(nTimeMsg,oDlg) },oDlg) // Ativa timer
oTimer:Activate()

oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20,.T.,.T. )
oPanel:Align := CONTROL_ALIGN_TOP   

@ 002, 003 SAY OemToAnsi(STR0016)+ " : " PIXEL OF oPanel FONT oFont COLOR CLR_GRAY   //"Caixinha"
@ 002, 050 SAY cCaption 				PIXEL OF oPanel FONT oFont 
@ 002, 200 SAY OemToAnsi(STR0017)  	PIXEL OF oPanel FONT oFont COLOR CLR_GRAY  //"Saldo : "
@ 002, 280 SAY oSaldo VAR nFa560sld PICTURE PesqPict("SEU","EU_SLDADIA") ;
												PIXEL OF oPanel FONT oFont  ;
												COLOR If(nFa560sld<0,CLR_RED,CLR_BLUE)

@ 011, 003 SAY OemToAnsi(STR0043) 	PIXEL OF oPanel FONT oFont COLOR CLR_GRAY  //"Data do Adiantamento:"
@ 011, 100 SAY dDataAdi					PIXEL OF oPanel FONT oFont  

oGet := MSGetDados():New(34,5,128,315,3,"FA560LinOK","FA560TudOK",,.T.,,,,300)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
                                                     

If lPanelFin
	ACTIVATE MSDIALOG oDlg ON INIT FaMyBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()})
Else	                	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()})
Endif

If nOpcA == 1
	//Se houve prestacao de contas
	If lContinua .and. nFa560Sld != nSldOrig

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tela de solicitacao dos dados de comprovantes ³
		//³ Fiscais na prestação de Contas.               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		aCompFis := Fa560GetCF()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava os dados³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      
		If !Empty(aCompFis)
			lGravaOk := Fa560Grava(cAlias,nRecnoSEU,nSaveSx8,aCompFis)		
		Else
		    lGravaOk := .F.			
		EndIf	           
		
		If !lGravaOk
			Help(" ",1,"A560NAOREG")
		EndIf
		
	Else //Se nao houve prestacao de contas posso devolver o dinheiro ao caixa
		If (nFa560Sld > 0) .And.;
			(MsgYesNo(OemToAnsi(STR0021),OemToAnsi(STR0022))) 	//"Deseja transferir o saldo remanescente para o caixinha?","Adiantamento com saldo remanescente"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza informacoes do registro de adiantamento            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			
			dbSelectArea("SEU")
			dbGoto(nRecnoSEU)
			
			If lPadrao579 .And. lGeraLanc			
				If nHdlPrv <= 0
					LoteCont("FIN")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Inicializa Lancamento Contabil                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nHdlPrv := HeadProva( cLote,;
						                      "FINA560" /*cPrograma*/,;
						                      Substr( cUsuario, 7, 6 ),;
						                      @cArquivo )
				Endif
				If  nHdlPrv > 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Prepara Lancamento Contabil                                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil 
							aAdd( aFlagCTB, {"EU_LA", "S", "SEU", SEU->( Recno() ), 0, 0, 0} )
						Endif
						nTotal += DetProva( nHdlPrv,;
						                    "579" /*cPadrao*/,;
						                    "FINA560" /*cPrograma*/,;
						                    cLote,;
						                    /*nLinha*/,;
						                    /*lExecuta*/,;
						                    /*cCriterio*/,;
						                    /*lRateio*/,;
						                    /*cChaveBusca*/,;
						                    /*aCT5*/,;
						                    /*lPosiciona*/,;
						                    @aFlagCTB,;
						                    /*aTabRecOri*/,;
						                    /*aDadosProva*/ )
					AAdd(aSEUCont,SEU->(RECNO()))
					Reclock("SEU",.F.)
					Replace EU_LA	With "S"
					MsUnLock()				
				Endif
			EndIf				
			
			If nHdlPrv > 0 .And. nTotal > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Efetiva Lan‡amento Contabil                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					RodaProva( nHdlPrv,;
					           nTotal )                               
					If cA100Incl( cArquivo,;
						           nHdlPrv,;
						           3 /*nOpcx*/,;
						           cLote,;
						           lDigita,;
						           lAglutina /*lAglut*/,;
						           /*cOnLine*/,;
						           /*dData*/,;
						           /*dReproc*/,;
						           @aFlagCTB,;
						           /*aDadosProva*/,;
						           aDiario )
							If !lUsaflag
								Reclock("SEU",.F.)
								Replace EU_LA	With "S"
								MsUnLock()
							Endif
					Endif	
					aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
			EndIf
			Fa560FcAdi(nRecnoSEU,nFa560Sld,nSaveSx8)			
		Endif
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada F560ADIA              				 ³
	//³ Destina-se a gravacoes complementares da exclusao  ³
	//³ do movimento do caixinha 							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("F560ADIA")
		ExecBlock("F560ADIA",.F.,.F.)
	Endif
Endif
MsUnLockAll()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa array da Integração com TMS x MNT			 	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFolTms   	:= {}	
aFolTmsBkp 	:= {}



If lFa550Adia
	ExecBlock("FA550ADF",.F.,.F.,{nOpca==1})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a gravacao dos lancamentos do SIGAPCO            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PcoFinLan("000359")

//Evita que a tela seja aberta novamente
MBrChgLoop(.F.)

dbSelectArea(cAlias)
Return /*Function Fa560Adian*/

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fa560GetCF ³ Autor ³ Lucas          		³ Data ³ 20/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Solicita dados de comprovantes Fiscais na prestação de     ³±±
±±³          ³ Contas.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa560GetCF()				                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo			    				      ³±±
±±³			 ³ ExpN1 = Número do registro 					              ³±±
±±³			 ³ ExpN2 = Opção do aRotina 					              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA560                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa560GetCF()
Local aSavArea   := GetArea()
Local cNFiscal   := CriaVar("F1_DOC")
Local cSerie     := CriaVar("F1_SERIE")
Local cFornece   := ""
Local cLoja      := ""
Local dEmissao   := CTOD("")
Local nValDesp   := 0.00
Local nValDesc	 := 0.00
Local nValFrete	 := 0.00
Local nValSeguro := 0.00
Local nValMerc	 := 0.00
Local nValBruto	 := 0.00
Local nValIVA	 := 0.00
Local nPercIB3895 := 0.00		            
Local nPercIVA	 := 0.00	                 
Local nPercIB672 := 0.00		             
Local nPercSUSS	 := 0.00	                 
Local nOutraPerc := 0.00  
Local nX  		 := 0
Local cConta     := ""
Local nOpcA      := 0	   
Local nPosForn   := 0                                                 
Local nPosLoja   := 0                                                 
Local nPosData   := 0                                                 
Local nPosVlBrut := 0                                                 
Local nPosConta  := 0
Local cNatureza  := ""
Local aSize      := {}
Local aObjects   := {}
Local aInfo      := {}
Local aPosObj    := {}
                
Local aCompFis   := {}

If AllTrim(FunName()) == "FINA560"
	nPosForn   := Ascan(aHeader,{|x| AllTrim(x[2]) == "EU_FORNECE"})
	nPosLoja   := Ascan(aHeader,{|x| AllTrim(x[2]) == "EU_LOJA"})
	nPosData   := Ascan(aHeader,{|x| AllTrim(x[2]) == "EU_EMISSAO"})
	nPosVlBrut := Ascan(aHeader,{|x| AllTrim(x[2]) == "EU_VALOR"})
	nPosConta  := Ascan(aHeader,{|x| AllTrim(x[2]) == "EU_CONTA"})

	cFornece  := If(nPosForn > 0,aCols[n][nPosForn],CriaVar("A2_COD"))
	cLoja     := If(nPosLoja > 0,aCols[n][nPosLoja],CriaVar("A2_LOJA"))
	dEmissao  := If(nPosData > 0,aCols[n][nPosData],CriaVar("EU_EMISSAO"))
	For nX := 1 To len(aCols)
		nValBruto += If(nPosVlBrut > 0,aCols[nX][nPosVlBrut],0.00)        
	Next nX
	cConta    := If(nPosConta  > 0,aCols[n][nPosConta],"")
	cNatureza := SET->ET_NATUREZ 
ElseIf AllTrim(FunName()) == "FINA100"
	cFornece  := CriaVar("A2_COD")
	cLoja     := CriaVar("A2_LOJA")
	dEmissao  := SE5->E5_DATA            
	nValBruto := SE5->E5_VALOR        
	cConta    := SE5->E5_DEBITO
	cNatureza := SE5->E5_NATUREZ
EndIf

//aSize := MSADVSIZE()     

aSize := MsAdvSize()
aObjects := {}
AAdd( aObjects, { 050, 050, .t., .t. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

//DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0058) FROM 9,0 TO 28,80 OF oMainWnd
		
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0058) From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL //"Datos del Comprobante Fiscal"

@ 025,001 TO 051, 355 LABEL STR0059 OF oDlg  PIXEL 		//"Comprobante Fiscal"
@ 055,001 TO 110, 355 LABEL STR0060 OF oDlg  PIXEL 		//"Totales"
@ 115,001 TO 185, 355 LABEL STR0061 OF oDlg  PIXEL 		//"Impuestos"

@ 037,004 SAY OemToAnsi(STR0062)    	         SIZE 23, 8 OF oDlg PIXEL		//"Factura"
@ 035,035 MSGET cNFiscal		                 PICTURE PesqPict("SF1","F1_DOC") 	SIZE 50, 8 OF oDlg PIXEL
@ 037,090 SAY OemToAnsi(STR0063)                 SIZE 25, 8 OF oDlg PIXEL		//"Serie"	
@ 035,120 MSGET cSerie			                 PICTURE PesqPict("SF1","F1_SERIE") SIZE 25, 8 OF oDlg PIXEL
@ 037,152 SAY OemToAnsi(STR0064)	             SIZE 40, 8 OF oDlg PIXEL		//"Proveedor"	
@ 035,190 MSGET cFornece						 PICTURE PesqPict("SA2","A2_COD") 	F3 CpoRetF3("F1_FORNECE"); 
                                                 VALID ExistCpo("SA2",cFornece) 	SIZE 40, 8 OF oDlg PIXEL               
                                                 
@ 037,240 SAY OemToAnsi(STR0065)	             SIZE 25, 8 OF oDlg PIXEL		//"Tienda"
@ 035,270 MSGET cLoja							 PICTURE PesqPict("SA2","A2_LOJA") 	F3 CpoRetF3("F1_LOJA");
												 VALID ExistCpo("SA2",cFornece+cLoja) SIZE 25, 8 OF oDlg PIXEL

If AllTrim(FunName()) == "FINA560"                                        
	@ 067,004 SAY OemToAnsi(STR0066)		         SIZE 50, 8 OF oDlg PIXEL		//"Valor Gastos"
	@ 065,075 MSGET nValDesp		                 PICTURE PesqPict("SF1","F1_VALMERC") SIZE 50, 8 OF oDlg PIXEL
EndIf

@ 067,152 SAY OemToAnsi(STR0067)	             SIZE 50, 8 OF oDlg PIXEL		//"Descuentos"
@ 065,205 MSGET nValDesc		                 PICTURE PesqPict("SF1","F1_VALMERC") SIZE 50, 8 OF oDlg PIXEL

@ 082,004 SAY OemToAnsi(STR0068)		         SIZE 50, 8 OF oDlg PIXEL       //"Frete"		
@ 080,075 MSGET nValFrete		                 PICTURE PesqPict("SF1","F1_VALMERC") SIZE 50, 8 OF oDlg PIXEL
@ 082,152 SAY OemToAnsi(STR0069)		         SIZE 50, 8 OF oDlg PIXEL		//"Seguro"
@ 080,205 MSGET nValSeguro		                 PICTURE PesqPict("SF1","F1_VALMERC") SIZE 50, 8 OF oDlg PIXEL

If AllTrim(FunName()) == "FINA560"
	@ 097,004 SAY OemToAnsi(STR0070)			     SIZE 50, 8 OF oDlg PIXEL		//"Valor Mercaderia"
Else
	@ 097,004 SAY OemToAnsi(STR0066)		         SIZE 50, 8 OF oDlg PIXEL		//"Valor Gastos"
EndIf
	
@ 095,075 MSGET nValMerc		                 PICTURE PesqPict("SF1","F1_VALMERC") SIZE 50, 8 OF oDlg PIXEL
@ 097,152 SAY OemToAnsi(STR0071)		         SIZE 50, 8 OF oDlg PIXEL		//"Valor Bruto"
@ 095,205 MSGET nValBruto		                 PICTURE PesqPict("SF1","F1_VALMERC") WHEN .F. SIZE 50, 8 OF oDlg PIXEL

@ 127,004 SAY OemToAnsi(STR0072) 	         	 SIZE 50, 8 OF oDlg PIXEL		//"Valor IVA"
@ 125,075 MSGET nValIVA			                 PICTURE PesqPict("SF1","F1_VALMERC") SIZE 50, 8 OF oDlg PIXEL
@ 127,152 SAY OemToAnsi(STR0073)     	 		 SIZE 60, 8 OF oDlg PIXEL		//"Perc. IB 38/95"
@ 125,205 MSGET nPercIB3895		                 PICTURE PesqPict("SF1","F1_VALMERC") SIZE 50, 8 OF oDlg PIXEL

@ 142,004 SAY OemToAnsi(STR0074)        		 SIZE 60, 8 OF oDlg PIXEL		//"Perc. IVA 3337"
@ 140,075 MSGET nPercIVA		                 PICTURE PesqPict("SF1","F1_VALMERC") SIZE 50, 8 OF oDlg PIXEL
@ 142,152 SAY OemToAnsi(STR0075)       			 SIZE 60, 8 OF oDlg PIXEL		//"Perc. IB 672/95"
@ 140,205 MSGET nPercIB672		                 PICTURE PesqPict("SF1","F1_VALMERC") SIZE 50, 8 OF oDlg PIXEL

@ 157,004 SAY OemToAnsi(STR0076)			     SIZE 50, 8 OF oDlg PIXEL		//"Perc. SUSS"
@ 155,075 MSGET nPercSUSS		                 PICTURE PesqPict("SF1","F1_VALMERC") SIZE 50, 8 OF oDlg PIXEL
@ 157,152 SAY OemToAnsi(STR0077)	 			 SIZE 50, 8 OF oDlg PIXEL		//"Otras Perc."
@ 155,205 MSGET nOutraPerc		                 PICTURE PesqPict("SF1","F1_VALMERC") SIZE 50, 8 OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(Fa560Ok(nValMerc,nValBruto,(nValMerc+nValIVA+nValDesp+nValFrete+nValSeguro-nValDesc),cNFiscal),oDlg:End(),nOpca := 0)},{||oDlg:End()})

If nOpcA == 1
	//Carrega o Array aCompFis (Comprovante Fiscal)
	AADD(aCompFis,{cNFiscal,cSerie,cFornece,cLoja,dEmissao,cNatureza})
	AADD(aCompFis,{nValDesp,nValDesc,nValFrete,nValSeguro,nValMerc,nValBruto})
    AADD(aCompFis,{nValIVA,nPercIB3895,nPercIVA,nPercIB672,nPercSUSS,nOutraPerc,cConta})
Else
 	aCompFis := {}
EndIf                                                                            

RestArea(aSavArea)
Return aCompFis


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fa560Ok    ³ Autor ³ Jose Lucas          ³ Data ³ 21/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validar a EnChoice.									 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa560Ok()						                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 									    				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA560                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa560Ok(nVal,nValBruto,nValTot,cNFiscal)
Local lRet := .T.

Default cNFiscal := ""

If nVal == 0
	MsgAlert(OemToAnsi(STR0081))
	lRet := .F.
EndIf

If lRet .And. nValTot<>nValBruto
	Aviso(STR0054,STR0089,{"OK"})
	lRet := .F.
EndIf	

If lRet .And. Empty(cNFiscal)
	Aviso(STR0054,STR0062+STR0085,{"OK"})
	lRet := .F.                                   
EndIf                                             
	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Função	 ³ Fa560GetImpos³ Autor ³ José Lucas		³ Data ³ 21/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±     
±±³Descri‡…o ³ Retornar array com nome dos campos Base, Aliquota e Valor   ³±
±±³          ³ dos impostos.                                               ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Parametros³ ExpC1 := Sigla do imposto.                                  ³±
±±³          ³          Exemplo: "IVA", "IBP"                              ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ ExpA1 {Nome do Cpo Base,Aliquota,Imposto}				   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização Argentina                                       ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa560GetImpos(cSiglaImp,cAlias)
LOCAL aSavArea  := GetArea()
LOCAL aImposto  := {"","","",0.00} 
LOCAL cCpoVBase := ""
LOCAL cCpoCAliq := ""
LOCAL cCpoCImpo := ""
LOCAL nAliqImpo := 0.00
                                                           
SFB->(dbSetOrder(1))
If SFB->(dbSeek(xFilial("SFB")+cSiglaImp))
	While SFB->(!Eof()) .and. SFB->FB_FILIAL == xFilial("SFB") .and. AllTrim(cSiglaImp) $ SFB->FB_CODIGO
		If cAlias == "SD1"
			cCpoVBase := "D1_BASIMP"+AllTrim(SFB->FB_CPOLVRO)
            cCpoCAliq := "D1_ALQIMP"+AllTrim(SFB->FB_CPOLVRO)
   			cCpoCImpo := "D1_VALIMP"+AllTrim(SFB->FB_CPOLVRO)  
   			nAliqImpo := SFB->FB_ALIQ
   		Else
			cCpoVBase := "F1_BASIMP"+AllTrim(SFB->FB_CPOLVRO)
			cCpoCAliq := " "
   			cCpoCImpo := "F1_VALIMP"+AllTrim(SFB->FB_CPOLVRO)
   			nAliqImpo := SFB->FB_ALIQ   
   		EndIf	
        If !Empty(cCpoCImpo)
        	aImposto[1] := cCpoVBase
        	aImposto[2] := cCpoCAliq                    
			aImposto[3] := cCpoCImpo
			aImposto[4] := nAliqImpo
		EndIf
		SFB->(dbSkip())
	End
EndIf
RestArea(aSavArea)                             
Return aImposto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA560Lanc ºAutor  ³Microsiga           º Data ³  23/03/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua os lancamentos no PCO e CTB e abate o saldo do cai- º±±
±±º          ³ xinha. Este processo foi transformado em funcao para ser   º±±
±±º          ³ executado apos a aprovacao do movimento no controle de     º±±
±±º          ³ alcada (MV_FINCTAL=2)                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA560Lanc()
Local nSldAtu		:= 0
Local nVlrRep		:= 0
Local lPadrao572	:= VerPadrao("572")
Local nHdlPrv		:= 0
Local lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/) 
Local aFlagCTB		:= {}
Local nTotal		:= 0
Local lDigita		:= If(MV_PAR01 == 1,.T.,.F.)
Local lAglutina		:= If(MV_PAR02 == 1,.T.,.F.)
Local lGeraLanc		:= If(MV_PAR03 == 1,.T.,.F.)
Local lF560Rep		:= .T.
Local lExecMsg		:= .T.
Local lFa550MSG		:= ExistBlock("Fa550MSG")
Local lMntTms		:= ( SuperGetMV( "MV_NGMNTMS",,'N') == 'S' )//-- Ativa integracao TMS X MNT.
Local cArquivo
Local lR5			:= GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao		:= Val(GetVersao(.F.))     // Indica a versao do Protheus
Local lExeIntTms	:= ((nVersao == 11 .And. lR5) .Or. nVersao > 11) //-- Verificação de Release .5 do Protheus 11
Local cSerDesp		:= ( SuperGetMV('MV_SERDESP',,'' ) )  
Local lRepManu    := (GetNewPar("MV_RPCXMN","2")== "1")

Private aFolTms		:= {}
Private aFolTmsBkp	:= {}
Private cLote			:= ""
Private aDiario		:= {}
Private cCaixa    	:= SEU->EU_CAIXA

//***Posicionar no registro do SEU***
If ( FindFunction( "UsaSeqCor" ) .And. UsaSeqCor() ) 
	cCodDiario:= M->EU_DIACTB
	AADD(aDiario,{"SEU",SEU->(recno()),cCodDiario,"EU_NODIA","EU_DIACTB"})
Endif 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravacao dos lancamentos do SIGAPCO                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PcoDetLan("000359","02","FINA560")
dbSelectArea("SET")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza saldo do caixinha                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nSldAtu := ET_SALDO - SEU->EU_VALOR
RecLock("SET",.F.)
REPLACE ET_SALDO WITH nSldAtu
MsUnlock()

If FindFunction( "FXMultSld()" ) .AND. FXMultSld()
	AtuSalCxa( ET_CODIGO, dDataBase, SEU->EU_VALOR * -1 )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada F560GRV              						    ³
//³ Destina-se a gravacoes complementares do movimento do caixinha  ³
//³ inclusive para criar o cheque avulso quando ao adiantamento     ³
//³ exigir															³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("F560GRV")
	ExecBlock("F560GRV",.F.,.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravacao dos lancamentos do SIGAPCO                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PcoDetLan("000359","01","FINA560")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ contabilizacao do movimento                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lPadrao572 .and. lGeraLanc
	If nHdlPrv <= 0
		LoteCont("FIN")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa Lancamento Contabil                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nHdlPrv := HeadProva( cLote,;
			                      "FINA560" /*cPrograma*/,;
			                      Substr( cUsuario, 7, 6 ),;
			                      @cArquivo )
	Endif
	If  nHdlPrv > 0 .And. Empty(SEU->EU_LA)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Prepara Lancamento Contabil                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil 
				aAdd( aFlagCTB, {"EU_LA", "S", "SEU", SEU->( Recno() ), 0, 0, 0} )
			Endif
			nTotal += DetProva( nHdlPrv,;
			                    "572" /*cPadrao*/,;
			                    "FINA560" /*cPrograma*/,;
			                    cLote,;
			                    /*nLinha*/,;
			                    /*lExecuta*/,;
			                    /*cCriterio*/,;
			                    /*lRateio*/,;
			                    /*cChaveBusca*/,;
			                    /*aCT5*/,;
			                    /*lPosiciona*/,;
			                    @aFlagCTB,;
			                    /*aTabRecOri*/,;
			                    /*aDadosProva*/ )
	Endif

	If nHdlPrv > 0 .And. nTotal > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetiva Lan‡amento Contabil                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RodaProva( nHdlPrv,;
			           nTotal )                               
			If cA100Incl( cArquivo,;
				           nHdlPrv,;
				           3 /*nOpcx*/,;
				           cLote,;
				           lDigita,;
				           lAglutina /*lAglut*/,;
				           /*cOnLine*/,;
				           /*dData*/,;
				           /*dReproc*/,;
				           @aFlagCTB,;
				           /*aDadosProva*/,;
				           aDiario )
					If !lUsaflag
						Reclock("SEU",.F.)
						Replace EU_LA	With "S"
						MsUnLock()
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Gravacao dos lancamentos do SIGAPCO                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PcoDetLan("000359","02","FINA560")
			Endif		
			aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada F560REP              							³
//³ Destina-se a permitir ou nao as reposicoes. O retorno sera logi-³
//³ co, sendo .T. permite a reposicao ou .F. em caso contrario. 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("F560REP")
	lF560Rep := ExecBlock("F560REP",.F.,.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o saldo ficou negativo ou      ³
//³ atingiu o limite de reposicao              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea('SET')
lExecMsg := If(lFa550MSG,ExecBlock("Fa550MSG",.F.,.F.),.T.)
If lF560Rep .and. ((nSldAtu < 0) .Or.;
	Iif( ET_TPREP=="0", (ET_VALOR - nSldAtu > ET_LIMREP),;
	((1-nSldAtu/ET_VALOR)*100 > ET_LIMREP) ))
	If ExistBlock("FA550VERIF",.T.) .And. Fa550Verif()
		If Fa550VlUsr(SET->ET_CODIGO,__CUSERID)
			If lExecMsg
				If MsgYesNo(OemToAnsi(STR0019),OemToAnsi(STR0020))
					// "Deseja fazer a reposicao agora? ","Valor limite de reposicao atingido"
					If lRepManu
				       FA550BcRep(cCaixa)
				       nVlrRep := Fa550Repor( ET_CODIGO,.T.,.T.,.T.) // Baixa e repoe  
				   	Else    
				       nVlrRep := Fa550Repor( ET_CODIGO,.T.,.T.,.T.) // Baixa e repoe  
				   	Endif
				Endif
			Endif
		Else
			MsgAlert(OemToAnsi(STR0020))
		Endif
	Else
		If lExecMsg
			If MsgYesNo(OemToAnsi(STR0019),OemToAnsi(STR0020))
				// "Deseja fazer a reposicao agora? ","Valor limite de reposicao atingido"
				If lRepManu
				   FA550BcRep(cCaixa)
				   nVlrRep := Fa550Repor( ET_CODIGO,.T.,.T.,.T.) // Baixa e repoe  
				Else    
				   nVlrRep := Fa550Repor( ET_CODIGO,.T.,.T.,.T.) // Baixa e repoe  
				Endif
			Endif
		Endif
	EndIf
Endif

If cPaisLoc <> "BRA" .And. SET->(FieldPos('ET_NRREND')) > 0 .And. SEU->(FieldPos('EU_NRREND')) > 0

	DbSelectArea('SET')
	DbSetOrder(1)
	MsSeek(xFilial()+SEU->EU_CAIXA)
	RecLock('SET',.F.)
	Replace ET_NRREND WITH SEU->EU_NRREND
    MsUnLock()

	PcoDetLan("000359","01","FINA550")		

Endif

If IntTMS() .And. nModulo == 43  
	If (!Empty(SEU->EU_CODVEI) .And. !Empty(SEU->EU_CODDES) .And. ;
					Posicione("DA3",1,xFilial("DA3")+SEU->EU_CODVEI,"DA3_FROVEI") == StrZero(1,Len(DA3->DA3_FROVEI)));																								
					.Or. ( !Empty(SEU->EU_FILORI) .And. !Empty(SEU->EU_VIAGEM) .And. !Empty(SEU->EU_CODDES))			
		// Grava o Custo de Transporte
		TMA250GrvSDG("SEU",SEU->EU_FILORI,SEU->EU_VIAGEM,SEU->EU_CODDES,SEU->EU_VALOR,1,SEU->EU_CODVEI,,,,,,,SEU->EU_NUM)
	EndIf
	If lExeIntTms //So executar integracao no Release .5 da versao 11 ou versao posterior
		If lMntTms			
			// Grava Os e Finalizada a mesma.
			TmsMntGrOs('2',cSerDesp,aFolTms,aFolTmsBkp)
		EndIf
		aFolTms		:= {}
		aFolTmsBkp	:= {}
	EndIf	
EndIf

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FB560Inclui ³ Autor³ Carlos E. Chigres   ³ Data ³ 08/11/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclusao de Comprovantes do Caixinha em modo PLANILHA      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FB560Inclui()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo									  ³±±
±±³			 ³ ExpN1 = N£mero do registro 								  ³±±
±±³			 ³ ExpN2 = N£mero da op‡„o selecionada 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA560 - Localizacao Chile                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FB560Inclui(cAlias,nReg,nOpc,cFilOri,cViagem)

Local aArea		 := GetArea()
Local nOpcA		 := 0
Local nPosi      := 1
Local nInd       := 1
Local nCntFor	 := 0
Local nSaveSx8	 := GetSx8Len()
Local cCampo     := " " 
Local aSize		 := {}
Local aObjects	 := {}
Local aInfo		 := {}
Local aPosObj	 := {}
Local aCampos    := {}
Local aUnWanted  := {}

//--- array de controle de Lock nos Caixinhas (usado em Fb560Caixa)
Private aCajas   := {}

Private aFolTms    := {}
Private aFolTmsBkp := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aTELA[0][0],aGETS[0]

Private oGet01
Private aHeader := {}, aCols := {}

Private ADIANTAMENTO :=	.F.

DEFAULT cFilOri		:= ''
DEFAULT cViagem		:= ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Composicao dos campos que irao fazer parte da MsNewGetDados. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCampos := { "EU_NUM","EU_CAIXA","EU_TIPO","EU_HISTOR","EU_NRCOMP","EU_VALOR","EU_MOEDA","EU_EMISSAO","EU_DTDIGIT",;
             "EU_BENEF","EU_FORNECE","EU_LOJA","EU_NOME","EU_CONTAD","EU_CONTAC","EU_CCD","EU_CCC",;
             "EU_ITEMD","EU_ITEMC","EU_CLVLDB","EU_CLVLCR","EU_NODIA","EU_SLDADIA","EU_NRREND" } 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Composicao dos campos que NAO PODEM fazer parte da MsNewGetDados  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aUnWanted := { "EU_CGC","EU_CONTA","EU_BAIXA","EU_NROADIA","EU_DIACTB","EU_VLMOED2",;
               "EU_NFISCAL","EU_SERIE","EU_CODAPRO","EU_APROVA" } 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao que monta o aHeader e o aCols vazio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
A560Fill( cAlias, aUnWanted, aCampos )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia lancamento no PCO ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PcoIniLan("000359")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia para processamento dos Gets ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//+------------------------------------------------------+
	//| Faz o calculo automatico de dimensoes de objetos     |
	//+------------------------------------------------------+
	aSize := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 100, 100, .t., .t. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

   	Define MSDialog oDlg Title cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd Pixel

       oGet01 := MSNewGetDados():New(aPosObj[1,1]+2,aPosObj[1,2]+1,aPosObj[1,3],aPosObj[1,4],Iif(Altera .Or. Inclui, GD_INSERT+GD_DELETE+GD_UPDATE, 0), "B560LinOk" ,"Allwaystrue()" , , , , 999, ,  , "B560DelK" , oDlg, aHeader, aCols )

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If( oGet01:TudoOk(), oDlg:End(), nOpca:=0)},{||nOpca:=0,oDlg:End()})


If nOpcA == 1

	Begin Transaction

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento aCols, ordenando pela Caixinha + EU_NUM ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSort( oGet01:aCols,,,{|x,y| x[2]+x[1] < y[2]+y[1] } )
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Loop para a Gravacao do aCols ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    //
    dbSelectArea( "SEU" )
    //
    For nInd := 1 TO Len( oGet01:aCols )

       If !GDDeleted( nInd, oGet01:aHeader, oGet01:aCols ) 

	      RecLock( "SEU", .T. )
	   
		    SEU->EU_FILIAL := xFilial("SEU")

	        For nCntFor := 1 TO Len( aCampos )

               cCampo  := aCampos[ nCntFor ]
               nPosi   := FieldPos( cCampo ) 
               xContem := GDFieldGet( cCampo, nInd, , oGet01:aHeader, oGet01:aCols )

                If nPosi > 0
                   //--- Grava, se o campo existe na base
			       FieldPut( nPosi, xContem )
			       //
                EndIf

            Next nCntFor  

           //--- Grava Status de aguardando liberação do título se o campo existir.
           If FieldPos("EU_STATUS") > 0
		      SEU->EU_STATUS := "01"
           EndIf

           //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
           //³ Bloco para gravar o numero de sequencial de caixa aberto ³
           //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	       SEU->( DbCommit() )

           //--- Posiciona no Caixinha
	       dbSelectArea("SET")
	       dbSetOrder(1)
	       dbSeek( xFilial("SET")+SEU->EU_CAIXA)
           // 
           dbSelectArea( "SEU" )

	       SEU->EU_SEQCXA := SET->ET_SEQCXA  
           //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
           //³ Fim do Bloco ³
           //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

           //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
           //³ Bloco para avaliar e gravar o Saldo Adiantamento ³
           //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             If SEU->EU_TIPO == "01" 
                SEU->EU_SLDADIA := SEU->EU_VALOR
             EndIf

	      MsUnLock()

          //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
          //³ Efetua os lancamentos no PCO e CTB e abate o saldo do caixinha   ³
          //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
          FB560Lanc()

       EndIf 

    Next nInd 

    While (GetSx8Len() > nSaveSx8 )
	   ConfirmSX8()
	Enddo

	End Transaction

Else

	While ( GetSx8Len() > nSaveSx8 )
		RollBackSX8()
	EndDO

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desfazer os Locks feitos em Fb560Valor ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "SET" )
dbSetOrder( 1 )
  //
  For nInd := 1 TO Len( aCajas )
    
     cCampo := aCajas[ nInd ][ 1 ]
     //
     If dbSeek( xFilial("SET") + cCampo )

        MsUnLock()        

     EndIf        

  Next nInd

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a gravacao dos lancamentos do SIGAPCO            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PcoFinLan("000359")
PcoFreeBlq("000359")
dbSelectArea(cAlias)
RestArea(aArea)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³B560LinOk ³ Autor ³ Andre Schwartz        ³ Data ³ 22/11/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a linha digitada esta OK                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FB560Inclui, FINA560                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function B560LinOk()

Local lRet     := .T.

Local nI       := 1
Local nPos     := 1
Local cCampo   := " "
Local xContem  := NIL
Local aVerCamp := { "EU_CAIXA", "EU_TIPO", "EU_HISTOR", "EU_VALOR", "EU_BENEF", "EU_NRCOMP", "EU_EMISSAO" }

//--- Ignore linhas deletadas
If !GDDeleted( n, oGet01:aHeader, oGet01:aCols ) 

   For nI := 1 To Len( aVerCamp )
   
      cCampo  := aVerCamp[ nI ]
            
      xContem := GDFieldGet( cCampo, n, , oGet01:aHeader, oGet01:aCols )
      
      If Empty( xContem )

         nPos   := GDFieldPos( cCampo, oGet01:aHeader )
         cCampo := oGet01:aHeader[ nPos ][ 1 ]
         //--- Inconsistencia , Campo Obrigatorio - não preenchido.
         Aviso( STR0083, STR0084 + cCampo + STR0085, { 'Ok' } )  

         lRet := .F.
         
         EXIT

      EndIf

   Next nI

EndIf

If lRet
   lRet := PcoVldLan('000359','02','FINA560',,,.T.) 
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   º A560Fill   º Autor º        Nava        º Data º 18/10/01 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¹±±
±±º   Preenche aHeader e Acols da GetDados                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe    º A560Fill( cAlias, aNoFields, aYesFields, lOnlyYes )       º±±
±±º            º                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros º                                                           º±±
±±º         01 º cAlias     - Alias                                        º±±
±±º         02 º aNoFields  - Campos a serem excluidos                     º±±
±±º         03 º aYesFields - Campos a serem incluidos                     º±±
±±º         04 º lOnlyYes   - Flag indicando se considera somente os camposº±±
±±º            º declarados no aYesFields + campos do usuario              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno    º                                                           º±±
±±ºÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso        º Generico                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Comentario º Supoe aHeader e Acols declarados como Private PELO progr. º±±
±±º            º e inicializadas como um array vazio.                      º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A560Fill( cAlias, aNoFields, aYesFields, lOnlyYes )

Local nX         := 1
Local nPos       := 1
Local aChange    := {}
Local cTxValid   := " "

Local aArea 	 := GetArea()
Local aAreaAlias := ( cAlias )->( GetArea() )
Local lNoFields	 := ( aNoFields <> NIL )
Local lYesFields := ( aYesFields <> NIL )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aHeader e Acols devem vir definidos OBRIGATORIAMENTE ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nUsado      := Len( aHeader )

Default lOnlyYes  := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Composicao dos VALIDS que serao alterados na MsNewGetDados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  Aadd( aChange, { "EU_CAIXA", "ExistCpo('SET') .And. Fb560Caixa()" } ) // Vazio() .or. ExistCpo("SET")             
  Aadd( aChange, { "EU_TIPO" , "Pertence('00|01')" } )              // Len(M->EU_TIPO)>1 .And. Pertence("00|01") 
  Aadd( aChange, { "EU_VALOR", "Positivo() .And. Fb560Valor()" } )  // Positivo() .And. Fa560Valor() 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array aHeader ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SX3->( DbSetOrder( 1 ) )
SX3->( DbSeek( cAlias ) )

SX3->( DbEval( {||	++nUsado, ;
		 					AADD(	aHeader, {	AllTrim( X3Titulo()), ;
												RTrim(X3_CAMPO),; 
												X3_PICTURE, ;
												X3_TAMANHO, ;
												X3_DECIMAL, ;
												X3_VALID, 	;
												X3_USADO,	;
												X3_TIPO, 	;
												X3_F3,	    ;
												X3_CONTEXT  } ) },;
					{ || 	( lYesFields .AND. Ascan( aYesFields, { |x| x == AllTrim( X3_CAMPO ) } ) > 0 ) .OR. ;
							If(lOnlyYes,X3_PROPRI == "U" .And. X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL,;
							( X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL .AND. ;
							( !lNoFields .OR. Ascan( aNoFields, Rtrim( X3_CAMPO ) ) == 0 ) )) },;
					{ || 	! Eof() .AND. X3_ARQUIVO == cAlias } )	)			
		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Varredura do aHeader ja montado, para interceptar os Valids ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len( aHeader )

    //--- Determina a posicao do Campo no aChange
    nPos := aScan( aChange, { |x| x[ 1 ] == aHeader[ nX ][ 2 ] } )
    
    If nPos > 0

       cTxValid := aChange[ nPos ][ 2 ] 

       If !Empty( cTxValid )
       
          aHeader[ nX ][ 6 ] := cTxValid

       EndIf
    
    EndIf

Next nX 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aCols vazio para a MsNewGetDados() ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aCols,Array(nUsado+1))
Aeval( aHeader, {|aCampo, nI| aCols[1][nI] := ( cAlias )->( CriaVar(aHeader[nI,2],.T.) ) } )
aCols[Len(aCols)][nUsado+1] := .F. 

RestArea( aAreaAlias )
RestArea( aArea )

Return Nil


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fb560Valor ³ Autor ³ Carlos E. Chigres   ³ Data ³ 08/11/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do campo EU_VALOR                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fb560Valor()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Acionado exclusivamente no modo Planilha da Inclusao       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fb560Valor()

//--- Retorno
Local lRet := .T.

//--- Ambiente
Local aAreaAnt  := GetArea()

//--- Genericas
Local nX        := 1
Local nPosValor := GDFieldPos( "EU_VALOR", oGet01:aHeader )
Local nPosCaixa := GDFieldPos( "EU_CAIXA", oGet01:aHeader )
Local lRetValor := .T.

//--- Leitura de campos do aCols
Local nValor    := GDFieldGet( "EU_VALOR", n, .T., oGet01:aHeader, oGet01:aCols )    // 3o parametro -> ReadVar
Local cCaixa    := GDFieldGet( "EU_CAIXA", n, , oGet01:aHeader, oGet01:aCols )

//--- Movimento Acumulado
Local cCajaCh   := " "
Local nMoveCx   := 0


If ExistBlock("F560VALOR")
   lRetValor := ExecBlock("F560VALOR",.F.,.F.)
Endif


If nValor <= 0

	Help(" ",1,"FA560VALOR")
	lRet := .F.

ElseIf ValType("cCaixa") == "C" .And. Empty( cCaixa )

	// No caso de adiantamento, o acols nao contem o campo EU_CAIXA
	Help(" ",1,"FA560CXVAZ")
	lRet := .F.

EndIf


//--- Prossegue ?
If lRet 

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Trecho construido para Somar os valores dos ³
   //³ Movimentos ja digitados e que pertencam a   ³
   //³ mesma CAIXINHA.                             ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    nMoveCx := 0

	For nX := 1 To Len( oGet01:aCols )

        //--- Nao considera linhas deletadas
        If !GDDeleted( nX, oGet01:aHeader, oGet01:aCols )

           //--- Nao posso considerar a linha que esta sendo editada ...
           If nX != n

              //--- Extracao da Caixa lida do aCols 
              cCajaCh := aCols[ nX ][ nPosCaixa ]
           
              //--- Acumula SOMENTE se for da mesma Caixa da Linha que esta sendo digitada / validada
              If cCajaCh == cCaixa
                     
                 nMoveCx += aCols[ nX ][ nPosValor ]

              EndIf

           EndIf

	    EndIf

	Next nX

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Na validacao do valor digitado, e verificado se o saldo da ³
    //³ caixinha selecionada e suficiente para o movimento.        ³
    //³ Para esta validacao, nao devera ser considerado            ³
    //³ simplesmente o saldo atual da caixinha: o valor a ser      ³
    //³ considerado sera o saldo da caixinha subtraindo-lhe        ³
    //³ os valores dos movimentos (linhas) ja digitados e que      ³
    //³ pertencam a mesma caixinha.                                ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SET")
	dbSetOrder(1)
	dbSeek( xFilial("SET")+cCaixa )

	If SET->ET_SALDO - nMoveCx < nValor .And. lRetValor   // Valor informado e' superior ao saldo
       Help(" ",1,"FA560SALDO")
	   lRet := .F.
	EndIf

EndIf	


RestArea( aAreaAnt )

Return( lRet )


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fb560Caixa ³ Autor ³ Carlos E. Chigres   ³ Data ³ 08/11/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do campo EU_CAIXA                                ³±±
±±³          ³                                                            ³±±
±±³          ³ Devido a validacao do VALOR no Lancamento, nao sera        ³±±
±±³          ³ possivel trocar o campo EU_CAIXA apos informado. Afinal,   ³±±
±±³          ³ a validacao do VALOR se da somando os lancamentos para a   ³±±
±±³          ³ mesma Caixinha ao longo do aCols.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fb560Caixa()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Acionado exclusivamente no modo Planilha da Inclusao       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fb560Caixa()

//--- Retorno
Local lRet := .T.

//--- Genericas
Local lFwd     := .T.
Local nPos     := 1
Local cFilSET  := xFilial("SET")
Local aAreaAnt := GetArea()

//--- Leitura do CONTEUDO do aCols - terceiro parametro se TRUE representa ReadVar
Local cContem := GDFieldGet( "EU_CAIXA", n, .F., oGet01:aHeader, oGet01:aCols )    
Local xConten := GDFieldGet( "EU_CAIXA", n, .T., oGet01:aHeader, oGet01:aCols )    


 //--- Verifica se existe CONTEUDO PREVIO ja armazenado no aCols
 If Empty( cContem )

    If !Empty( xConten )

       dbSelectArea("SET")
       dbSetOrder( 1 )
       lFwd := dbSeek( cFilSET + xConten )

       If lFwd

          If SET->( MsRLock() )

             nPos := aScan( aCajas, {|x| x[ 1 ] ==  SET->ET_CODIGO } )
             //
             If nPos == 0
                Aadd( aCajas, { SET->ET_CODIGO , " " } )
             EndIf
                       
          Else

             lRet := .F.
             //
             IW_MsgBox( STR0087, STR0054, "STOP" )  //"Este Caixinha está sendo utilizado em outro terminal, não pode ser utilizado no Movimento"###"Atenção"

          EndIf

       EndIf

    EndIf
 
 Else

    lRet := .F.
    //---  Inconsistencia , Já existe uma Caixinha informada, e não pode ser alterada.
    Aviso( STR0083, STR0086 , { "Ok" } ) //"Inconsistencia"###"Já existe uma Caixinha informada, e não pode ser alterada."
 
 EndIf

RestArea( aAreaAnt )

Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ B560DelK ³ Autor ³ Andre Schwartz        ³ Data ³ 22/11/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Na restauracao da linha, precisa checar Valor novamente    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FB560Inclui, FINA560                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function B560DelK()

Local lRet := .T.

//--- Ambiente
Local aAreaAnt  := GetArea()

//--- Genericas
Local nX        := 1
Local nPosValor := GDFieldPos( "EU_VALOR", oGet01:aHeader )
Local nPosCaixa := GDFieldPos( "EU_CAIXA", oGet01:aHeader )

//--- Leitura de campos do aCols
Local nValor    := GDFieldGet( "EU_VALOR", n, , oGet01:aHeader, oGet01:aCols )   
Local cCaixa    := GDFieldGet( "EU_CAIXA", n, , oGet01:aHeader, oGet01:aCols )

//--- Movimento Acumulado
Local cCajaCh   := " "
Local nMoveCx   := 0

 //--- Se ja esta deletado, nao deixa reintegrar ... pela validacao do campo Valor
 If GDDeleted( n, oGet01:aHeader, oGet01:aCols ) 

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Trecho construido para Somar os valores dos ³
   //³ Movimentos ja digitados e que pertencam a   ³
   //³ mesma CAIXINHA.                             ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    nMoveCx := 0

	For nX := 1 To Len( oGet01:aCols )

        //--- Nao considera linhas deletadas
        If !GDDeleted( nX, oGet01:aHeader, oGet01:aCols )

           //--- Nao posso considerar a linha que esta sendo editada ...
           If nX != n

              //--- Extracao da Caixa lida do aCols 
              cCajaCh := aCols[ nX ][ nPosCaixa ]
           
              //--- Acumula SOMENTE se for da mesma Caixa da Linha que esta sendo digitada / validada
              If cCajaCh == cCaixa
                     
                 nMoveCx += aCols[ nX ][ nPosValor ]

              EndIf

           EndIf

	    EndIf

	Next nX

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Na validacao do valor digitado, e verificado se o saldo da ³
    //³ caixinha selecionada e suficiente para o movimento.        ³
    //³ Para esta validacao, nao devera ser considerado            ³
    //³ simplesmente o saldo atual da caixinha: o valor a ser      ³
    //³ considerado sera o saldo da caixinha subtraindo-lhe        ³
    //³ os valores dos movimentos (linhas) ja digitados e que      ³
    //³ pertencam a mesma caixinha.                                ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SET")
	dbSetOrder(1)
	dbSeek( xFilial("SET")+cCaixa )

	If SET->ET_SALDO - nMoveCx < nValor    // Valor informado e' superior ao saldo
       Help(" ",1,"FA560SALDO")
	   lRet := .F.
	EndIf

 EndIf
 
RestArea( aAreaAnt )

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FB560Lanc ºAutor  ³Microsiga           º Data ³  23/03/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua os lancamentos no PCO e CTB e abate o saldo do      º±±
±±º          ³ caixinha.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FB560Lanc()

Local nSldAtu		:= 0
Local nVlrRep		:= 0
Local lPadrao572	:= VerPadrao("572")
Local nHdlPrv		:= 0
Local lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/) 
Local aFlagCTB		:= {}
Local nTotal		:= 0
Local lDigita		:= If(MV_PAR01 == 1,.T.,.F.)
Local lAglutina		:= If(MV_PAR02 == 1,.T.,.F.)
Local lGeraLanc		:= If(MV_PAR03 == 1,.T.,.F.)
Local lF560Rep		:= .T.
Local lExecMsg		:= .T.
Local lFa550MSG		:= ExistBlock("Fa550MSG")
Local lMntTms		:= ( SuperGetMV( "MV_NGMNTMS",,'N') == 'S' )//-- Ativa integracao TMS X MNT.
Local cArquivo
Local lR5			:= GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao		:= Val(GetVersao(.F.))     // Indica a versao do Protheus
Local lExeIntTms	:= ((nVersao == 11 .And. lR5) .Or. nVersao > 11) //-- Verificação de Release .5 do Protheus 11
Local cSerDesp		:= ( SuperGetMV('MV_SERDESP',,'' ) )  
Local lRepManu    := (GetNewPar("MV_RPCXMN","2")== "1")

Private aFolTms		:= {}
Private aFolTmsBkp	:= {}
Private cLote			:= ""
Private aDiario		:= {}
Private cCaixa   		:= SEU->EU_CAIXA

//***Posicionar no registro do SEU***
If ( FindFunction( "UsaSeqCor" ) .And. UsaSeqCor() ) 
	cCodDiario := SEU->EU_DIACTB
	AADD(aDiario,{"SEU",SEU->(recno()),cCodDiario,"EU_NODIA","EU_DIACTB"})
Endif 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravacao dos lancamentos do SIGAPCO                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PcoDetLan("000359","02","FINA560")
dbSelectArea("SET")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza saldo do caixinha                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nSldAtu := ET_SALDO - SEU->EU_VALOR
RecLock("SET",.F.)
REPLACE ET_SALDO WITH nSldAtu
//MsUnlock()     // Mantem bloqueado - lancamento modo Grid

If FindFunction( "FXMultSld()" ) .AND. FXMultSld()
	AtuSalCxa( ET_CODIGO, dDataBase, SEU->EU_VALOR * -1 )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravacao dos lancamentos do SIGAPCO                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PcoDetLan("000359","01","FINA560")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ contabilizacao do movimento                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lPadrao572 .and. lGeraLanc
	If nHdlPrv <= 0
		LoteCont("FIN")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa Lancamento Contabil                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nHdlPrv := HeadProva( cLote,;
			                      "FINA560" /*cPrograma*/,;
			                      Substr( cUsuario, 7, 6 ),;
			                      @cArquivo )
	Endif
	If  nHdlPrv > 0 .And. Empty(SEU->EU_LA)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Prepara Lancamento Contabil                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil 
				aAdd( aFlagCTB, {"EU_LA", "S", "SEU", SEU->( Recno() ), 0, 0, 0} )
			Endif
			nTotal += DetProva( nHdlPrv,;
			                    "572" /*cPadrao*/,;
			                    "FINA560" /*cPrograma*/,;
			                    cLote,;
			                    /*nLinha*/,;
			                    /*lExecuta*/,;
			                    /*cCriterio*/,;
			                    /*lRateio*/,;
			                    /*cChaveBusca*/,;
			                    /*aCT5*/,;
			                    /*lPosiciona*/,;
			                    @aFlagCTB,;
			                    /*aTabRecOri*/,;
			                    /*aDadosProva*/ )
	Endif

	If nHdlPrv > 0 .And. nTotal > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetiva Lan‡amento Contabil                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RodaProva( nHdlPrv,;
			           nTotal )                               
			If cA100Incl( cArquivo,;
				           nHdlPrv,;
				           3 /*nOpcx*/,;
				           cLote,;
				           lDigita,;
				           lAglutina /*lAglut*/,;
				           /*cOnLine*/,;
				           /*dData*/,;
				           /*dReproc*/,;
				           @aFlagCTB,;
				           /*aDadosProva*/,;
				           aDiario )
					If !lUsaflag
						Reclock("SEU",.F.)
						Replace EU_LA	With "S"
						MsUnLock()
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Gravacao dos lancamentos do SIGAPCO                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PcoDetLan("000359","02","FINA560")
			Endif		
			aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada F560REP              							³
//³ Destina-se a permitir ou nao as reposicoes. O retorno sera logi-³
//³ co, sendo .T. permite a reposicao ou .F. em caso contrario. 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("F560REP")
	lF560Rep := ExecBlock("F560REP",.F.,.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o saldo ficou negativo ou      ³
//³ atingiu o limite de reposicao              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea('SET')
lExecMsg := If(lFa550MSG,ExecBlock("Fa550MSG",.F.,.F.),.T.)
If lF560Rep .and. ((nSldAtu < 0) .Or.;
	Iif( ET_TPREP=="0", (ET_VALOR - nSldAtu > ET_LIMREP),;
	((1-nSldAtu/ET_VALOR)*100 > ET_LIMREP) ))
	If ExistBlock("FA550VERIF",.T.) .And. Fa550Verif()
		If Fa550VlUsr(SET->ET_CODIGO,__CUSERID)
			If lExecMsg
				If MsgYesNo(OemToAnsi(STR0019),OemToAnsi(STR0020))
					// "Deseja fazer a reposicao agora? ","Valor limite de reposicao atingido"
					If lRepManu
				       A550BcRep(cCaixa)
				       nVlrRep := Fa550Repor( ET_CODIGO,.T.,.T.,.T.) // Baixa e repoe  
				   	Else    
				       nVlrRep := Fa550Repor( ET_CODIGO,.T.,.T.,.T.) // Baixa e repoe  
				   	Endif
				Endif
			Endif
		Else
			MsgAlert(OemToAnsi(STR0020))
		Endif
	Else
		If lExecMsg
			If MsgYesNo(OemToAnsi(STR0019),OemToAnsi(STR0020))
				// "Deseja fazer a reposicao agora? ","Valor limite de reposicao atingido"
				If lRepManu
				   FA550BcRep(cCaixa)
				   nVlrRep := Fa550Repor( ET_CODIGO,.T.,.T.,.T.) // Baixa e repoe  
				Else    
				   nVlrRep := Fa550Repor( ET_CODIGO,.T.,.T.,.T.) // Baixa e repoe  
				Endif
			Endif
		Endif
	EndIf
Endif

If cPaisLoc <> "BRA" .And. SET->(FieldPos('ET_NRREND')) > 0 .And. SEU->(FieldPos('EU_NRREND')) > 0

	DbSelectArea('SET')
	DbSetOrder(1)
	MsSeek(xFilial()+SEU->EU_CAIXA)
	RecLock('SET',.F.)
	Replace ET_NRREND WITH SEU->EU_NRREND
    //MsUnlock()     // Mantem bloqueado - lancamento modo Grid

	PcoDetLan("000359","01","FINA550")		

Endif

If IntTMS() .And. nModulo == 43  
	If (!Empty(SEU->EU_CODVEI) .And. !Empty(SEU->EU_CODDES) .And. ;
					Posicione("DA3",1,xFilial("DA3")+SEU->EU_CODVEI,"DA3_FROVEI") == StrZero(1,Len(DA3->DA3_FROVEI)));																								
					.Or. ( !Empty(SEU->EU_FILORI) .And. !Empty(SEU->EU_VIAGEM) .And. !Empty(SEU->EU_CODDES))			
		// Grava o Custo de Transporte
		TMA250GrvSDG("SEU",SEU->EU_FILORI,SEU->EU_VIAGEM,SEU->EU_CODDES,SEU->EU_VALOR,1,SEU->EU_CODVEI,,,,,,,SEU->EU_NUM)
	EndIf
	If lExeIntTms //So executar integracao no Release .5 da versao 11 ou versao posterior
		If lMntTms			
			// Grava Os e Finalizada a mesma.
			TmsMntGrOs('2',cSerDesp,aFolTms,aFolTmsBkp)
		EndIf
		aFolTms		:= {}
		aFolTmsBkp	:= {}
	EndIf	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FA560TOK  ºAutor  ³Leonardo Castroº    Data ³  07/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação de saldo na confirmação de inclusão              º±±
±±º          ³  de movimento do caixinha.                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Financeiro - Caixinha                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
                                                           
Function FA560TOK()
       
Local lRet := .F.

DbSelectArea("SET")
SET->(DbSetOrder(1))
If DbSeek(xFilial("SET")+M->EU_CAIXA)
	If Obrigatorio(aGets,aTela) .AND. F560VerPE() .And. PcoVldLan('000359','02','FINA560') .And. F560VldApr()
		If M->EU_VALOR < SET->ET_SALDO
			lRet := .T.
		Else
		    CriaHlp()
		    Help(" ",1,"FA560SLD")
		EndIf	
    EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CriaHlp º Autor ³ Leonardo Castro    º Data ³   23/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cria mensagens de help ou help de campos necessario        º±±
±±º          ³ para rotina Movimentos do caixinha.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Financeiro - Caixinha                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CriaHlp()

Local aHelpPor := {}   
Local aHelpSpa := {}
Local aHelpEng := {}
		
aHelpPor	:=	{ "Saldo do caixinha alterado." }
aHelpEng    :=  { "Petty cash balance changed." }
aHelpSpa    :=  { "Se modificó el saldo del caja ","chica." }

PutHelp( "PFA560SLD", aHelpPor, aHelpEng, aHelpSpa, .F. )

aHelpPor	:=	{ "Verificar o novo saldo do caixinha"," e tentar novamente." }
aHelpEng    :=  { "Check new balance of petty cash" ," and try again." }
aHelpSpa    :=  { "Verificar el nuevo saldo del caja"," chica e intentar nuevamente." }

PutHelp( "SFA560SLD", aHelpPor, aHelpEng, aHelpSpa, .F. )

Return Nil


//SIGAFIN X SIGAPFS

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Fin560When

Verificacao de possibilidade de edicao dos campos do caixinha criados para a integracao 
Sigafin x SigaPFS

@author    Mauricio Pequim Jr
@version   11.80
@since     12/03/13

@param cCampo	- Código do Campo a ser verificado

@return ExpL1 = Confirma a possibilidade de edição do campo (When)

/*/
//-----------------------------------------------------------------------------------------------------
Function Fin560When(cCampo)

Local lRet		:= .F.
Local lCXJurFin	:= If(FindFunction("FVldJurxFin"),FVldJurxFin(),.F.)
Local lPrestCta := IsInCallStack("Fa560Adian")
Local cTpMov	:= ""
Local cDespJur	:= ""
Local cFatJur	:= ""
Local cNatureza := ""
Local cRatJur 	:= ""
Local lNatureza := .F.

Default cCampo := ""

If !Empty(cCampo)

	If lPrestCta	//Na prestacao de contas de adiantamento nao tenho os campos de memoria	
		cTpMov		:= SEU->EU_TIPO
		cDespJur	:= SEU->EU_DESPJUR
		cFatJur		:= GDFieldGet( "EU_FATJUR", n, .F., aHeader, aCols )
		cNatureza	:= GDFieldGet( "EU_NATUREZ", n, .F., aHeader, aCols )
		cRatJur 	:= "2"
	Else 		
		cTpMov		:= M->EU_TIPO
		cDespJur	:= M->EU_DESPJUR
		cFatJur		:= M->EU_FATJUR
		cNatureza	:= M->EU_NATUREZ
		cRatJur 	:= M->EU_RATJUR
	Endif

	If lCXJurFin
		If Alltrim(cCampo) $ "EU_DESPJUR"
			lRet := .T.
	
		ElseIf cDespJur == '1'
			If !Empty(cNatureza)
				SED->(DbSetOrder(1))
				If SED->(MsSeek(xFilial("SED")+cNatureza))
					lNatureza := .T.
				Endif
			Endif

			If cTpMov == '00' //Despesa
				If Alltrim(cCampo) $ "EU_RATJUR|EU_TIPDESP|EU_PROFISS|EU_NATUREZ"
					lRet := .T.
					

			    //Caso nao seja feito o rateio juridico, os campos abaixo podem ser habilitados.
			    //Caso contrario, somente na tela de rateio.
				ElseIf cRatJur == '2'

					If Alltrim(cCampo) $ "EU_MEMDSCR|EU_FATJUR"
						lRet := .T.
                    Endif
                    
					If cFatJur == '1'
						If Alltrim(cCampo) $ "EU_CLIENTE|EU_LOJACLI|EU_CASO"
							lRet := .T.
						Endif
					ElseIf cFatJur == '2' .and. lNatureza
						If Alltrim(cCampo) == "EU_ESCRIT" .and. SED->ED_ESCRIT == '1'
							lRet := .T.
						ElseIf Alltrim(cCampo) == "EU_GRPJUR" .and. SED->ED_GRPJUR == '1'
							lRet := .T.
						Endif	
					Endif
        		Endif
			ElseIf cTpMov == '01' //Adiantamento
				If lPrestCta
					If Alltrim(cCampo) $ "EU_TIPDESP|EU_PROFISS|EU_NATUREZ"
						lRet := .T.
	
				    //Caso nao seja feito o rateio juridico, os campos abaixo podem ser habilitados.
				    //Caso contrario, somente na tela de rateio.
					ElseIf cRatJur == '2'
	
						If Alltrim(cCampo) $ "EU_MEMDSCR|EU_FATJUR"
							lRet := .T.
	                    Endif
	                    
						If cFatJur == '1'
							If Alltrim(cCampo) $ "EU_CLIENTE|EU_LOJACLI|EU_CASO"
								lRet := .T.
							Endif
						ElseIf cFatJur == '2' .and. lNatureza
							If Alltrim(cCampo) == "EU_ESCRIT" .and. SED->ED_ESCRIT == '1'
								lRet := .T.
							ElseIf Alltrim(cCampo) == "EU_GRPJUR" .and. SED->ED_GRPJUR == '1'
								lRet := .T.
							Endif	
						Endif
	        		Endif
	
				Else
					If Alltrim(cCampo) $ "EU_PROFISS"
						lRet := .T.
					Endif
				Endif
			Endif
		Endif
	Endif
Endif

Return lRet


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F560TudoOk

Verificacao TudoOk da tela de inclusão de movimentos do caixinha

@author    Mauricio Pequim Jr
@version   11.80
@since     12/03/13

@param aGets
@param aTela

@return ExpL1 = Retorno lógico para as validações realizadas

/*/
//-----------------------------------------------------------------------------------------------------

Function F560TudoOk(aGets,aTela)

Local lRet		:= .F.
Local cTpMov	:= ""
Local cDespJur	:= ""
Local cFatJur	:= ""
Local cNatureza	:= ""
Local cRateio	:= ""
Local lCXJurFin	:= If(FindFunction("FVldJurxFin"),FVldJurxFin(),.F.)

//Validacao padrao (existente anteriormente)
If Obrigatorio(aGets,aTela) .And. F560VerPE() .And. PcoVldLan('000359','02','FINA560') .And. F560VldApr()
	lRet := .T.

	//Validacao especifica para integracao caixinha Financeiro x SigaPFS
	If lCXJurFin

		cTpMov		:= M->EU_TIPO
		cDespJur	:= M->EU_DESPJUR
		cFatJur		:= M->EU_FATJUR
		cNatureza	:= M->EU_NATUREZ 
		cRateio		:= M->EU_RATJUR

		If cDespJur == '1'

			//Movimento de Despesa	
			If cTpMov == '00'
				If Empty(M->EU_PROFISS) .OR. Empty(M->EU_TIPDESP) .OR. Empty(M->EU_NATUREZA)
					Help(" ",1,"F560DJUR0",,STR0109 +CRLF+STR0091+CRLF+STR0092+CRLF+STR0108,1,0) ///"Quando se tratar de um movimento do caixinha para integração com o SIGAPFS, os seguintes campos são obrigatórios:"
					lRet := .F.						 	 	 	
				Endif
	
                If lRet
					If cFatJur == '1' 
						If Empty(M->EU_CLIENTE) .OR. Empty(M->EU_LOJACLI) .OR. Empty(M->EU_CASO)
							Help(" ",1,"F560DJUR1",,STR0093+CRLF+STR0094+CRLF+STR0095+CRLF+STR0096,1,0) //'Quando a despesa juridica for reembolsável do cliente, é obrigatório o preenchimento dos campos abaixo:'###'Cliente Jur.'###'Loja Cliente'###'Caso'
							lRet := .F.						 	 	 	
						Endif
					ElseIf cRateio == '2' .and. !(Empty(cNatureza))
		
						SED->(dbSetOrder(1))
						If MsSeek(xFilial("SED")+cNatureza)
							If SED->ED_ESCRIT == '1'
								If Empty(M->EU_ESCRIT)		
									Help(" ",1,"F560DJUR2",,STR0097+CRLF+STR0098,1,0)		//'Devido a configuração da Natureza o campo abaixo tem seu preenchimento como obrigatório.'###'Escritório'
									lRet := .F.
			                    ElseIf SED->ED_GRPJUR == '1' .and. Empty(M->EU_GRPJUR)
									Help(" ",1,"F560DJUR3",,STR0097+CRLF+STR0099,1,0)	//'Devido a configuração da Natureza o campo abaixo tem seu preenchimento como obrigatório.'###'Grupo Jurid.'
									lRet := .F.
								Endif
							Endif
						Endif
					Endif
				Endif
						
				If lRet
					//Se a despesa nao vai ser cobrada do cliente, limpo os campos de Cliente, Loja e Caso
					If cFatJur == '2' .and. (!Empty(M->EU_CLIENTE) .OR. !Empty(M->EU_LOJACLI) .OR. !Empty(M->EU_CASO))
						M->EU_CLIENTE := ""
						M->EU_LOJACLI := ""
						M->EU_CASO    := ""
					Endif
					
					//Se a despesa vai ser cobrada do cliente, limpo os campos de escritorio e grupo juridico
					If cFatJur == '1' .and. (!Empty(M->EU_ESCRIT) .OR. !Empty(M->EU_GRPJUR))
						M->EU_ESCRIT := ""				
						M->ED_GRPJUR := ""
					Endif
				Endif
		
			//Movimento de Adiantamento
			ElseIf cTpMov == '01'
				If Empty(M->EU_PROFISS)		
					Help(" ",1,"F560DJUR4",,STR0100+CRLF+STR0091,1,0)	//'Devido o tipo de movimento ser de Adiantamento e tratar-se de uma despesa juridica, o campo abaixo tem seu preenchimento como obrigatório.'###'Prof.Favorec'
					lRet := .F.
				Else
					M->EU_CLIENTE := ""
					M->EU_LOJACLI := ""
					M->EU_CASO    := ""
					M->EU_ESCRIT  := ""				
					M->ED_GRPJUR  := ""
				Endif		
			Endif			
		Endif
	Endif
Endif	

Return lRet


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FIN560IDSP

Inicializador padrao do campo EU_DESPJUR (Despesa juridica)

@author    Mauricio Pequim Jr
@version   11.80
@since     12/03/13

@return ExpC1 = Retorna o inicializador padrao do campo EU_DESPJUR (Despesa juridica)

/*/
//-----------------------------------------------------------------------------------------------------
Function FIN560IDSP()

Local cRelDspJur := '2'
Local lCXJurFin	:= If(FindFunction("FVldJurxFin"),FVldJurxFin(),.F.)

If lCxJurFin
	cRelDspJur := '1'
Endif

Return cRelDspJur
		

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FIN560Cli

Verificacao a existencia de Cliente/Loja

@author    Mauricio Pequim Jr
@version   11.80
@since     12/03/13

@param cCliente	- Código do Cliente
@param cLoja	- Código da Loja do Cliente

@return ExpL1 = Confirma a existencia de Cliente/Loja

/*/
//-----------------------------------------------------------------------------------------------------
Function FIN560Cli (cCliente,cLoja)

Local lRet := .F.
Local aAreaSA1 := SA1->(GetArea())

DEFAULT cCliente := ""
DEFAULT cLoja := ""

If !Empty(cCliente)
	SA1->(dbSetOrder(1))
	If SA1->(MsSeek(xFilial("SA1")+cCliente+cLoja))
		Fin560Caso('EU_CLIENTE')
		lRet := .T.
	Endif
Endif
RestArea(aAreaSA1)
Return lRet


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Fin560Rd0

Validaç]ão do campo EU_PROFISS

@author    Mauricio Pequim Jr
@version   11.80
@since     12/03/13

@return ExpL1 = Retorno lógico para as validações realizadas

/*/
//-----------------------------------------------------------------------------------------------------

Function Fin560Rd0(cCodigo)

Local lRet	:= .F.

DEFAULT cCodigo := ""

RD0->(dbSetOrder(9))

If !Empty(cCodigo) .and. RD0->(MsSeek(xFilial("RD0")+cCodigo)) .and. Empty(RD0->RD0_DTADEM)
	lRet := .T.
Else
	Help(" ",1,"F560PRFJUR",,STR0101+CRLF+STR0102,1,0)	//'Código do profissional favorecido inválido.'###'Verifique o cadastro de participantes.'
Endif

Return lRet
	
//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Fin560Caso

Validaç]ão do campo EU_CASO

@author    Mauricio Pequim Jr
@version   11.80
@since     12/03/13

@return ExpL1 = Retorno lógico para as validações realizadas

/*/
//-----------------------------------------------------------------------------------------------------

Function Fin560Caso(cCampo)

Local cNumCaso := SuperGetMV('MV_JCASO1',,'1')
Local aArea    := GetArea()
Local aAreaNVE := NVE->(GetArea())
Local aAreaSA1 := SA1->(GetArea())
Local aCliLoj  := {}    
Local lRet 	   := .T.	
Local lPrestCta := IsInCallStack("Fa560Adian")
Local cCaso		:= ""
Local cCliente	:= ""
Local cLojaCli	:= ""

DEFAULT cCampo := 'EU_CASO'

If nTamCaso == NIL
	nTamCaso := TamSx3("NVE_NUMCAS")[1]
Endif

cCaso 	 := If (lPrestCta .and. cCampo != 'EU_CASO'   , GDFieldGet( 'EU_CASO'   , n, .F., aHeader, aCols ), M->EU_CASO    )
cCliente := If (lPrestCta .and. cCampo != 'EU_CLIENTE', GDFieldGet( 'EU_CLIENTE', n, .F., aHeader, aCols ), M->EU_CLIENTE )
cLojaCli := If (lPrestCta .and. cCampo != 'EU_LOJACLI', GDFieldGet( 'EU_LOJACLI', n, .F., aHeader, aCols ), M->EU_LOJACLI )

If cCampo == "EU_CASO" .AND. !Empty( cCaso )

	If cNumCaso == '2'  //Numero do caso nao se repete para os clientes

		aCliLoj := F560CasoAtual(cCaso)

		If	!Empty(aCliLoj)
			If lPrestCta
				GDFieldPut('EU_CLIENTE',aCliLoj[1][1],n)			
				GDFieldPut('EU_LOJACLI',aCliLoj[1][2],n)							       
			Else
				M->EU_CLIENTE := aCliLoj[1][1]
				M->EU_LOJACLI := aCliLoj[1][2]
			Endif
		Endif
	Else				//Numero do caso se repete para os clientes

		If !Empty(cCliente) .AND. !Empty(cLojaCli)
			lRet := ExistCpo('NVE',cCliente+cLojaCli+cCaso,1,,.F.)  
			If !lRet
				Help(" ",1,"F560CASO1",,STR0103,1,0)	//"Preenchimento de Cliente / Loja / Caso inválido. Por favor, verifique."
			EndIf	
		Endif
	EndIF

ElseIf cCampo == "EU_CLIENTE"
		
	If !Empty(cCliente) .AND. !Empty(cLojaCli)

		If !Empty(cCaso)
			lRet := ExistCpo('NVE',cCliente+cLojaCli+cCaso,1,,.F.)  
			If !lRet 
				Help(" ",1,"F560CASO2",,STR0103,1,0)	//"Preenchimento de Cliente / Loja / Caso inválido. Por favor, verifique!"
			EndIf	
		EndIf
	EndIf
	
EndIf

RestArea( aAreaNVE )
RestArea( aAreaSA1 )
RestArea( aArea )

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F560CasoAtual
Função para buscar o cliente/loja/caso atual tratando a questão de casos em andamento/remanejados 
quando o parametro "MV_JCASO1" for igual a 2 (Sequencia de caso independente do cliente).

@author Mauricio Pequim Jr
@since 15/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function F560CasoAtual(cCaso)

Local aRet    := {}
Local cQuery  := ""
Local aCasos  := {}
Local nI      := 0   
Local cQuery1 := ""
Local aNY1    := {}  
Local cClien  := ""
Local cLoja   := ""

Default cCaso := ""

If !Empty(cCaso)

	cQuery := "SELECT NVE.NVE_CCLIEN, NVE.NVE_LCLIEN, NVE.NVE_NUMCAS, NVE.NVE_SITUAC, NVE.R_E_C_N_O_ NVERECNO"
	cQuery += " FROM "+RetSqlName("NVE")+" NVE "
	cQuery += " WHERE NVE.NVE_FILIAL = '" + xFilial( "NVE" ) + "'"
	cQuery += " AND NVE.NVE_NUMCAS = '" + cCaso + "'"
	cQuery += " AND D_E_L_E_T_ = '' "

	aCasos := JurSQL(cQuery, {"NVE_CCLIEN", "NVE_LCLIEN", "NVE_NUMCAS", "NVE_SITUAC", "NVERECNO"})

	If Len(aCasos) == 1
		aAdd(aRet,{aCasos[1][1], aCasos[1][2]}) 
	ElseIf Len(aCasos) > 1
		For nI := 1 to len(aCasos)   
			If aCasos[nI][4] == "1" 
				aAdd(aRet,{aCasos[nI][1], aCasos[nI][2]}) 
				Exit				
			EndIf
		Next nI	
		
		If Empty(aRet)
			cQuery1 := "SELECT NY1_CCLIEN, NY1_CLOJA, NY1_SEQ"
			cQuery1 += " FROM "+RetSqlName("NY1")+" NY1 "
			cQuery1 += " WHERE NY1.NY1_FILIAL = '" + xFilial( "NY1" ) + "'"
			cQuery1 += " AND NY1.NY1_CCASO = '" + cCaso + "'"
			cQuery1 += " AND D_E_L_E_T_ = '' "
			cQuery1 += " ORDER BY NY1_SEQ "
  
			aNY1 := JurSQL(cQuery1, {"NY1_CCLIEN", "NY1_CLOJA", "NY1_SEQ"}) 
			
			If !Empty(aNY1)
				For nI := 1 to len(aNY1)   
					cClien := aNY1[nI][1]
					cLoja  := aNY1[nI][2]
				Next nI	 
				
				aAdd(aRet, JurGetDdTB("NVE",1,xFilial("NVE")+cClien+cLoja+cCaso,{"NVE_CCLINV", "NVE_CLJNV"}))
								
			EndIf
						
		EndIf
	EndIf
Endif

	
Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F560CanDel
Função para verificar se é possivel excluir o movimento do caixinha
caso o mesmo seja referente a uma integração Caixinha x Juridico

@author Mauricio Pequim Jr
@since 27/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function F560CanDel()

Local lRet := .T.
Local aArea := GetArea()

If SEU->EU_DESPJUR == '1'

	If !Empty(SEU->EU_SEQJUR)
		aDesp := GetAdvFVal("NVY",{"NVY_SITUAC", "NVY_CPREFT"},xFilial("NVY")+SEU->EU_SEQJUR,1,{"",""})
		If (aDesp[1] == '2'  .Or. !Empty(aDesp[2]))
			lRet := .F.
		EndIf

	ElseIf SEU->EU_RATJUR == '1'
		//busco o rateio na FJ4 e verifico se um deles foi faturado	
		dbSelectArea("FJ4")
		FJ4->(DbSetOrder(1))	
		
		If FJ4->(MsSeek(xfilial("FJ4")+SEU->EU_NUM))
			While !Eof() .and. xfilial("FJ4")+SEU->EU_NUM == FJ4->(FJ4_FILIAL+FJ4_NUM)
				aDesp := GetAdvFVal("NVY",{"NVY_SITUAC", "NVY_CPREFT"},xFilial("NVY")+SEU->EU_SEQJUR,1,{"",""})
				If (aDesp[1] == '2'  .Or. !Empty(aDesp[2]))
					lRet := .F.
					Exit
				EndIf
				FJ4->(dbSkip())
			Enddo
		Endif
	Endif
Endif

RestArea(aArea)	

Return lRet		


//-------------------------------------------------------------------
/*/{Protheus.doc} F560CanDel
Função para excluir os registros das tabelas FJ4 e NVY referentes a 
uma integração Caixinha x Juridico

@author Mauricio Pequim Jr
@since 27/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function F560DelJur(cNroAdia,cSeqJur)

Local aRecFJ4 := {}
Local aArea := GetArea()
Local nX := 0

DEFAULT cNroAdia := ""
DEFAULT cSeqJur	 := ""

If !Empty(cNroAdia)

	//Despesa juridica sem rateio
	If !Empty(cSeqJur)
		ExcluiPFS(cSeqJur)
	Else

		//Despesa juridica com rateio
		dbSelectArea("FJ4")
		FJ4->(DbSetOrder(1))	
		
		If FJ4->(MsSeek(xfilial("FJ4")+cNroAdia))
			While !Eof() .and. xfilial("FJ4")+cNroAdia == FJ4->(FJ4_FILIAL+FJ4_NUM)
				aadd(aRecFJ4,FJ4->(RECNO()))
				If !Empty(FJ4->FJ4_SEQJUR)
					ExcluiPFS(FJ4->FJ4_SEQJUR)
				Endif
				FJ4->(dbSkip()) 
			Enddo
		Endif

		If Len(aRecFJ4) > 0
			For nX := 1 to Len(aRecFJ4)
				FJ4->(DbGoto(aRecFJ4[nX]))
				Reclock('FJ4')
				DbDelete()
				MsUnlock()
			Next			
		Endif

	Endif
				 			
Endif

RestArea(aArea)

Return
