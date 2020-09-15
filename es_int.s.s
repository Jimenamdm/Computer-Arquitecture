* Inicializaci?n del StackPointer y del PC:
		ORG $0
		DC.L $8000	*StackPointer
		DC.L INICIO	*PC
		ORG $400
		

	* Definicion de equivalencias:
	
		MR1A:	EQU	$EFFC01		* modo A (W)
		MR2A:	EQU	$EFFC01		* modo A (2?W)
		SRA:	EQU	$EFFC03		* estado A (R)
		CSRA:	EQU	$EFFC03		* selecci?n de reloj A (R)
		CRA:	EQU	$EFFC05		* control A (W)
		RBA:	EQU	$EFFC07		* buffer de recepcion A (R)
		TBA:	EQU	$EFFC07		* buffer de transmision A (R)
		ACR:	EQU	$EFFC09		* control auxiliar
		ISR:	    EQU	$EFFC0B		* estado de inerrupci?n (R)
		IMR:	    EQU	$EFFC0B		* m?scarade interrupci?n (W)
		MR1B:	EQU	$EFFC11		* modo B (W)
		MR2B:	EQU	$EFFC11		* modo B (2?W)
		SRB:	EQU	$EFFC13		* estado B (R)
		CSRB:	EQU	$EFFC13		* seleccion de reloj B (R)
		CRB:	EQU	$EFFC15		* control B (W)
		RBB:	EQU	$EFFC17		* buffer de recepcion B (R)
		TBB:	EQU	$EFFC17		* buffer de transmision B (R)
		IVR:	EQU	$EFFC19		* vector de interrupcion

	BUFFERS:
	*Definimos el tama?o del buffer
	TAM:	EQU	2001
	
		BUF_TA:	DS.B TAM	* Buffer de transmision A
		BUF_TB:	DS.B TAM	* Buffer de transmision B
		BUF_RA: DS.B TAM		* Buffer de recepcion A
		BUF_RB: DS.B TAM		* Buffer de recepcion B
		CPIMR: DS.B 1				*Copia IMR
		BUFFER: DC.B '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890',$0d
		CONT_BUC:	DC.L	0
		*BUFFER: DS.B    2100  * Buffer para lectura y escritura de caracteres
		CONTL:		DC.W	0 	* Contador de lineas
	CONTC:		DC.W	0 	* Contador de caracteres
	DIRLEC:		DC.L	0 	* Direccion lectura SCAN
	DIRESC:		DC.L	0 	* Direccion escritura PRINT
	TAME:		DC.W	101 	* Tamano escritura PRINT
	FLAGRTIA: DC.L 0	*Flag para RTI A
	FLAGRTIB: DC.L 0	*Flag para RTI B
	FLAGPRINT: DC.L 0	*Flag para PRINT
	DESA:		EQU	0 	* Descriptor linea A
	DESB:		EQU	1 	* Descriptor linea B
	NLIN:		EQU	2 	* Numero lineas a leer
	TAML:		EQU	101	* Tamano linea SCAN
	TAMB:		EQU	5 	* Tamano bloque PRINT

	* PUNTEROS:
	
		PTA_L:		DC.L 0			* Puntero de lectura del BUF_TA
		PTA_E:	DC.L 0			* Puntero de escritura del BUF_TA
		PTA_I:		DC.L 0			* Inicio del buffer BUF_TA
		
		PTB_L:		DC.L 0			* Puntero de lectura del BUF_TB
		PTB_E:	DC.L 0			* Puntero de escritura del BUF_TB
		PTB_I:		DC.L 0			* Inicio del buffer BUF_TB
		
		
		PRA_L:		DC.L 0			* Puntero de lectura del BUF_RA
		PRA_E:	DC.L 0			* Puntero de escritura del BUF_RA
		PRA_I:		DC.L 0			* Inicio del buffer BUF_RA	

		
		PRB_L:		DC.L 0			* Puntero de lectura del a BUF_RB
		PRB_E:	DC.L 0			* Puntero de escritura dele BUF_RB	
		PRB_I:		DC.L 0			* Inicio del buffer BUF_RB

INICIO: 
		BSR INIT
		MOVE.W #$2000,SR * Inhabilitas interrupciones interrupciones
		MOVE.W	#0,CONTC	* Inicializa contador de caracteres
		MOVE.W	#NLIN,CONTL	* Inicializa contador de lineas
		MOVE.L	#BUFFER,DIRLEC	* Direccion lectura = comienzo buffer

