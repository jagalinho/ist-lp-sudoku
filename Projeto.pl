%-----------------------------------------------------------
% Solucionador de Sudoku
% Projeto de 'Logica para Programacao'
% Joao Andre de Franca Ferreira Galinho - LEIC-T - 87667
%-----------------------------------------------------------

:- include('SUDOKU').

%-----------------------------------------------------------
% tira_num_aux(Num,Puz,Pos,N_Puz) significa que, dado um
% Numero (Num), um Puzzle (Puz) e uma Posicao (Pos), retorna
% um novo Puzzle (N_Puz) com o Num removido da Pos do Puz, e
% com essa mudanca propagada, caso a Pos se torne numa
% posicao unitaria.
%-----------------------------------------------------------

tira_num_aux(Num,Puz,Pos,N_Puz) :-
    puzzle_ref(Puz,Pos,Cont),
    subtract(Cont,[Num],Cont_aux),
    puzzle_muda_propaga(Puz,Pos,Cont_aux,N_Puz).

%-----------------------------------------------------------
% tira_num(Num,Puz,Posicoes,N_Puz) significa que, dado um
% Numero (Num), um Puzzle (Puz) e uma lista de Posicoes
% (Posicoes), retorna um novo Puzzle (N_Puz) com o Num
% retirado de todas as Posicoes em Posicoes do Puz, e com
% todas essas mudancas propagadas, caso alguma das Posicoes
% se torne unitaria.
%-----------------------------------------------------------

tira_num(Num,Puz,Posicoes,N_Puz) :-
    percorre_muda_Puz(Puz,tira_num_aux(Num),Posicoes,N_Puz).

%-----------------------------------------------------------
% puzzle_muda_propaga(Puz,Pos,Cont,Puz) significa que, dado
% um Puzzle (Puz), uma Posicao (Pos) e um Conteudo (Cont),
% retorna um novo Puzzle (N_Puz) com o Cont na Pos do Puz, e
% propaga* a mudanca caso o Cont seja uma lista unitaria.
% (* Propagar significa remover o numero em questao (neste
% caso, o que esta na lista unitaria Cont) de todas as
% posicoes relacionadas a posicao em questao (neste caso,
% a Pos).)
%-----------------------------------------------------------

puzzle_muda_propaga(Puz,Pos,Cont,Puz) :-
    puzzle_ref(Puz,Pos,Cont), !.
puzzle_muda_propaga(Puz,Pos,Cont,N_Puz) :-
    length(Cont,1),
    puzzle_muda(Puz,Pos,Cont,Puz_aux),
    posicoes_relacionadas(Pos,Posicoes),
    nth1(1,Cont,Num),
    tira_num(Num,Puz_aux,Posicoes,N_Puz), !.
puzzle_muda_propaga(Puz,Pos,Cont,N_Puz) :-
    puzzle_muda(Puz,Pos,Cont,N_Puz).

%-----------------------------------------------------------
% e_unitaria(Puz,Pos) significa que, dado um Puzzle (Puz) e
% uma Posicao (Pos), retorna 'true' se o conteudo da Pos
% relativamente ao Puz for unitaria, e 'false' caso
% contrario.
%-----------------------------------------------------------

e_unitaria(Puz,Pos) :-
    puzzle_ref(Puz,Pos,Cont),
    length(Cont,1).

%-----------------------------------------------------------
% possiblidades(Pos,Puz,Poss) significa que, dada uma
% Posicao (Pos) e um Puzzle (Puz), retorna uma lista com
% todas as possiblidades possiveis (Poss) para a Pos do Puz,
% tendo em conta apenas todas as posicoes relacionadas com a
% Pos cujo conteudo relativo ao Puz e uma lista unitaria.
%-----------------------------------------------------------

possibilidades(Pos,Puz,Poss) :-
    numeros(Todos),
    posicoes_relacionadas(Pos,Posicoes),
    include(e_unitaria(Puz),Posicoes,Posicoes_Uni),
    conteudos_posicoes(Puz,Posicoes_Uni,Conteudos_aux),
    append(Conteudos_aux,Conteudos),
    subtract(Todos,Conteudos,Poss).

