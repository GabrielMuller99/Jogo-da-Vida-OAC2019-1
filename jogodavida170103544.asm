.macro SALVA_ENDERECO	
	addi sp, sp, -4	# aloca espaço na pilha	
	sw ra, 0(sp)	# e salva o endereço de retorno
.end_macro

.macro RETORNA_ENDERECO
	lw ra, 0(sp)	# recupera o endereco de retorno
	addi sp, sp, 4	# e recupera o espaço liberado na pilha
.end_macro

.macro SALVA(%reg)
     addi sp, sp, -4	# aloca espaço na pilha
     sw %reg, 0(sp)	# e salva o endereço de retorno
.end_macro

.macro RETORNA(%reg)
     lw %reg, 0(sp)	# recupera o endereco de retorno
     addi sp, sp, 4	# e recupera o espaço liberado na pilha
.end_macro

.data 
matrizA: .space 324	 # matriz que salva o input inicial do usuario
matrizB: .space 324	 # matriz que eh usada ao longo do codigo
mensagem1: .asciz "Quantas bacterias gostaria de colocar?\n"
mensagem2: .asciz "Digite a coordenada de x\n"
mensagem3: .asciz "Digite a coordenada de y\n"

.text
	call zerar_matriz	# funcao que zera as matrizes
	call input_usuario	# funcao que pega os inputs do usuario
	
main_loop:	call plotm	# imprime a matriz
		
		li a0, 400	#
		li a7, 32	# faz com que tenha um delay entre as impressoes das matrizes
		ecall		#
		
		call scan_mat	# funcao que percorre a matrizB, descobre se eh 0 ou 1 e faz as determinadas comparacoes e passando o resultado para a matrizA
		call copia_mat	# funcao que copia a matrizA para a matrizB
		j main_loop	# da loop para o programa continuar
	
zerar_matriz:	li a0, 17	# coloca i = 17 da matriz 18x18
		li a1, 18	# coloca j = 18 da matriz 18x18
		la t0, matrizA	# pega o endereco da matriz A
		la t2, matrizB	# pega o endereço da matriz B
		li t1, '0'	# coloca o digito 0 no registrador t1
		
		zerar_matriz_i:	beq a1, x0, zerar_matriz_j	# compara se j == 0, entao vai para a proxima funcao
				
				sb t1, 0(t0)	# coloca 0 no endereco atual da matrizA
				sb t1, 0(t2)	# coloca 0 no endereco atual da matrizB
		
				addi a1, a1, -1	# decrementa a j
				addi t0, t0, 1	# vai para o proximo endereco da matrizA
				addi t2, t2, 1	# vai para o proximo endereco da matrizB
				
				j zerar_matriz_i # loop
		
		zerar_matriz_j:	beq a0, x0, retorno	# compara se i == 0, entao vai para a proxima funcao
		
				li a1, 18	 # reseta o j
				addi, a0, a0, -1 # decrementa o i

				j zerar_matriz_i # volta para zerar_matriz_i
		
retorno: ret	# retorna para onde a funcao que chamou essa foi chamada

plotm: 	li a0, 15		# coloca i = 15 da matriz 16x16
	li a1, 16		# coloca j = 16 da matriz 16x16
	la t0, matrizA		# pega o endereco da matriz A
	li t1, 0x00003000	# pega o endereco inicial do bitmap display
	li t2, '0' 		# coloca o digito 0 no registrador t2
	li t4, 0xFFFFFFFF	# coloca a cor branca no registrador t4
	li t5, 0x00000000	# coloca a cor preta no registrador t5
	addi t0, t0, 19		# incrementa o t0 para chegar no endereco correto da matriz
	
	plotmat:	beq a1, x0, plotmatloop	# compara se j == 0, entao vai para a proxima funcao
				
			lb t3, 0(t0)	# carrega no t3 o byte que esta na primeira posicao da matriz que sera impressa no bitmap
			
			bne t3, t2, plotmat1 # se for 0 vai para plotmat0 e se for diferente de 0 vai para plotmat1
			
			j plotmat0	# pula para plotmat0
		
			plotmat1:	sw t4, 0(t1)	# pinta de branco o bitmap
	
					addi a1, a1, -1	# decrementa a j
					addi t0, t0, 1	# vai para o proximo endereco da matrizA
					addi t1, t1, 4	# vai para o proximo endereco do bitmap
			
					j plotmat	# retorna para plotmat
		
			plotmat0:	sw t5, 0(t1)	# pinta de preto o bitmap
					
					addi a1, a1, -1	# decrementa a j
					addi t0, t0, 1	# vai para o proximo endereco da matrizA
					addi t1, t1, 4	# vai para o proximo endereco do bitmap
			
					j plotmat	# retorna para plotmat
			
			
	plotmatloop:	beq a0, x0, retorno	# compara se i == 0, entao vai para a proxima funcao
		
			li a1, 16	 # reseta o j
			addi, a0, a0, -1 # decrementa o i
			addi t0, t0, 2	 # vai para a proxima linha do bitmap

			j plotmat	 # volta para plotmat
	