BUC20:		
		MOVE.W	#TAML,-(A7)	* Tamano maximo de linea
		MOVE.W	#DESB,-(A7)	* Puerto A
		MOVE.L	DIRLEC,-(A7)	* Direccion lectura

BUC21:		BSR 	SCAN
		CMP.L	#0,D0
		BEQ	BUC21		* Si no se ha leido una linea se intenta de nuevo
		ADD.L	#8,A7		* Restablece la pila
		ADD.L	D0,DIRLEC	* Calcula la nueva direccion de lectura
		ADD.W	D0,CONTC	* Actualiza el numero de caracteres leidos
		SUB.W	#1,CONTL	* Actualiza el numero de lineas leidas. Si no
		BNE	BUC20		* se han leido todas las lineas se vuelve a leer
		
		MOVE.L	#BUFFER,DIRLEC	* Direccion lectura = comienzo buffer
		MOVE.W	TAME,-(A7)	* Tamano maximo de linea
		MOVE.W	#DESB,-(A7)	* Puerto A
		MOVE.L	#BUFFER,-(A7)	* Direccion lectura
		BSR PRINT


		BREAK

	
			
			

				
	******************************************************************INIT********************************************************
		
	INIT:
		MOVE.B	#%00010000,CRA		* Reset puntero MRA1
		MOVE.B	#%00010000,CRB		* Reset puntero MRB1
		MOVE.B	#%00000011,MR1A		* 8bits por car?cter l?nea A, 1 interrupción por caracter
		MOVE.B	#%00000011,MR1B		* 8bits por car?cter l?nea B, 1 interrupción por caracter
		MOVE.B	#%00000000,MR2A		* Eco desactivado (accso al registro de modo A)
		MOVE.B	#%00000000,MR2B   	* Eco desactivado (acceso al registro de modo B)
		MOVE.B   #%11001100,CSRA	* Velocidad A = 38400bps
		MOVE.B   #%11001100,CSRB	* Velocidad B = 38400bps
		MOVE.B   #%00000000,ACR     * auxiliar, Seleccionamos velocidad conjunto 1 = 38400 bps
		MOVE.B   #%00000101,CRA		* Trans y Recep activados para A
		MOVE.B   #%00000101,CRB		* Trans y Recep activados para B
		MOVE.B   #$40,IVR			* Registro de Interrupciones
		
		MOVE.B #%00100010,CPIMR		* Copia del Registro de mascara de las interrupciones
		MOVE.B CPIMR,IMR
		MOVE.L #RTI,256				* Actualiza direccion RTI en la tabla de vectores
		
		MOVE.L #BUF_TA,PTA_L		*Puntero lectura transmisión de A
		MOVE.L #BUF_TA,PTA_E		*Puntero escritura transmisión de A
		MOVE.L #BUF_TA,PTA_I		*Puntero inicio transmisión de A
		
		MOVE.L #BUF_TB,PTB_L		*Puntero lectura transmisión de B
		MOVE.L #BUF_TB,PTB_E		*Puntero escritura transmisión de B
		MOVE.L #BUF_TB,PTB_I		*Puntero inicio transmisión de B
		
		MOVE.L #BUF_RA,PRA_L		*Puntero lectura recepción de A
		MOVE.L #BUF_RA,PRA_E		*Puntero escritura recepción de A
		MOVE.L #BUF_RA,PRA_I		*Puntero inicio recepción de A
		
		MOVE.L #BUF_RB,PRB_L		*Puntero lectura recepción de B
		MOVE.L #BUF_RB,PRB_E		*Puntero escritura recepción de B
		MOVE.L #BUF_RB,PRB_I		*Puntero inicio recepción de B
		
		RTS
		
******************************************************Busco Buffer************************************************

