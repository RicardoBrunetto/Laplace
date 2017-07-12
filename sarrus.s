.section .data

mensagemInicial:      .asciz    "%s* Trabalho 01 - Resolutor de Sistemas Lineares de 3 variáveis \t*%s"
mensagemTchau:        .asciz    "\nTchau Tchau!\n"
mensagemMostrar:      .asciz    "\tMatriz atual:\n"
mensagemSistema:      .asciz    "\tSistema Linear:\n"

mostrarX_i:           .asciz    "\n\t=>\tx_%d = %d\n"
mostrarResultado:     .asciz    "\nDeterminante Dx_: %d"
mostrarResultado_D:   .asciz    "\n\n\n=>\tDeterminante Principal: %d\n"

spi_res:              .asciz     "\n%s\tSISTEMA IMPOSSÍVEL | POSSÍVEL E INDETERMINADO%s\n"
VALEDI:                 .asciz     "\n(edi): %d\n"
OFFSET:               .asciz      "\nEAX(OFFSET): %d\tEBX(LINHA): %d\t ECX(COLUNA): %d\n"
MOVED:                .asciz    "\nMOVED: %d (%d bytes)"
executar_Novamente:   .asciz    "\n\nDeseja executar novamente?\n<s>im | <n>ão\n"

divisoria:            .asciz    "\n-----------------------------------------------------------------\n"

author:   .asciz    "Autor:\nRicardo Henrique Brunetto\t-\tRA: 94182\n"
input_f:  .asciz    "%s*\tA inserção das linhas é do seguinte formato:\t\t*\n*\tcn*x_n + ... + c2*x_2 + c1*x_1 = res_n\t\t\t*\n*\t\t\t\t\t\t\t\t*\n*\tOnde será solicitado o coeficiente de cada x_i\t\t*%s"

pedirLn:    .asciz    "\n---------- Equação (Linha da Matriz) %d ----------\n"
pedirXn:    .asciz    "\nInforme o coeficiente de x_%d: "
pedirRes:   .asciz    "\nInforme o resultado da equação %d: "

limpabuf:       .string   "%*c"
mostrar_coef:   .asciz    "%dx_%d %s"
plus_signal:    .asciz    "+ "
eq_signal:      .asciz    "= "

mostrar_elem:   .asciz  "%d\t"
formatoString:  .asciz  "%s"
formatoChar:    .asciz  "%c"
formatoNum:     .asciz  "%d"
pulaLinha:      .asciz  "\n"

matriz:       .int      0
matriz_aux:   .int      0
contadorLn:   .int      0
contadorEq:   .int      0
N:            .int      3
det_valor:    .int      0

det_D:        .int      0

contador_Cramer:  .int  0
atual_index:      .int  0

return_add1:  .int      0
return_add2:  .int      0
return_add3:  .int      0
return_addJ:  .int      0
resp:         .int      0

.section .text

msg_inicial:
  pushl $divisoria
  pushl $divisoria
  pushl $mensagemInicial
  call printf
  pushl $author
  call printf
  pushl $divisoria
  pushl $divisoria
  pushl $input_f
  call printf
  addl $28, %esp
ret


# Pré-Condição:
#   Linha está em %ebx
#   Coluna está em %ecx
#   Endereço incial da matriz está no topo da pilha
# Pós-Condição:
#   Avança i+j posições na matriz %edi
# Registradores Alterados:
#   %edi %eax %ecx
matricial_linear:
  popl return_add1
   # Nesse momento, %edi deve estar no topo da pilha
   movl $1, %eax
   decl %ebx
   mull %ebx
   mull N
   addl %ecx, %eax
   decl %eax
   movl %eax, %ebx
   call pular # vai avançar %ebx + %ecx (i+j) campos

   pushl return_add1
ret

# Pré-Condição:
#   Endereço de memória no topo da pilha
# Pós-Condição:
#   Avança 4 bytes em %edi (%edi = %edi + 4) e o empilha
# Registradores Alterados:
#   %edi
proximo_campo:
  popl return_addJ

  popl %edi
  addl $4, %edi
  pushl %edi

  pushl return_addJ
ret

