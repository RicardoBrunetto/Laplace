.section .data

mensagemInicial:      .asciz    "%s* Trabalho 02 - Resolutor de Sistemas Lineares de N variáveis \t*%s"
mensagemTchau:        .asciz    "\nTchau Tchau!\n"
mensagemMostrar:      .asciz    "\tMatriz atual:\n"

mostrarX_i:           .asciz    "\n\t=>\tx%d = %d\n"
mostrarResultado:     .asciz    "\nDeterminante Dx%d: %d"
mostrarResultado_D:   .asciz    "\n\n\n=>\tDeterminante Principal: %d\n"

spi_res:              .asciz     "\n%s\tSISTEMA IMPOSSÍVEL | POSSÍVEL E INDETERMINADO%s\n"

divisoria:            .asciz    "\n-----------------------------------------------------------------\n"

author:   .asciz    "Autor:\nRicardo Henrique Brunetto\t-\tRA: 94182\n"
input_f:  .asciz    "%s*\tA inserção das linhas é do seguinte formato:\t\t*\n*\tcn*xn + ... + c2*x2 + c1*x1 = res_xn\t\t\t*\n*\t\t\t\t\t\t\t\t*\n*\tOnde será solicitado o coeficiente de cada xi\t\t*%s"

pedirN:     .asciz    "\nInforme a quantidade de variáveis (e equações):\t"

pedirLn:    .asciz    "\n---------- Equação (Linha da Matriz) %d ----------\n"
pedirXn:    .asciz    "\nInforme o coeficiente de x%d: "
pedirRes:   .asciz    "\nInforme o resultado da equação %d: "

mostrar_elem:   .asciz  "%d\t"
formatoString:  .asciz  "%s"
formatoChar:    .asciz  "%c"
formatoNum:     .asciz  "%d"
pulaLinha:      .asciz  "\n"

matriz:       .int      0
matriz_aux:   .int      0
contadorLn:   .int      0
contadorEq:   .int      0
N:            .int      0
indice_fcol:  .int      0
det_valor:    .int      0

det_D:        .int      0

contador_Cramer:  .int  0
atual_index:      .int  0

return_add1:  .int      0
return_add2:  .int      0
return_add3:  .int      0
return_addJ:  .int      0

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
#   %edi %eax
matricial_linear:
   # Nesse momento, %edi deve estar no topo da pilha
   addl %ebx, %ecx # soma as linhas + colunas a serem deslocadas
   movl %ecx, %eax # move para %eax
   call pular # vai avançar %ebx + %ecx (i+j) campos
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

ler_n:
  pushl $pedirN
  call printf
  addl $4, %esp

  pushl $N
  pushl $formatoNum
  call scanf
  addl $8, %esp
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

# Pré-Condição:
#   Endereço do primeiro elemento da matriz em %edi
#   Ordem da matriz em %ebx
# Pós-Condição:
#   O determinante da matriz somado à variável det_valor
# Registradores Alterados:
#   %eax %ebx %ecx %edx %edi %esi
determinante:
  pushl %edi # Guarda o endereço da matriz atual
  pushl %ebx

  cmpl $1, %ebx
  je ordem_1
  cmpl $2, %ebx
  je ordem_2

  # Para matrizes de ordem maior igual a 3 [endereço da matriz continua em %edi]
  # Aplica-se laplace
  ordem_maior_igual_3:
    movl %ebx, %ecx
    decl %ecx # considera N-1 de dimensão
    movl $4, %eax
    mull %ecx
    mull %ecx # 4x(N-1 x N-1)

    movl %ecx, %eax
    movl %ecx, %ebx
    call alocar_matriz

    movl %edi, %esi # A partir de agora, %esi tem o endereço do 1º elemento da matriz auxiliar (n-1 x n-1)

    movl $0, %ecx # Quantidade de colunas a serem fixadas

    loop_ordem_maior_igual_3:
      incl %ecx
      movl %ecx, indice_fcol

      movl (%esp), %ebx # recoloca a ordem da matriz atual em %ebx
      movl 4(%esp), %edi # %edi volta a ter o endereço da matriz atual

      pushl det_valor
      movl $0, det_valor

      pushl %ecx # salva a coluna fixada
      call submatriz # encontra a submatriz

      movl %esi, %edi # Agora %edi é a submatriz

      pushl %ecx
      popl %ecx

      decl %ebx # %ebx contém a ordem da submatriz (sempre n-1)

      pushl %edi # empilha a matriz auxiliar atual

      call determinante # calcula o determinante da submatriz

      popl %esi # obtém a matriz auxiliar da outra iteração (para desalocar)
      popl indice_fcol # antigo %ecx (contador da coluna) estava no topo
      call sinal_cofator # diz por quanto o determinante deve ser multiplicado com base na coluna fixada

      pushl %edx # guarda %edx
      movl  12(%esp), %edx # recupera %edi sem tirar da pilha

      pushl %ecx
      pushl %eax # Guarda o valor recém cálculado

      movl indice_fcol, %ecx
      movl $4, %eax
      decl %ecx # indice_fcol-1
      pushl %edx # multiplicar altera o edx
      mull %ecx # 4*(indice_fcol-1)
      popl %edx

      addl %eax, %edx # desloca 4*(indice_fcol-1) bytes para obter o elemento fixado
      movl (%edx), %edx # transfere para edx o próprio valor (elemento de posição [1]x[indice_fcol])

      popl %eax # Recupera o sinal do cofator
      imull %edx # (-1)^(1+indice_fcol) * elemento [1]x[indice_fcol]

      popl %ecx # Recupera o valor da coluna fixada
      popl %edx # Recupera o valor de %edx
      imull det_valor # (-1)^(1+indice_fcol) * elemento [1]x[indice_fcol] * det_valor (TEOREMA DE LAPLACE)

      # o valor antigo do determinante está no topo da pilha
      popl %edx
      addl %eax, %edx
      movl %edx, det_valor # soma o determinante antigo com o atual

      # verifica a quantidade de colunas ainda restantes a serem fixadas
      movl indice_fcol, %ecx
      popl %ebx # recupera a ordem da matriz
      pushl %ebx

      cmpl %ecx, %ebx
    jnz loop_ordem_maior_igual_3

      popl %ebx
      popl %edi

      pushl %esi # %esi tem o endereço que foi alocado para a matriz auxiliar
  		call free
  		addl $4, %esp

    jmp fim_calculo_det

    # Para matrizes de ordem 1
    # O valor do determinante é o próprio elemento da matriz
    ordem_1:
    popl %ebx
    popl %edi

    movl (%edi), %eax
    movl %eax, det_valor
    jmp fim_calculo_det # só cai neste caso se vier de uma matriz 1x1

    # Para matrizes de ordem 2
    # O determinante é dado por [a11*a22 - a12*a21]
    ordem_2:
      popl %ebx
      popl %edi

      movl (%edi), %eax # %eax = a11
      imull 12(%edi) # %eax = a11 * a22

      addl %eax, det_valor

      movl 4(%edi), %eax # %eax = a12
      imull 8(%edi) # %eax = a12 * a21
      movl $-1, %edx
      imull %edx # %eax = (-1) * (a12 * a21)

      addl %eax, det_valor