BUSC_BUFF:

		BTST #0,D0		*Comparamos el contenido del pimer bit de D0
		BEQ	LINEA_A	*Si es igual a 0 accedemos a la l?nea A
		BRA	LINEA_B	*Si es igual a 1 accedemos a la l?nea B
	
	LINEA_A:
		BTST	#1,D0		*Comparamos el contenido del segundo bit de D0
		BEQ	RECP_A	*Si es igual a 0 accedemos a BUF_RA
		BRA	TRANS_A	*Si es igual a 1 accedemos a BUF_TA

	LINEA_B:
		BTST	#1,D0		*Comparamos el contenido del segundo bit de D0
		BEQ	RECP_B   	*Si es igual a 0 accedemos a BUF_RB
		BRA	TRANS_B  	*Si es igual a 1 accedemos a BUF_TB

	RECP_A:
		MOVE.L	(PRA_L),A0	*Puntero de lectura
		MOVE.L	(PRA_I),A1	*Inicio del buffer
		MOVE.L   (PRA_E),A2   *Puntero de escritura
		RTS
		
	TRANS_A:
		MOVE.L	(PTA_L),A0	*Puntero de lectura
		MOVE.L	(PTA_I),A1	*Inicio del buffer
		MOVE.L   (PTA_E),A2   *Puntero de escritura
		RTS
		
	RECP_B:
		MOVE.L	(PRB_L),A0	*Puntero de lectura
		MOVE.L	(PRB_I),A1	*Inicio del buffer
		MOVE.L   (PRB_E),A2   *Puntero de escritura
		RTS
		
	TRANS_B:
		MOVE.L	(PTB_L),A0	*Puntero de lectura
		MOVE.L	(PTB_I),A1	*Inicio del buffer
		MOVE.L   (PTB_E),A2   *Puntero de escritura
		RTS
		
	*****************************************************************Actualiza Puntero******************************************************	
		
ACT_P_L:
		
		BTST #0,D0					*Comparamos el contenido del pimer bit de D0
		BEQ	PUN_AL				*Si es igual a 0 accedemos a la l?nea A
		BRA	PUN_BL				*Si es igual a 1 accedemos a la l?nea B
	
	PUN_AL:
		BTST	#1,D0				*Comparamos el contenido del segundo bit de D0
		BEQ	PU_RE_AL				*Si es igual a 0 accedemos a BUF_RA
		BRA	PU_TR_AL				*Si es igual a 1 accedemos a BUF_TA

	PUN_BL:
		BTST	#1,D0				*Comparamos el contenido del segundo bit de D0
		BEQ	PU_RE_BL   			*Si es igual a 0 accedemos a BUF_RB
		BRA	PU_TR_BL 			*Si es igual a 1 accedemos a BUF_TB
		
	PU_RE_AL:
		MOVE.L	A0,PRA_L		*Puntero de lectura
		RTS
		
	PU_TR_AL:
		MOVE.L	A0,PTA_L		*Puntero de lectura
		RTS
		
	PU_RE_BL:
		MOVE.L	A0,PRB_L		*Puntero de lectura
		RTS
		
	PU_TR_BL:
		MOVE.L	A0,PTB_L		*Puntero de lectura
		RTS
		
ACT_P_E:
		
		BTST #0,D0					*Comparamos el contenido del pimer bit de D0
		BEQ	PUN_AE					*Si es igual a 0 accedemos a la l?nea A
		BRA	PUN_BE					*Si es igual a 1 accedemos a la l?nea B
	
	PUN_AE:
		BTST	#1,D0				*Comparamos el contenido del segundo bit de D0
		BEQ	PU_RE_AE				*Si es igual a 0 accedemos a BUF_RA
		BRA	PU_TR_AE				*Si es igual a 1 accedemos a BUF_TA

	PUN_BE:
		BTST	#1,D0				*Comparamos el contenido del segundo bit de D0
		BEQ	PU_RE_BE   			*Si es igual a 0 accedemos a BUF_RB
		BRA	PU_TR_BE 			*Si es igual a 1 accedemos a BUF_TB
		
	PU_RE_AE:
		MOVE.L   A2,PRA_E   	*Puntero de escritura
		RTS
		
	PU_TR_AE:
		MOVE.L   A2,PTA_E   	*Puntero de escritura
		RTS
		
	PU_RE_BE:
		MOVE.L   A2,PRB_E  	*Puntero de escritura
		RTS
		
	PU_TR_BE:
		MOVE.L   A2,PTB_E   	*Puntero de escritura
		RTS
		
		
************************************************************LEECAR*****************************************************