# Pré-Condição:
#   Endereço de memória no topo da pilha
#   Quantidade de bytes em %ebx
# Pós-Condição:
#   Avança %ebx bytes em %edi (%edi = %edi + 4x%ebx) e o empilha
# Registradores Alterados:
#   %edi  %eax  (%ebx é salvo e recuperado - não altera)
pular:
  popl return_addJ

  popl %edi
  pushl %ebx

  movl %ebx, %eax
  movl $4, %ebx
  mull %ebx   # faz eax * 4 (%ebx * 4)

  addl %eax, %edi

  popl %ebx
  pushl %edi

  pushl return_addJ
ret

# Pré-Condição:
#   Endereço da matriz principal em %edi
# Pós-Condição:
#   Preenche a matriz %edi (N x N+1)
# Registradores Alterados:
#   %edi  %ecx
ler_dados:
  popl return_add1 # guarda o endereço de retorno
  movl matriz, %edi # coloca o endereço inicial da matriz em %edi
  pushl %edi # coloca %edi na pilha
  movl N, %ecx # quantidade de vezes que o loop_dados vai executar

  loop_ler_dados:
    movl %ecx, contadorLn # faz backup do valor de ecx (contador)

    pushl %ecx
    push $pedirLn
    call printf
    addl $8, %esp

    call ler_equacao

    movl contadorLn, %ecx
    loop loop_ler_dados

    pushl return_add1 # empilha o endereço de retorno
    ret
    # Supoe que o bloco de memória está em %edi
    ler_equacao:
      popl return_add2 # deixa %edi no topo da pilha / guarda o endereço de retorno
      movl N, %ecx

      loop_ler_equacao:
        movl %ecx, contadorEq # faz backup do valor de ecx (contador)

        pushl contadorEq
        pushl $pedirXn
        call printf
        addl $8, %esp

        # %edi está na pilha
        pushl $formatoNum
        call scanf
        addl $4, %esp

        call proximo_campo

        movl contadorEq, %ecx
        loop loop_ler_equacao

        # Acabaram os coeficientes de xn. Pede o resultado da equação.
        pushl contadorLn
        pushl $pedirRes
        call printf
        addl $8, %esp

        pushl $formatoNum
        call scanf
        addl $4, %esp

        call proximo_campo # deixa %edi pronto para a proxima linha

      pushl return_add2
ret

# Pré-Condição:
#   Ordem da matriz está em %eax (linhas) e %ebx (colunas)
# Pós-Condição:
#   Endereço do primeiro elemento da nova matriz em %edi
# Registradores Alterados:
#   %eax  %ecx
alocar_matriz:
  movl $4, %ecx
  mull %ebx # multiplica %eax x %ebx
  mull %ecx # 4 x (%eax x %ebx), pois 1 inteiro ocupa 4 bytes

  movl %eax, %ecx
  pushl %ecx
  call malloc
  addl $4, %esp # desempilha %ecx
  movl %eax, %edi
ret


# Pré-Condição:
#   Endereço do primeiro elemento da matriz em %edi
# Pós-Condição:
#   Mostra o sistema linear na tela
# Registradores Alterados:
#   %ecx  %edi
mostrar_sistema:
  pushl $divisoria
  call printf
  pushl $mensagemSistema
  call printf
  addl $8, %esp

  popl return_add1 # guarda o endereço de retorno
  # addl $8, %esp
  movl N, %ecx # quantidade de vezes que o loop_dados vai executar

  loop_mostrar_sistema:
    movl %ecx, contadorLn # faz backup do valor de ecx (contador)

    push $pulaLinha
    call printf
    addl $4, %esp

    call mostrar_equacao

    movl contadorLn, %ecx
    loop loop_mostrar_sistema

    pushl $divisoria
    call printf
    addl $4, %esp
    pushl return_add1 # empilha o endereço de retorno
    ret

    mostrar_equacao:
      popl return_add2 # deixa %edi no topo da pilha / guarda o endereço de retorno
      movl N, %ecx
      incl %ecx # mostrar os n+1 inteiros

      loop_mostrar_equacao:
        movl %ecx, contadorEq # faz backup do valor de ecx (contador)

        pushl %eax
        pushl %ebx
        pushl %ecx
        pushl %edx

        cmpl $1, %ecx
        je printar_result
        cmpl $2, %ecx
        je printar_ultimo_coef

        printar_coef:
          pushl $plus_signal
          jmp sequencia_print
        printar_ultimo_coef:
          pushl $eq_signal
          jmp sequencia_print
        printar_result:
          pushl (%edi)
          pushl $mostrar_elem
          call printf
          addl $8, %esp
          jmp fim_print
        sequencia_print:
          decl %ecx
          pushl %ecx
          pushl (%edi)
          pushl $mostrar_coef
          call printf
          addl $16, %esp
        fim_print:

        popl %edx
        popl %ecx
        popl %ebx
        popl %eax

        addl $4, %edi

        movl contadorEq, %ecx
        loop loop_mostrar_equacao

        pushl return_add2