%-----------------------------------------------------------
% inicializa_aux(Puz,Pos,N_Puz) significa que, dado um
% Puzzle (Puz) e uma Posicao (Pos), retorna um novo Puzzle
% (N_Puz) com a Pos do Puz inicializada*.
% (* Inicializar significa colocar no conteudo da Posicao em
% questao (neste caso, a Pos) todas as suas possibilidades,
% caso o seu conteudo ja nao seja uma posicao unitaria. Se
% apenas existir uma possibilidade, o conteudo da Posicao em
% questao torna-se unitario, e a mudanca e propagada para o
% resto do Puzzle em questao (neste caso, o Puz).)
%-----------------------------------------------------------

inicializa_aux(Puz,Pos,N_Puz) :-
    \+ e_unitaria(Puz,Pos),
    possibilidades(Pos,Puz,Poss),
    puzzle_muda_propaga(Puz,Pos,Poss,N_Puz), !.
inicializa_aux(Puz,_,Puz).

%-----------------------------------------------------------
% inicializa(Puz,N_Puz) significa que, dado um Puzzle (Puz),
% retorna um novo Puzzle (N_Puz) com todas as Posicoes do
% Puz inicializadas.
%-----------------------------------------------------------

inicializa(Puz,N_Puz) :-
    todas_posicoes(Posicoes),
    percorre_muda_Puz(Puz,inicializa_aux,Posicoes,N_Puz).

%-----------------------------------------------------------
% pos_aparencia(Puz,Num,Posicoes,Pos_Num) significa que,
% dado um Puzzle (Puz), um Numero (Num) e uma lista de
% Posicoes (Posicoes), retorna uma Posicao (Pos_Num)
% correspondente a primeira aparencia do Num nos conteudos
% das Posicoes relativos ao Puz. Se o Num nao aparecer
% nos conteudos das Posicoes relativos ao Puz, retorna
% 'false'.
%-----------------------------------------------------------

pos_aparencia(Puz,Num,[Pos|_],Pos_Num) :-
    puzzle_ref(Puz,Pos,Cont),
    member(Num,Cont),
    Pos_Num = Pos, !.
pos_aparencia(Puz,Num,[_|Outras_Pos],Pos_Num) :-
    pos_aparencia(Puz,Num,Outras_Pos,Pos_Num).

%-----------------------------------------------------------
% so_aparece_uma_vez(Puz,Num,Posicoes,Pos_Num) significa
% que, dado um Puzzle (Puz), um Numero (Num) e uma lista de
% Posicoes (Posicoes), devolve a Posicao na qual o Num
% aparece (Pos_Num). Caso o Num nao apareca exatamente uma
% vez nos conteudos das Posicoes de Posicoes relativos ao
% Puz, retorna 'false'.
%-----------------------------------------------------------

so_aparece_uma_vez(Puz,Num,Posicoes,Pos_Num) :-
    pos_aparencia(Puz,Num,Posicoes,Pos_Num),
    subtract(Posicoes,[Pos_Num],N_Posicoes),
    \+ pos_aparencia(Puz,Num,N_Posicoes,_).

%-----------------------------------------------------------
% inspecciona_num(Posicoes,Puz,Num,N_Puz) significa que,
% dada uma lista de Posicoes (Posicoes), um Puzzle (Puz) e
% um Numero (Num), retorna um novo Puzzle (N_Puz) com o
% Num inspeccionado* nas Posicoes em Posicoes.
% (* Inspeccionar significa, se o numero em questao (neste
% caso, o Num) aparecer apenas uma vez nas Posicoes em
% questao, mudar o conteudo da posicao na qual aparece para
% a lista unitaria contendo apenas o proprio numero, e
% propagar essa mudanca.)
%-----------------------------------------------------------

inspecciona_num(Posicoes,Puz,Num,N_Puz) :-
    so_aparece_uma_vez(Puz,Num,Posicoes,Pos_Num),
    puzzle_muda_propaga(Puz,Pos_Num,[Num],N_Puz), !.
inspecciona_num(_,Puz,_,Puz).

%-----------------------------------------------------------
% inspecciona_grupo(Puz,Gr,N_Puz) significa que, dado um
% Puzzle (Puz) e uma lista de Posicoes (Gr), retorna um
% novo Puzzle (N_Puz) com todos os numeros possiveis
% inspeccionados nas Posicoes em Gr.
%-----------------------------------------------------------

inspecciona_grupo(Puz,Gr,N_Puz) :-
    numeros(Todos),
    percorre_muda_Puz(Puz,inspecciona_num(Gr),Todos,N_Puz).

