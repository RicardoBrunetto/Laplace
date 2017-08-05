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

teste:    .asciz  "19.21"
mostrafloat: .asciz "\n%lf\n"
var:        .space  8
te:         .int    0
.section .text
.globl _start
_start:
  pushl $teste
  call converte_double

  pushl $mostrafloat
  call printf
  addl $4, %esp


  pushl $0
  call exit

# Pré-Condição
#   Endereço inicial da string está na pilha
# Pós-Condição:
#   Double está no topo da pilha
# Registradores Alterados:
#   %ebx %eax %st(0)
converte_double:
  popl %ebx # endereço de retorno desempilhado
  popl %eax # endereço inicial da string

  finit
  subl $8, %esp
  pushl %eax
  call atof
  addl $4, %esp
  fstl var

  fstpl (%esp)
  pushl $mostrafloat
  call printf
  addl $4, %esp

  pushl %ebx
ret