ret

# Pré-Condição:
#   Endereço do primeiro elemento da matriz em %edi
# Pós-Condição:
#   O determinante da matriz somado à variável det_valor
# Registradores Alterados:
#   %eax %ebx %ecx %edx %edi %esi
determinante:
  movl $0, det_valor # zera o determinante atual
  pushl %edi # Guarda o endereço da matriz atual
  # já está em a11
  movl (%edi), %eax # %eax = a11

  pushl %eax # guarda eax atual
  pushl 4(%esp) # empilha %edi para ser avançado
  movl $2, %ebx
  movl $2, %ecx
  call matricial_linear # vai para o elemento [2][2]
  popl %edi # recupera %edi já avançado
  popl %eax # recupera o produto atual
  imull (%edi) # %eax = produto anterior * elemento atual


  pushl %eax # guarda eax atual
  pushl 4(%esp) # empilha %edi para ser avançado
  movl $3, %ebx
  movl $3, %ecx
  call matricial_linear # vai para o elemento [3][3]
  popl %edi # recupera %edi já avançado
  popl %eax # recupera o produto atual
  imull (%edi) # %eax = produto anterior * elemento atual


  addl %eax, det_valor # det_valor = det_atual + (a11*a22*a33)
  movl $1, %eax # reseta eax (nova parcela será calculada)


  pushl %eax # guarda eax atual
  pushl 4(%esp) # empilha %edi para ser avançado
  movl $1, %ebx
  movl $2, %ecx
  call matricial_linear # vai para o elemento [1][2]
  popl %edi # recupera %edi já avançado
  popl %eax # recupera o produto atual
  imull (%edi) # %eax = produto anterior * elemento atual

  pushl %eax # guarda eax atual
  pushl 4(%esp) # empilha %edi para ser avançado
  movl $2, %ebx
  movl $3, %ecx
  call matricial_linear # vai para o elemento [2][3]
  popl %edi # recupera %edi já avançado
  popl %eax # recupera o produto atual
  imull (%edi) # %eax = produto anterior * elemento atual

  pushl %eax # guarda eax atual
  pushl 4(%esp) # empilha %edi para ser avançado
  movl $3, %ebx
  movl $1, %ecx
  call matricial_linear # vai para o elemento [3][1]
  popl %edi # recupera %edi já avançado
  popl %eax # recupera o produto atual
  imull (%edi) # %eax = produto anterior * elemento atual


  addl %eax, det_valor # det_valor = det_atual + (a12*a23*a31)
  movl $1, %eax # reseta eax (nova parcela será calculada)


  pushl %eax # guarda eax atual
  pushl 4(%esp) # empilha %edi para ser avançado
  movl $1, %ebx
  movl $3, %ecx
  call matricial_linear # vai para o elemento [1][3]
  popl %edi # recupera %edi já avançado
  popl %eax # recupera o produto atual
  imull (%edi) # %eax = produto anterior * elemento atual

  pushl %eax # guarda eax atual
  pushl 4(%esp) # empilha %edi para ser avançado
  movl $2, %ebx
  movl $1, %ecx
  call matricial_linear # vai para o elemento [2][1]
  popl %edi # recupera %edi já avançado
  popl %eax # recupera o produto atual
  imull (%edi) # %eax = produto anterior * elemento atual

  pushl %eax # guarda eax atual
  pushl 4(%esp) # empilha %edi para ser avançado
  movl $3, %ebx
  movl $2, %ecx
  call matricial_linear # vai para o elemento [3][2]
  popl %edi # recupera %edi já avançado
  popl %eax # recupera o produto atual
  imull (%edi) # %eax = produto anterior * elemento atual


  addl %eax, det_valor # det_valor = det_atual + (a13*a21*a32)
  movl $-1, %eax # reseta eax (nova parcela será calculada) -1 pois é diagonal secundária


  pushl %eax # guarda eax atual
  pushl 4(%esp) # empilha %edi para ser avançado
  movl $1, %ebx
  movl $3, %ecx
  call matricial_linear # vai para o elemento [1][3]
  popl %edi # recupera %edi já avançado
  popl %eax # recupera o produto atual
  imull (%edi) # %eax = produto anterior * elemento atual

  pushl %eax # guarda eax atual
  pushl 4(%esp) # empilha %edi para ser avançado
  movl $2, %ebx
  movl $2, %ecx
  call matricial_linear # vai para o elemento [2][2]
  popl %edi # recupera %edi já avançado
  popl %eax # recupera o produto atual
  imull (%edi) # %eax = produto anterior * elemento atual

  pushl %eax # guarda eax atual
  pushl 4(%esp) # empilha %edi para ser avançado
  movl $3, %ebx
  movl $1, %ecx
  call matricial_linear # vai para o elemento [3][1]
  popl %edi # recupera %edi já avançado
  popl %eax # recupera o produto atual
  imull (%edi) # %eax = produto anterior * elemento atual


  addl %eax, det_valor # det_valor = det_atual + (a13*a22*a31)
  movl $-1, %eax # reseta eax (nova parcela será calculada) -1 pois é diagonal secundária


  pushl %eax # guarda eax atual
  pushl 4(%esp) # empilha %edi para ser avançado
  movl $1, %ebx
  movl $1, %ecx
  call matricial_linear # vai para o elemento [2][3]
  popl %edi # recupera %edi já avançado
  popl %eax # recupera o produto atual
  imull (%edi) # %eax = produto anterior * elemento atual

  pushl %eax # guarda eax atual
  pushl 4(%esp) # empilha %edi para ser avançado
  movl $2, %ebx
  movl $3, %ecx
  call matricial_linear # vai para o elemento [2][3]
  popl %edi # recupera %edi já avançado
  popl %eax # recupera o produto atual
  imull (%edi) # %eax = produto anterior * elemento atual

  pushl %eax # guarda eax atual
  pushl 4(%esp) # empilha %edi para ser avançado
  movl $3, %ebx
  movl $2, %ecx
  call matricial_linear # vai para o elemento [3][2]
  popl %edi # recupera %edi já avançado
  popl %eax # recupera o produto atual
  imull (%edi) # %eax = produto anterior * elemento atual


  addl %eax, det_valor # det_valor = det_atual + (a11*a23*a32)
  movl $-1, %eax # reseta eax (nova parcela será calculada) -1 pois é diagonal secundária


  pushl %eax # guarda eax atual
  pushl 4(%esp) # empilha %edi para ser avançado
  movl $1, %ebx
  movl $2, %ecx
  call matricial_linear # vai para o elemento [1][2]
  popl %edi # recupera %edi já avançado
  popl %eax # recupera o produto atual
  imull (%edi) # %eax = produto anterior * elemento atual

  pushl %eax # guarda eax atual
  pushl 4(%esp) # empilha %edi para ser avançado
  movl $2, %ebx
  movl $1, %ecx
  call matricial_linear # vai para o elemento [2][1]
  popl %edi # recupera %edi já avançado
  popl %eax # recupera o produto atual
  imull (%edi) # %eax = produto anterior * elemento atual

  pushl %eax # guarda eax atual
  pushl 4(%esp) # empilha %edi para ser avançado
  movl $3, %ebx
  movl $3, %ecx
  call matricial_linear # vai para o elemento [3][3]
  popl %edi # recupera %edi já avançado
  popl %eax # recupera o produto atual
  imull (%edi) # %eax = produto anterior * elemento atual


  addl %eax, det_valor # det_valor = det_atual + (a13*a21*a33)
  popl %edi