%-----------------------------------------------------------
% inspecciona(Puz,N_Puz) significa que, dado um Puzzle
% (Puz), retorna um novo Puzzle (N_Puz) com todos os numeros
% possiveis inspeccionados em todos os grupos do Puz.
%-----------------------------------------------------------

inspecciona(Puz,N_Puz) :-
    grupos(Todos),
    percorre_muda_Puz(Puz,inspecciona_grupo,Todos,N_Puz).

%-----------------------------------------------------------
% grupo_correto(Puz,Nums,Gr) significa que, dado um Puzzle
% (Puz), uma lista de Numeros (Nums) e uma lista de
% Posicoes (Gr), retorna 'true' se todos os Numeros em Nums
% aparecerem exatamente uma vez nos conteudos das Posicoes
% em Gr relativos ao Puz, e 'false' caso contrario.
%-----------------------------------------------------------

grupo_correcto(_,[],_) :- !.
grupo_correcto(Puz,[Num|Outros_Num],Gr) :-
    so_aparece_uma_vez(Puz,Num,Gr,_),
    grupo_correcto(Puz,Outros_Num,Gr).

%-----------------------------------------------------------
% solucao(Puz) significa que, dado um Puzzle (Puz), retorna
% 'true' caso o Puz seja uma solucao valida, e retorna
% 'false' caso contrario.
%-----------------------------------------------------------

solucao(Puz) :-
    numeros(Nums),
    grupos(Grs),
    solucao(Puz,Nums,Grs).
solucao(_,_,[]) :- !.
solucao(Puz,Nums,[Gr|Outros_Gr]) :-
    grupo_correcto(Puz,Nums,Gr),
    solucao(Puz,Nums,Outros_Gr).

%-----------------------------------------------------------
% inspecciona_multiplo(Puz,N_Puz) siginfica que, dado um
% Puzzle (Puz), retorna um novo Puzzle (N_Puz) que
% corresponde ao Puz inspeccionado multiplas vezes, ate que
% a sua inspeccao ja nao tenha qualquer efeito.
%-----------------------------------------------------------

inspecciona_multiplo(Puz,N_Puz) :-
    inspecciona(Puz,Puz_Aux),
    Puz \= Puz_Aux,
    inspecciona_multiplo(Puz_Aux,N_Puz).
inspecciona_multiplo(Puz,Puz).

%-----------------------------------------------------------
% resolve_pos(Puz,Pos,Nums,Sol) significa que, dado um
% Puzzle (Puz), uma Posicao (Pos) e uma lista de Numeros
% (Nums), retorna um novo Puzzle (Sol) com um dos Numeros de
% Nums na Pos do Puz de forma a este ser uma solucao valida.
% Se nenhum dos Numeros de Nums na Pos gerar uma solucao
% valida, retorna 'false'.
%-----------------------------------------------------------

resolve_pos(Puz,Pos,[Num|_],Sol) :-
    puzzle_muda_propaga(Puz,Pos,[Num],N_Puz),
    inspecciona_multiplo(N_Puz,Sol),
    solucao(Sol), !.
resolve_pos(Puz,Pos,[_|Outros_Num],Sol) :-
    resolve_pos(Puz,Pos,Outros_Num,Sol).

%-----------------------------------------------------------
% resolve_aux(Puz,Posicoes_N_Uni,Sol) significa que, dado um
% Puzzle (Puz) e uma lista das suas Posicoes nao unitarias
% (Posicoes), retorna um novo Puzzle (Sol) que corresponde a
% solucao do Puz.
%-----------------------------------------------------------

resolve_aux(Puz,[Pos|_],Sol) :-
    puzzle_ref(Puz,Pos,Cont),
    resolve_pos(Puz,Pos,Cont,Sol), !.
resolve_aux(Puz,[_|Outras_Pos],Sol) :-
    resolve_aux(Puz,Outras_Pos,Sol).

%-----------------------------------------------------------
% resolve(Puz,Sol) significa que, dado um Puzzle (Puz),
% retorna um novo Puzzle (Sol) que corresponde a solucao do
% Puz.
%-----------------------------------------------------------

resolve(Puz,Sol) :-
    inicializa(Puz,Puz_Ini),
    inspecciona_multiplo(Puz_Ini,N_Puz),
    todas_posicoes(Posicoes),
    exclude(e_unitaria(N_Puz),Posicoes,Posicoes_N_Uni),
    resolve_aux(N_Puz,Posicoes_N_Uni,Sol), !.
