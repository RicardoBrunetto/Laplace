.section .data

mensagemInicial:      .asciz    "%s* Trabalho 01 - Resolutor de Sistemas Lineares de N variáveis \t*%s"
mensagemTchau:        .asciz    "\nTchau Tchau!\n"
mensagemMostrar:      .asciz    "\tMatriz atual:\n"

divisoria:            .asciz    "\n-----------------------------------------------------------------\n"

author:   .asciz    "Autor:\nRicardo Henrique Brunetto\t-\tRA: 94182\n"
input_f:  .asciz    "%s*\tA inserção das linhas é do seguinte formato:\t\t*\n*\tcn*xn + ... + c2*x2 + c1*x1 = res_xn\t\t\t*\n*\t\t\t\t\t\t\t\t*\n*\tOnde será solicitado o coeficiente de cada xi\t\t*%s"

pedirN:     .asciz    "\nInforme a quantidade de variáveis (e equações):\t"

pedirLn:    .asciz    "\n---------- Equação (Linha da Matriz) %d ----------\n"
pedirXn:    .asciz    "\nInforme o coeficiente de x%d: "
pedirRes:   .asciz    "\nInforme o resultado da equação %d: "

mostrar_elemdois:   .asciz  "\nMostrarElem: %d\t\n"
mostrar_reg:   .asciz  "\nMostrarReg: %X\t\n"

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


# Transforma o endereço [i][j] ([%ebx][%ecx]) em um endereço [k] ([%eax]) - matriz[0][0] em %edi
matricial_linear:
   popl return_add3 # Guarda o endereço de retorno
   # Nesse momento, %edi deve estar no topo da pilha
   addl %ebx, %ecx # soma as linhas + colunas a serem deslocadas
   movl %ecx, %eax # move para %eax
   call pular # vai avançar %ebx + %ecx (i+j) campos
   # %edi vai estar apontando para matriz[i][j]
   pushl return_add3
ret

# Avança para o proximo campo (4 bytes)
proximo_campo:
  popl %edx

  popl %edi
  addl $4, %edi
  pushl %edi

  pushl %edx
ret

# Avança %eax campos (é como se fosse um proximo_campo de %eax loops)
pular:
  popl return_addJ

  popl %edi
  pushl %ebx  # guarda o conteúdo de ebx, caso tenha algo importante

  movl $4, %ebx
  mull %ebx   # faz eax * 4
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

# Aloca a matriz de %eax x %ebx bytes e guarda o ponteiro em %edi
alocar_matriz:
  movl $4, %ecx
  mull %ebx # multiplica %eax x %ebx
  mull %ecx # 4 x (%eax x %ebx), pois 1 inteiro ocupa 4 bytes

  movl %eax, %ecx
  pushl %ecx
  call malloc
  addl $4, %esp
  movl %eax, %edi
ret

# Supoe que o bloco de memória está em %edi
mostrar_linha:
  popl return_add2 # deixa %edi no topo da pilha / guarda o endereço de retorno
  movl N, %ecx
  incl %ecx # mostrar os n+1 inteiros

loop_mostrar_linha:
  movl %ecx, contadorEq # faz backup do valor de ecx (contador)

  # %edi está na pilha
  pushl (%edi)
  pushl $mostrar_elem
  call printf
  addl $8, %esp

  call proximo_campo

  movl contadorEq, %ecx
  loop loop_mostrar_linha

  pushl return_add2
ret

# mostra a matriz que está em %edi
mostrar_matriz:
  pushl $divisoria
  call printf
  pushl $mensagemMostrar
  call printf
  addl $8, %esp

  popl return_add1 # guarda o endereço de retorno
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


# Calcula o determinante da matriz cujo endereço está em %edi
determinante:
  cmpl $1, N
  je ordem_1
   cmpl $2, N
  je ordem_2

# Para matrizes de ordem maior igual a 3 [endereço da matriz continua em %edi]
ordem_maior_igual_3:
  movl N, %ecx
  decl %ecx # considera N-1 de dimensão
  movl $4, %eax
  mull %ecx
  mull %ecx # 4x(N-1 x N-1)

  pushl %eax
  call malloc
  movl %eax, matriz_aux # aloca a matriz auxiliar de dimensão N-1 por N-1
  addl $4, %esp

  movl %edi, %esi # A partir de agora, %esi tem o endereço do 1º elemento da matriz principal [MP]

pular_segunda_linha:
  movl N, %eax
  incl %eax
  call pular # avança N+1 campos (considera a resposta), ou seja, vai para [1][0] - 1º elemento da segunda linha da MP


  movl $0, %edx # percorre a primeira linha


ordem_1:

ordem_2:












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

  movl matriz, %edi # coloca o endereço inicial da matriz em %edi
  pushl %edi # coloca %edi na pilha

  call pular_segunda_linha

#  call mostrar_matriz


fim:
  pushl $mensagemTchau
  call printf
  addl $4, %esp

  pushl $0
  call exit