ret

# Pré-Condição:
#   Endereço da matriz auxiliar já alocada está em %esi
# Pós-Condição:
#   Matriz sem a última coluna está em %esi
# Registradores Alterados:
#   %edi %esi %ecx
gerar_matriz_sem_z:
  movl N, %ecx # quantidade de vezes que o loop_dados vai executar
  movl matriz, %edi # move o endereço da matriz principal para %edi

  loop_gerar_matriz_sem_z:
    movl %ecx, contadorLn # faz backup do valor de ecx (contador)

    call linha_gerar_matriz_sem_z

    # %edi estará em um elemnto [k][N] e deve-se pular o elemento [k][N+1]
    addl $4, %edi # pula para o proximmo elemento de %edi

    movl contadorLn, %ecx
    loop loop_gerar_matriz_sem_z

    ret
    linha_gerar_matriz_sem_z:
      movl N, %ecx

      loop_linha_gerar_matriz_sem_z:
        movl %ecx, contadorEq # faz backup do valor de ecx (contador)

        movl  (%edi), %eax
        movl  %eax, (%esi) # copia o elemento para a posição atual em %esi

        addl $4, %esi # move para o proximo espaço em %esi
        addl $4, %edi # move para o proximo espaço em %edi

        movl contadorEq, %ecx
        loop loop_linha_gerar_matriz_sem_z