LEECAR:	

		MOVEM.L A0-A3/D3,-(A7)

		BSR BUSC_BUFF 		*Buscamos a que buffer tenemos que acceder
		
		MOVE.L A1,A3

		CMP.L	A0,A2			*Comprobamos si apuntan a la misma posicion
		BEQ	VACIO_L				*Si apuntan a la misma posicion es que esta vacio
		MOVE.B	(A0),D3			*Guardamos la memoria de buffer en el registro D3
		ADD.L	#1,A0			*Avanzamos el puntero una posicion
		ADDA.L #2001,A1
		CMP.L	A1,A0			*Comprobamos si estamos al final del buffer
		BEQ	INICIO_L			*Si es asi movemos el puntero a la primera posicion
		BSR ACT_P_L
		MOVE.L D3,D0
		BRA FIN_LE
	
	INICIO_L:
		MOVE.L	A3,A0			*Movemos el puntero a la primera posicion
		BSR ACT_P_L
		MOVE.L D3,D0
		BRA	FIN_LE99
	
	VACIO_L:
		MOVE.L	#-1,D0			*Si esta vacio guardamos un -1 en D0
	
	FIN_LE:
		MOVEM.L (A7)+,A0-A3/D3
		RTS
		
	*******************************************************ESCCAR********************************************************		
		
