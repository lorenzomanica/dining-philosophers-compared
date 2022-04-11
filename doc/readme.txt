Enunciado do do trabalho de Concorrência TPC1: Filósofos Jantando

Como vimos em aula, o problema dos filósofos jantando foi originalmente 
formulado por Dijkstra em 1965 e é usado frequentemente para exemplificar 
problemas de concorrência relacionados ao acesso a recursos. 
Nele cinco filósofos estão sentados ao redor de uma mesa de jantar, 
com um garfo entre dois filósofos adjacentes. Cada filósofo alterna entre 
pensar e comer. Para conseguir comer um filósofo precisa de dois garfos, 
o da esquerda e o da direta. A solução deve garantir que não ocorra 
deadlock e starvation, ainda assim mantendo um bom grau de concorrência 
(possibilidade de vários filósofos pensarem ao mesmo tempo e depois 
comerem ao mesmo).


Neste trabalho o desafio é apresentar duas soluções concorrentes para o 
problema, descrever e explicar o seu funcionamento, mostrar sua execução 
em uma máquina com várias núcleos e analisar como se comparam em relação:

    ao funcionamento geral da solução;
    aos mecanismos usados na sincronização;
    como estes mecanismos são implementados na linguagem escolhida;
    como as soluções evitam deadlock e starvation;
    ao nível de concorrência obtido de cada solução 
        (comparando com uma versão sequencial não concorrente). 
        Ou seja, qual versão permite mais concorrência quando filósofos 
        pensam e quando filósofos comem). Isto poderia ser avaliado por 
        alguma estimativa de tempo ou colocando tempos em cada fase 
        e medindo, por exemplo, o tempo total que eles levam para pensar 
        e comer 10 vezes cada um.

Os códigos que implementam as soluções escolhidas podem ser buscados na 
internet e podem estar em qualquer linguagem, mas sua execução precisa 
ser reproduzida em uma máquina local do grupo (ou que o grupo tenha acesso) 
com mais de um core para que seja possível a análise de concorrência física. 
Para fins de comparação, deve ser desenvolvida pelo grupo uma versão sequencial 
onde os filósofos pensam e comem em sequência, um depois do outro, 
para ser usada como baseline para as versões concorrentes.

A avaliação do trabalho será feita com base no acompanhamento do 
desenvolvimento do trabalho em laboratório e no envio de um relatório 
técnico no moodle que atenda as questões enumeradas acima.

Formato do relatório técnico:

    arquivo formato .pdf;
    cabeçalho reduzido com identificação do grupo e do trabalho;
    primeira página coluna dupla com margens reduzidas (2cm) e fonte 10;
    segunda página com dumps de tela mostrando a execução dos programas 
        em funcionamento;
    a partir da terceira página código fonte formatado em coluna simples 
        dos programas utilizados no trabalho (sem limite).

Dicas para formatar o código: copiar o código do VS Code e colar no Word, 
ele mantém toda a formatação. Depois ajeitar o tamanho da fonte e o 
espaçamento entre as linhas pra economizar espaço. 
Outra opção é usar o overleaf que já importa o arquivo formatado.