ret

# Pré-Condição:
#   Endereço da matriz auxiliar já alocada está em %esi
#   Endereço da matriz principal está em %edi
#   Índice da coluna está em %ebx
# Pós-Condição:
#   Matriz de %esi receberá a última coluna de %edi na coluna de índice %ebx
# Registradores Alterados:
#   (%edi, %esi, %ebx, %ecx e %eax são salvos - não alteram)
copiar_ultima_coluna:
  pushl %ecx # salva %ecx
  pushl %eax # salva %eax
  pushl %ebx # salva %ebx
  pushl %edi # salva a matriz principal
  pushl %esi # salva a matriz auxiliar

  decl %ebx # os deslocamentos são indexados em 0 enquanto as colunas são indexadas em 1 (deslocar 0 => coluna 1)
  movl N, %ecx # executará o loop N vezes (são N elementos)

  loop_copiar_ultima_coluna:
    pushl %edi # guarda a matriz principal
    pushl %esi # empilha %esi para ser avançado
    call pular # avança em %ebx-1 elementos (primeira iteração) ou N elementos (demais iterações)
    popl %esi # %esi recebe a matriz já no elemento correto
    # %edi com a matriz original está no topo da pilha
    movl N, %ebx # pula para a última coluna em %edi
    call pular
    popl %edi # recupera a matriz principal já avançada

    movl (%edi), %eax # copia o elemento
    movl %eax, (%esi)

    addl $4, %edi # a matriz principal tem uma linha a mais que deve ser considerada
  loop loop_copiar_ultima_coluna

  popl %esi # recupera a matriz principal
  popl %edi # recupera a matriz principal
  popl %ebx # recupera %ebx
  popl %eax # recupera %eax
  popl %ecx # recupera %ecx
ret