write:	mv a0, s1		# pega o valor da coordenada x e faz i = x
	mv a1, s2		# pega o valor da coordenada y e faz j = y
	la a2, matrizA		# pega o endereco da matriz A
	li t2, '0' 		# coloca o digito 0 no registrador t2
	li t3, '1'		# coloca o digito 1 no registrador t3
	li t4, 18		# coloca a quantidade de colunas no t4
	addi a2, a2, 19		# incrementa o a2 para chegar no endereco correto da matriz
	
	mul t5, a0, t4		#
	add a2, a2, t5		# calculo que descobre a posicao na matriz, nesse caso a2[i][j]
	add a2, a2, a1		#
	
	lb t6, 0(a2)		# salva o valor da matriz em t6
	
	beq t6, t2, write1	# se for igual a 0, pula pra funcao que inverte o 0 pra 1
	
	sb t2, 0(a2)		# inverte de 1 para 0
	
	j ret_write		# pula pro final da funcao
	  
	write1:	sb t3, 0(a2)	# inverte o 0 para 1
			
	ret_write: ret		# retorna para onde write foi chamada
	
readm:	mv a0, s1		# pega o valor da coordenada x e faz i = x
	mv a1, s2		# pega o valor da coordenada y e faz j = y
	la a2, matrizA		# pega o endereco da matriz A
	li t4, 18		# coloca a quantidade de colunas no t4
	addi a2, a2, 19		# incrementa o a2 para chegar no endereco correto da matriz
	
	mul t5, a0, t4		#
	add a2, a2, t5		# calculo que descobre a posicao na matriz, nesse caso a2[i][j]
	add a2, a2, a1		#
	
	lb a1, 0(a2)		# salva o valor da matriz em a1
	
	ret 			# retorna com o valor que foi salvo em a1
	
copia_mat:	la t0, matrizA	# pega o endereco da matriz A
		la t1, matrizB	# pega o endereço da matriz B
		li a0, 17	# coloca i = 17 da matriz 18x18
		li a1, 18	# coloca j = 18 da matriz 18x18
		
		copia_matriz:	beq a1, x0, copia_matloop	# compara se j == 0, entao vai para a proxima funcao
		
				lb t2, 0(t0)	# carrega o valor que esta nesse endereco na matrizA
				sb t2, 0(t1)	# copia o valor que estava na matrizA para a matrizB
				
				addi a1, a1, -1	# decrementa o j
				addi t0, t0, 1	# pula para o proximo espaco da memoria da matrizA
				addi t1, t1, 1	# pula para o proximo espaco da memoria da matrizB
				
				j copia_matriz	# loop
				
		copia_matloop:  beq a0, x0, final_copia	# compara se i == 0, entao vai para a proxima funcao
		
				li a1, 18	 # reseta o j
				addi, a0, a0, -1 # decrementa o i

				j copia_matriz 	 # volta para copia_matriz
				
		final_copia: 	ret	# retorna para onde foi chamada
				
input_usuario:	la a0, mensagem1 #
		li a7, 4	 # imprime a mensagem1
		ecall		 #
		
		li a7, 5	 #
		ecall		 # pega o valor de quantas bacterias que o usuario digitou e coloca em s0
		mv s0, a0	 #
		
		input_loop:	beq s0, x0, final_input	# o loop acontecera s0 vezes
				
				la a0, mensagem2	#
				li a7, 4		# imprime a mensagem2
				ecall			#
				
				li a7, 5		#
				ecall			# pega o valor da coordenada x que o usuario colocou
				mv s1, a0		#
				
				la a0, mensagem3	#
				li a7, 4		# imprime a mensagem3
				ecall			#
				
				li a7, 5		#
				ecall			# pega o valor da coordenada y que o usuario colocou
				mv s2, a0		#
				
				addi s0, s0, -1		# decrementa o s0
				
				SALVA_ENDERECO		# macro que salva o endereco de retono

				call write		# chama a funcao que troca os 0's e 1's de acordo com as coordenadas dadas pelo usuario
					
				RETORNA_ENDERECO	# macro que recupera o endereco de retorno			
														
				j input_loop		# loop
				
		final_input: ret	# retorna a funcao para onde ela foi chamada 

