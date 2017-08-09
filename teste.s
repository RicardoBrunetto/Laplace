.section .data
descritor:  .int    0

SYS_EXIT:   .int 1
SYS_FORK:   .int 2
SYS_READ:   .int 3
SYS_WRITE:  .int 4
SYS_OPEN:   .int 5
SYS_CLOSE:  .int 6
SYS_CREAT:  .int 8

STD_OUT:    .int 1
STD_IN:     .int 2

O_RDONLY:   .int 0x0000
O_WRONLY:   .int 0x0001
O_RDWR:     .int 0x0002
O_CREAT:    .int 0x0040
O_EXCL:     .int 0x0080
O_APPEND:   .int 0x0400
O_TRUNC:    .int 0x0200

S_IRWXU:    .int 0x01C0
S_IRUSR:    .int 0x0100
S_IWUSR:    .int 0x0040
S_IRWXG:    .int 0x0038
S_IRGRP:    .int 0x0020
S_IWGRP:    .int 0x0010
S_IXGRP:    .int 0x0008
S_IRWXO:    .int 0x0007
S_IROTH:    .int 0x0004
S_IWOTH:    .int 0x0002
S_IXOTH:    .int 0x0001
S_NADA:     .int 0x0000

byte_enter:   .byte 10
byte_return:  .byte 13
byte_NULL:    .byte 0
byte_espaco:  .byte ' '


file_descriptor: .int 0
file_path:     .space   100
buffer_str:     .space 2
var:  .double 0
return_add1:  .int      0
return_add2:  .int      0

menosum:      .double   -1

str_format: .asciz  "\nei: %s\n"
str_in:     .asciz  "%s"
int_format: .asciz  "\n%i\n"
float_format: .asciz  "\n%lf\n"

two_addr:   .asciz  "\n%X\n%X\n"


teste:    .asciz  "19.21"
mostrafloat: .asciz "\n%lf\n"
te:         .int    0



.section .text
.globl _start
_start:
  call ler_caminho_entrada

  pushl $file_path
  pushl $str_format
  call printf
  addl $8, %esp

  call ler_arquivo

  pushl $0
  call exit

# Pré-Condição:
# Pós-Condição:
#   A string com o nome do arquivo de entrada está em file_path
# Registradores Alterados:
ler_caminho_entrada:
  pusha
  pushl $file_path
  pushl $str_in
  call scanf
  addl $8, %esp
  popa
ret

# Pré-Condição:
#   O endereço da string está no topo da pilha
# Pós-Condição:
#   A string contém \0 no final
# Registradores Alterados:
#   %edi
inserir_fim_str:
  popl return_add2
  popl %edi
  pusha
  movl $0, %ecx
  # econtra o enter
  loop_inserir_fim_str:
    addl $1, %ecx
    movb (%edi), %al
    cmpb byte_enter, %al
    jz fim_loop_inserir_fim_str
    addl $1, %edi
    jmp loop_inserir_fim_str
  fim_loop_inserir_fim_str:
  movb byte_NULL, %al
  incl %edi
  movb %al, (%edi)
  popa
  pushl return_add2
ret


# Pré-Condição:
#   file_descriptor contém o descritor do arquivo em uma posição válida
# Pós-Condição:
#   O valor lido está no topo da pilha
# Registradores Alterados:
ler_elemento:
  popl return_add1

  pusha
  movl SYS_READ, %eax
  movl file_descriptor, %ebx
  movl $buffer_str, %ecx
  movl $1, %edx
  int $0x80

  movl $buffer_str, %edi

  # lê byte a byte para detectar espaços / enters
  loop_ler_elemento:
    movb (%edi), %al
    cmpb byte_enter, %al

    je fim_loop_ler_elemento
    cmpb byte_espaco, %al
    je fim_loop_ler_elemento
    addl $1, %edi

    movl SYS_READ, %eax
    movl file_descriptor, %ebx
    movl %edi, %ecx
    movl $1, %edx
    int $0x80

    jmp loop_ler_elemento
  fim_loop_ler_elemento:

#  pushl $buffer_str
  # call inserir_fim_str

  finit
  pushl $buffer_str
  call atof
  addl $4, %esp

  popa

  subl $8, %esp
  fstpl (%esp)
  pushl return_add1
ret

# Pré-Condição:
#   O nome do arquivo de entrada está em file_path
# Pós-Condição:
#
# Registradores Alterados:
ler_arquivo:
  # Abre arquivo
  movl SYS_OPEN, %eax
  movl $file_path, %ebx
  movl O_RDONLY, %ecx
  int $0x80
  movl %eax, file_descriptor

  call ler_elemento

  fldl (%esp)

  pushl $float_format
  call printf
  addl $12, %esp

  call ler_elemento

  fldl (%esp)

  pushl $float_format
  call printf
  addl $12, %esp

  fadd %st(1), %st(0)

  subl $8, %esp
  fstpl (%esp)

  pushl $float_format
  call printf
  addl $12, %esp

  # Fecha arquivo
  movl SYS_CLOSE, %eax
  movl file_descriptor, %ebx
  int $0x80
ret