# Pré-Condição:
#   Endereço da matriz auxiliar já alocada está em %esi
#   Endereço da matriz principal está em %edi
#   Índice da coluna está em %ebx
# Pós-Condição:
#   Matriz de %esi receberá a última coluna de %edi na coluna de índice %ebx
# Registradores Alterados:
#   (%edi, %esi, %ebx, %ecx e %eax são salvos - não alteram)
resolver_sistema:
  movl $1, atual_index
  movl N, %ecx

  loop_resolver_sistema:
    movl %ecx, contador_Cramer
    movl N, %eax
    movl N, %ebx
    call alocar_matriz
    movl %edi, matriz_aux
    movl matriz_aux, %esi

    call gerar_matriz_sem_z
    jmp pular_fim

    # Não faz um loop tão grande, teve de se quebrar a execução
    continuar:
      movl contador_Cramer, %ecx
      loop loop_resolver_sistema
      jmp fim_resolver_sistema
    pular_fim:

    movl matriz_aux, %esi
    movl matriz, %edi
    movl atual_index, %ebx
    call copiar_ultima_coluna
    incl %ebx
    movl %ebx, atual_index
    # calcular o determinante da matriz com a coluna %ebx subsituída pela última coluna da MP
    movl matriz_aux, %edi
    movl N, %ebx

    movl $0, det_valor

    call determinante

    movl det_valor, %eax
    cltd
    idivl det_D

    pushl %eax

    pushl det_valor
    pushl contador_Cramer
    pushl $mostrarResultado
    call printf
    addl $12, %esp

    popl %eax

    pushl %eax
    pushl contador_Cramer
    pushl $mostrarX_i
    call printf
    addl $12, %esp

    jmp continuar
    fim_resolver_sistema:
ret

.globl _start

_start:
  call msg_inicial
  jmp inicio_resolucao

# Inicia o procedimento
inicio_resolucao:
  movl $0, det_valor

  movl N, %eax
  movl N, %ebx
  incl %ebx
  call alocar_matriz
  movl %edi, matriz

  call ler_dados

  pushl %edi
  pushl %ebx
  movl matriz, %edi
  call mostrar_sistema
  popl %ebx
  popl %edi

  movl N, %eax
  movl N, %ebx
  call alocar_matriz
  movl %edi, matriz_aux
  movl matriz_aux, %esi

  call gerar_matriz_sem_z

  movl matriz_aux, %edi
  movl N, %ebx

  call determinante

  movl det_valor, %eax
  movl %eax, det_D    # guarda o determinante da matriz principal

  pushl %eax
  pushl %ebx
  pushl %ecx
  pushl %edx

  pushl det_D
  pushl $mostrarResultado_D
  call printf
  addl $8, %esp

  popl %edx
  popl %ecx
  popl %ebx
  popl %eax

  cmpl $0, det_D
  je sistema_spi

  call resolver_sistema
  jmp fim

  sistema_spi:
  pushl $divisoria
  pushl $divisoria
  pushl $spi_res
  call printf
  addl $12, %esp

  jmp fim

fim:
  pushl $executar_Novamente
  call printf
  pushl $limpabuf
  call scanf
  addl $8, %esp

  call getchar
  cmpl $'s', %eax
  jz inicio_resolucao

  pushl $mensagemTchau
  call printf
  addl $4, %esp

  pushl $0
  call exit




  # Pré-Condição:
  #   Endereço do primeiro elemento da matriz em %edi
  # Pós-Condição:
  #   Mostra a matriz na tela
  # Registradores Alterados:
  #   %ecx  %edi
  mostrar_matriz:
    pushl $divisoria
    call printf
    pushl $mensagemMostrar
    call printf
    addl $8, %esp

    popl return_add1 # guarda o endereço de retorno
    # addl $8, %esp
    movl N, %ecx # quantidade de vezes que o loop_dados vai executar

    loop_mostrar_matriz:
      movl %ecx, contadorLn # faz backup do valor de ecx (contador)

      push $pulaLinha
      call printf
      addl $4, %esp

      call mostrar_linha

      movl contadorLn, %ecx
      loop loop_mostrar_matriz

      pushl $divisoria
      call printf
      addl $4, %esp
      pushl return_add1 # empilha o endereço de retorno
      ret

      mostrar_linha:
        popl return_add2 # deixa %edi no topo da pilha / guarda o endereço de retorno
        movl N, %ecx
        incl %ecx # mostrar os n+1 inteiros

        loop_mostrar_linha:
          movl %ecx, contadorEq # faz backup do valor de ecx (contador)

          pushl %eax
          pushl %ebx
          pushl %ecx
          pushl %edx

          pushl (%edi)
          pushl $mostrar_elem
          call printf
          addl $8, %esp

          popl %edx
          popl %ecx
          popl %ebx
          popl %eax

          addl $4, %edi

          movl contadorEq, %ecx
          loop loop_mostrar_linha

          pushl return_add2
  ret