vizinhos:	li t0, 2		# t0 sera usado para pular as linhas da matriz das celulas vizinhas da celula que foi escaneada
		li t1, 3		# t1 sera usado para percorrer as linhas da matriz das celulas vizinhas da celula que foi escaneada
		li t2, '1'		# t2 recebe o '1' para fazer comparacoes e incrementar o contador
		li t4, 0		# t4 sera o contador
		addi a3, a3, -19	# incrementa o a3 para chegar no endereco correto da matriz
		
		vizinho_lp:	beq t1, x0, vizinho_loop	# enquanto t1 for diferente de 0, a funcao ficara em loop
				
				lb t3, 0(a3)			# carrega o elemento salvo nesse endereco de a3
				
				bne t3, t2, decrementa		# se t3 for 1, ele continua, caso seja 0, pula pra decrementa
				
				addi t4, t4, 1			# t4 = t4 + 1
				
				decrementa:	addi t1, t1, -1	# decrementa t1
						addi a3, a3, 1	# pula para o proximo endereco
						
						j vizinho_lp	# faz loop na funcao vizinho_lp
					
		vizinho_loop:	beq t0, x0, fim_vizinho		# enquanto t0 for diferente de 0, volta para vizinho_lp
					
				addi a3, a3, 15			# pula de linha na matriz 3x3
				addi t0, t0, -1			# decrementa t0
				addi t1, t1, 3			# devolve o valor original de t1
		
				j vizinho_lp			# pula de volta pra vizinho_lp

		fim_vizinho:	mv a0, t4	# pega o valor do contador t4 e passa para a0
				ret		# retorna o a0 para onde vizinhos foi chamado

scan_mat:	la a2, matrizA		# carrega o endereco da matrizA
		la a3, matrizB		# carrega o endereco da matrizB
		li t1, 15		# t1 sera usado para pular as linhas das matrizes
		li t2, 16		# t2 sera usado para percorrer as linhas das matrizes
		li s2, '1'		# s2 recebe o '1' para fazer comparacoes 
		li s3, '0'		# s3 recebe o '0' para fazer comparacoes
		addi a2, a2, 19		# incrementa o a2 para chegar no endereco correto da matrizA
		addi a3, a3, 19		# incrementa o a3 para chegar no endereco correto da matrizB
		
		scan_matriz:	beq t2, x0, scan_matriz_loop	# comparacao que faz com que seja percorrido as linhas das matrizes
		
				lb t0, 0(a3)		# carrega o valor que esta nesse endereco da matrizB
				
				SALVA_ENDERECO		#
				SALVA(t0)		#
				SALVA(t1)		# salva todos os valores que estao nesses registradores numa pilha
				SALVA(t2)		# para serem recuperados apos a chamada da funcao vizinhos
				SALVA(a2)		#
				SALVA(a3)		#
				
				jal vizinhos		# chama a funcao vizinhos
				
				RETORNA(a3)		#
				RETORNA(a2)		#
				RETORNA(t2)		# recupera todos os valores que estavam salvos na pilha e coloca de volta
				RETORNA(t1)		# nesses registradores
				RETORNA(t0)		#
				RETORNA_ENDERECO	#
				
				li t4, 3		# carrega estes dois registradores para fazerem as 
				li t5, 2		# comparacoes de sobrevivencia, nascimento e morte
				
				bne t0, s2, nascimento	# se o que estiver em t0 for 0, ele pula para nascimento, se nao, continua
				
				addi a0, a0, -1		# se for 1 em t0, o contador tera um a mais, assim eh necessario diminuir 1
				
				blt a0, t5, morte	# se 2 > a0 > 3
				bgt a0, t4, morte	# ele pula para morte
				
				sobrevive:	sb t0, 0(a2)	# coloca neste endereco da matrizA o mesmo valor que esta na matrizB
				
						j loop		# pula para loop
				
				morte:	sb s3, 0(a2)		# coloca neste endereco da matrizA o 0
					
					j loop			# pula para loop
				
				nascimento:	beq a0, t4, nasce	# se o valor em a0 for igual a t4 vai para nasce
						
						j loop		# pula para loop
						
						nasce:	sb s2, 0(a2)	# coloca neste endereco da matrizA o 1
					
				loop:		addi t2, t2, -1	# decrementa o t2 para continuar a funcao
						addi a2, a2, 1	# pula para o proximo endereco da matrizA
						addi a3, a3, 1	# pula para o proximo endereco da matrizB
						
						j scan_matriz	# faz o loop da funcao
				
		scan_matriz_loop:	beq t1, x0, fim_scan	# enquanto t1 nao for 0, a funcao scan_matriz continuara num loop
					
					li t2, 16	# devolve o valor original de t2
					addi t1, t1, -1	# decrementa o t1
					addi a2, a2, 2	# pula a linha da matrizA
					addi a3, a3, 2	# pula a linha da matrizB
					
					j scan_matriz	# volta para scan_matriz
					
		fim_scan:	ret	# retorna para onde a funcao foi chamada