ESCCAR:

		MOVEM.L A0-A3,-(A7)
		
		BSR BUSC_BUFF		*Buscamos aque buffer tenemos que acceder
		
		MOVE.L A1,A3
		ADDA.L #2000,A1
		CMP.L A1,A2
		BNE M_LLENO
		
		CMP.L	A3,A0			*Comprobamos si estamos al inicio del buffer
		BEQ	LLENO
		
	M_LLENO:
		MOVE.L A0,A4
		SUB.L #1,A4
		CMP.L A4,A2
		BEQ LLENO
				
		MOVE.B	D1,(A2)		*Guardo el caracter en el puntero de escritura
		ADD.L #1,A2				*Avanzamos el puntero una posicion
		ADDA.L #1,A1
		CMP.L A1,A2
		BEQ	INICIO_E			*Si es asi movemos el puntero a la primera posicion
		BSR ACT_P_E
		MOVE.L #0,D0			*Como la insercion se ha hecho correctamente guardamos un 0 en D0
		BRA	FIN_E

	LLENO:
		MOVE.L	#-1,D0 		*Si el buffer esta lleno, guardamos un -1 en D0
		BRA	FIN_E

	INICIO_E:
		MOVE.L	A3,A2		*Movemos el puntero a la primera posicion
		BSR ACT_P_E
		MOVE.L #0,D0			*Como la insercion se ha hecho correctamente guardamos un 0 en D0
		BRA	FIN_E
	
	FIN_E:							
		MOVEM.L (A7)+,A0-A3
		RTS
		
	*********************************************LINEA****************************************************	
		
	LINEA:
		MOVEM.L A0-A3/D4,-(A7)
		
		BSR BUSC_BUFF		*Buscamos a que buffer tenemos que acceder
		MOVE.L A1,A3
		ADDA.L #2001,A3
		
		MOVE.L #0,D4			*Creamos un contador para saber cuantos caracteres leemos
		
	BUC:
		CMP.L	A0,A2			*Comprobamos si apuntan a la misma posicion
		BEQ	VACIO_LI			*Si apuntan a la misma posicion es que esta vacio
		CMP.B #13,(A0)		*Comprobamos si ese caracter es un retorno de carro
		BEQ FIN_LIN			*Si es asi es que hemos llegado al final de la linea
		ADD.L #1,D4				*Si no, sumamos 1 al contador de caracteres leídos
		ADD.L #1,A0				*Pasamos a la siguiente posicion de A0
		CMP.L A3,A0			*Comprobamos si estamos al final del buffer
		BEQ FIN_BUF
		BRA BUC

	FIN_BUF:
		MOVE.L A1,A0			*Si estamos al final del buffer nos situamos en el inicio
		BRA BUC	
		
	VACIO_LI:
		MOVE.L #0,D0			*Si el buffer esta vacio devolvemos un 0
		BRA FIN_LI
		
	FIN_LIN:
		MOVE.L D4,D0			*Devolvemos el numero de caracteres leidos
		ADD.L #1,D0				*Le sumamos uno a los caracteres leidos por el retorno de carro
		
	FIN_LI:
		MOVEM.L (A7)+,A0-A3/D4
		RTS

		
	*****************************************************************SCAN****************************************************
	
	SCAN: 
		LINK A6,#0				*Creamos el marco de pila
		
		MOVE.W 12(A6),D0 		*Guardamos el puerto al que queremos acceder (Descriptor)
		CMP.W #0,D0				*Miramos si es un 0
		BEQ CORREC
		CMP.W #1,D0				*Miramos si es un 1
		BEQ CORREC
		MOVE.L #-1,D0			*Si ha habido algun error devolvemos -1 y terminamos
		BRA FIN_SCA
		
	CORREC:
		
		BSR LINEA				*Buscamos una linea
		
		CMP.L #0,D0				*Miramos si la subrutina LINEA nos ha devuelto un 0
		BEQ FIN_SCA
		MOVE.W 14(A6),D3        *Guardamos en D3 el tamaño
		CMP.L D3,D0				*Comprobamos si el tamaño es el adecuado  
		BHI FINC_SCA
		
		MOVE.L 8(A6),A1		 	*Guardamos la dirección del buffer en el que queremos devolver
		MOVE.L D0,D4			*Guardamos la longitud de la linea que servira como contador
		
	BUC_SCAN:
		CMP.L #0,D4 			*Miramos si ya hemos guardado todas las posiciones
		BEQ FINC_SCA			*Si es asi terminamos
		MOVE.W 12(A6),D0		*Si no guardamos el puerto y llamamos a LEECAR
		BSR LEECAR
		MOVE.B D0,(A1)+			*Guardamos el carcater en el buffer			
		ADD.L #1,D5				*Sumamos el contador de carcateres leidos e insertados   
		SUB.L #1,D4				*Restamos el contador de caracteres leidos
		BRA BUC_SCAN
		
	
	FINC_SCA:
		MOVE.L D5,D0			*Si ha ido bien devolvemos el numero de caracteres leidos e insertados y terminamos 
		
	FIN_SCA:
		CLR.L D3				*Vaciamos los registros y deshacemos el marco de pila
		CLR.L D4
		CLR.L D5
		UNLK A6
		RTS
		
	*******************************************************************PRINT************************************************	
	
	PRINT: 
		LINK A6,#0				*Creamos el marco de pila
			
		MOVE.W 12(A6),D2 		*Guardamos el puerto al que queremos acceder (Descriptor)
		CMP.W #0,D2  			*Miramos si es un 0
		BEQ PUERTO_A			*Si es asi seguimos por el puerto A
		CMP.W #1,D2				*Miramos si es un 1
		BEQ PUERTO_B			*Si es así seguimos por el puerto B
		MOVE.L #-1,D0			*Si ha habido algun error devolvemos -1 y terminamos
		BRA FIN_PRI				*Si no es 0 o 1 terminamos
		
	PUERTO_A:
		MOVE.L	#2,D6			*Indicamos el puerto en que queremos trabajar
		BRA SIG
		
	PUERTO_B:
		MOVE.L	#3,D6			*Indicamos el puerto en que queremos trabajar
		
	SIG:
		MOVE.L 8(A6),A1 		*Direccion de buffer de entrada
		MOVE.W 14(A6),D3	  	*Tamaño del buffer de entrada
		
	BUC_PRI:
		CMP.W #0,D3				*Miramos si ya hemos guardado todas las posiciones
		BEQ INTERR				*Si es asi terminamos
		MOVE.B (A1)+,D1			*Guardamos la posicion que queremos escribir
		MOVE.L D6,D0			*Guardamos el puerto al que queremos acceder
		BSR ESCCAR
		CMP.L #-1,D0			*Miramos si el buffer esta lleno
		BEQ FINC_PRI			*Si lo esta, terminamos
		ADD.L #1,D4				*Sumamos 1 a los caracteres leidos y escritos
		SUB.W #1,D3				*Restamos 1 al contador
		CMP.B #13,D1
		BNE BUC_PRI
		MOVE.B #1,FLAGPRINT
		BRA BUC_PRI
		
	INTERR:
		CMP.B #0,FLAGPRINT
		BEQ FINC_PRI
		MOVE.B #0,FLAGPRINT
		MOVE.W SR,D5			*Guardamos el registro de estado
		MOVE.W #$2700,SR		*Activamos las interrupciones
		CMP.W #0,D2				*Miramos si es un 0
		BEQ LINEA_AA			*Si es asi, tenemos que activar la linea A
		BSET #4,CPIMR			*Si no, activamos la linea B
		BRA COP_IMR	

	LINEA_AA:
		BSET #0,CPIMR			*Activamos la linea A
		
	COP_IMR:
		MOVE.B CPIMR,IMR		*Guardamos en el IMR real
		MOVE.W D5,SR			*Devolvemos al registro de estado el valor que tenia antes de la interrupcion	
		
	FINC_PRI:
		MOVE.L  D4,D0     		*Si ha ido bien devolvemos el numero de caracteres leidos e insertados y terminamos 
		
	FIN_PRI:
		CLR.L D2				*Vaciamos los registros y deshacemos el marco de pila
		CLR.L D3
		CLR.L D4
		CLR.L D6
		CLR.L D5
		UNLK A6	
		RTS
				
		
	***************************************************************************************RTI************************************************************************	
	
