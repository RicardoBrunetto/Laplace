# Resolutor de Sistemas Lineares
Este trabalho foi desenvolvido para a disciplina de Programação para Interfaceamento Hardware Software (Ciência da Computação - UEM) em Agosto/2017 por Ricardo Henrique Brunetto (ra94182@uem.br)

## Funcionalidade
Dado um arquivo de entrada que esteja configurado como uma matriz de números inteiros de ordem 3, o programa calcula o Determinante e o valor das variáveis considerando a matriz como um sistema linear, através da aplicação das regras de Sarrus e Cramer.

## Especificações Tecnológicas
Todo o programa foi escrito em Assembly-Intel-32. O `makefile` local pode ser perfeitamente utilizado, visto que não há dependências externas que requeiram complexidade.

## Implementação
O relatório pode ser encontrado [aqui](Relatório.pdf).

## Lista de Afazeres
- [x] Entrada
- [x] Cálculo do determinante (Sarrus)
  - [x] Cálculo de Sarrus
    - [x] Lógica para calcular o determinante por produtos
- [x] Principal
  - [x] Sequência correta dependendo da ordem
- [x] Copiar a coluna Z
- [x] Regra de Cramer

## Licença
Este projeto segue a licença [Creative Commons Attribution-ShareAlike (BY-SA)](https://creativecommons.org/licenses/by-sa/4.0/), que está detalhada no arquivo [`LICENSE.md`](LICENSE.md).
<p align="center">
  <img src="https://licensebuttons.net/l/by-sa/3.0/88x31.png">
</p>