fim_calculo_det:

ret

# Pré-Condição:
#   Coluna fixa está em indice_fcol
# Pós-Condição:
#   A constante que multiplica o cofator (-1)^(linha + coluna) está em %eax
# Registradores Alterados:
#   %eax
sinal_cofator:
  movl indice_fcol, %eax
  andl $1, %eax
  cmpl $1, %eax
  jz notpar
    movl $-1, %eax
    ret
  notpar:
    movl $1, %eax
ret

# Pré-Condição:
#   Ordem da matriz principal está em %ebx
#   Coluna fixa está no topo da pilha
#   Endereço da matriz auxiliar está em %esi
#   Endereço da matriz principal está em %edi
# Pós-Condição:
#   A submatriz (desconsiderando a coluna %ebx e a primeira linha) de %edi em %esi
# Registradores Alterados:
#   %eax %ecx %edx %edi (%esi e %ebx são recalculados - não alteram)
submatriz:
  # A coluna fixa vai para indice_fcol
  movl 4(%esp), %eax
  movl %eax, indice_fcol
  # Avança para a segunda linha
  pushl %edi
  # incl %ebx
  call pular # avança N campos, ou seja, vai para [1][0] - 1º elemento da segunda linha da MP
  popl %edi # contém o endereço da segunda linha
  # decl %ebx

# Calcula a quantidade de elementos da matriz principal, exceto a primeira linha
  movl %ebx, %eax
  mull %eax # (%eax x %eax = %ebx x %ebx)
  movl %eax, %ecx # move para %ecx
  subl %ebx, %ecx # (%ecx <- %ecx - %eax) - assim temos nxn - n

  movl $0, %eax # %eax acompanha a coluna
  loop_submatriz:
    incl %eax
    cmpl %eax, indice_fcol # compara se a coluna atual deve ser copiada ou não
    je final_laco_submatriz

    movl  (%edi), %edx
    movl  %edx, (%esi) # copia o elemento para a posição atual em %esi
    addl $4, %esi # move para o proximo espaço em %esi

    final_laco_submatriz:
      addl $4, %edi # move para o proximo espaço em %edi
      cmpl %eax, %ebx  # chegou na última coluna
      jne pular_reset_eax
      movl $0, %eax
      pular_reset_eax:
      loop loop_submatriz

  # retorna %esi para o valor original
  decl %ebx # n-1
  movl %ebx, %eax
  incl %ebx # retorna %ebx para o valor original
  mull %eax # (n-1 x n-1)
  pushl %ebx
  movl $4, %ebx
  mull %ebx
  popl %ebx
  # addl $4, %eax # último add não considerado
  subl %eax, %esi # move para o proximo espaço em %esi
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
  call ler_n

  movl N, %eax
  movl N, %ebx
  incl %ebx
  call alocar_matriz
  movl %edi, matriz

  call ler_dados

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

resolver_sitema_ordem1:
  movl matriz, %edi
  movl $1, %ebx
  call determinante

fim:
  pushl $mensagemTchau
  call printf
  addl $4, %esp

  pushl $0
  call exit
