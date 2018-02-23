# Resolutor de Sistemas Lineares
Estes trabalhos foram desenvolvidos para a disciplina de Programação para Interfaceamento Hardware Software (Ciência da Computação - UEM) em Agosto/2017 por Ricardo Henrique Brunetto (ra94182@uem.br)

## Descrição
Aqui comportam-se dois trabalhos distintos.
- [Sarrus](Sarrus): Resolução de Sistemas Lineares de ordem 3 através da regra de Sarrus.
- [Laplace](Laplace): Resolução de Sistemas Lineares de quaisquer ordem positiva através da regra de Laplace.

## Especificações Tecnológicas
Ambos os programas foram escritos em Assembly-Intel-32. Para cada qual, o `makefile` local pode ser perfeitamente utilizado, visto que não há dependências externas que requeiram complexidade.

## Implementação
Relatório de [Sarrus](Sarrus/Relatório.pdf) e [Laplace](Laplace/Relatório/Documento.pdf).

### Limitações e Sugestões
- Em relação à implementação de Laplace, não foi feita considerando números em ponto-flutuante. Segue como sugestão de trabalho futuro.

## Licença
Este projeto segue a licença [Creative Commons Attribution-ShareAlike (BY-SA)](https://creativecommons.org/licenses/by-sa/4.0/), que está detalhada no arquivo [`LICENSE.md`](LICENSE.md).
<p align="center">
  <img src="https://licensebuttons.net/l/by-sa/3.0/88x31.png">
</p>

# Laplace

Implementação em Assembly de um resolutor de sistemas lineares de N equações com N variáveis através dos teoremas de Cramer e Laplace.

- [ ] Entrada
  - [ ] Entrada por arquivo
- [x] Cálculo do determinante (Laplace)
  - [x] Gerar matriz sem a última coluna (coeficientes)
  - [x] Gerar submatriz (cofator Aij)
  - [x] Cálculo do sinal de cofator
  - [x] Cálculo de Laplace
    - [x] Lógica para calcular o determinante parcialmente
- [x] Principal
  - [x] Sequência correta dependendo da ordem
- [x] Copiar a coluna Z
- [x] Regra de Cramer
- [ ] Usar ponto flutuante
  - [x] Alterar os espaços de armazenamento
  - [ ] Lógica de cada procedimento usando a pilha FPU
- [ ] Utilizar vetor de variáveis
- [ ] Otimizar quando o coeficiente for zero