RTI: 
		MOVEM.L D0-D2,-(A7)
		
	VOL:
		MOVE.B ISR,D2			*Guardamos el puerto por el que va la interrupcion
		AND.B CPIMR,D2
		
		BTST #0,D2  				*Miramos si es un 0
		BNE TR_A					*Si lo es pasamos a transmision de A
		BTST #1,D2					*Miramos si es un 1
		BNE REC_A					*Si lo es pasamos a la recepcion de A
		BTST #4,D2					*Miramos si es un 4
		BNE TR_B					*Si lo es pasamos a la transmision de B
		BTST #5,D2					*Miramos si es un 5
		BNE REC_B					*Si lo es pasamos a la recepcion de B
		BRA FIN_RTI				*Si no es ninguno de los anteriores termino
		
		REC_A:
			MOVE.L #0,D0					*Guardamos el puerto por el que ha venido la interrupcion en D0
			MOVE.B RBA,D1				*Escribimos el caracter que queremos escribir en D1
			BSR ESCCAR					*Llamamos a ESCCAR para escribir el caracter
			BRA VOL							*Una vez escrito volvemos al principio
			
		REC_B:
			MOVE.L #1,D0					*Guardamos el puerto por el que ha venido la interrupcion en D0
			MOVE.B RBB,D1				*Escribimos el caracter que queremos escribir en D1	
			BSR ESCCAR					*Llamamos a ESCCAR para escribir el caracter
			BRA VOL							*Una vez escrito volvemos al principio
			
		TR_A:
			MOVE.L #2,D0					*Indicamos en D0 el puerto por el que ha venido la interrupción
			CMP.B #1,FLAGRTIA
			BEQ SLT_LINA						*Si es asi tratamos este caso
			BSR LEECAR
			MOVE.B D0,TBA					*Escribimos el carcater recibido en el puerto B	
			CMP.B #13,D0						*Miramos el caracter transmitido ha sido un retorno de carro
			BNE VOL								*Si no, inabilitamos las interrupciones
			MOVE.B #1,FLAGRTIA			*Si es asi, lo indicamos en nuestra variable
			BRA VOL
			
		TR_B:
			MOVE.L #3,D0						*Indicamos en D0 el puerto por el que ha venido la interrupción
			CMP.B #1,FLAGRTIB 			*Miramos si el retorno de carro es 1
			BEQ STL_LINB						*Si es asi tratamos este caso
			BSR LEECAR
			MOVE.B D0,TBB					*Escribimos el carcater recibido en el puerto B		
			CMP.B #13,D0						*Miramos el caracter transmitido ha sido un retorno de carro
			BNE VOL								*Si no, inabilitamos las interrupciones
			MOVE.B #1,FLAGRTIB			*Si es asi, lo indicamos en nuestra variable
			BRA VOL
			
		SLT_LINA:	
			MOVE.B #10,TBA					*Escribimos el salto de linea en en puerto A
			MOVE.L #2,D0						*Dejamos el registro D0 preparado para poder llamar a LEECAR cuando termine la subrutina
			MOVE.B #0,FLAGRTIA			*Ponemos a 0 nuestra variable que indica el retorno de carro
			BSR LINEA							*Se llama a linea para saber si hay mas lineas disponibles
			CMP.L #0,D0						*Si es así volvemos al principio
			BNE VOL
			BCLR #0,CPIMR			*Si no, se deshabilitan las interrupciones
			MOVE.B CPIMR,IMR
			BRA VOL
			
		STL_LINB:
			MOVE.B #10,TBB						*Escribimos el salto de linea en en puerto B
			MOVE.L #3,D0							*Dejamos el registro D0 preparado para poder llamar a LEECAR cuando termine la subrutina
			MOVE.B #0,FLAGRTIB				*Ponemos a 0 nuestra variable que indica el retorno de carro
			BSR LINEA								*Se llama a linea para saber si hay mas lineas disponibles
			CMP.L #0,D0							*Si es así volvemos al principio
			BNE VOL
			BCLR #4,CPIMR			*Si no, se deshabilitan las interrupciones
			MOVE.B CPIMR,IMR
			BRA VOL
			
		FIN_RTI:
			MOVE.B CPIMR,IMR
			MOVEM.L (A7)+,D0-D2
			RTE	
				
