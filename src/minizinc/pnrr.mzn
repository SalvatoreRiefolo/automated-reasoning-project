include "benchmarks/common.dzn";

% Cifre espresse in migliaia
% 1    = 1.000
% 10   = 10.000
% 100  = 100.000
% 1000 = 1.000.000

enum RICHIESTE;
enum COMUNI;

var int: numero_comuni;

array[COMUNI] of var int: abitanti_per_comune;
array[COMUNI, COMUNI] of var bool: strade_tra_comuni;
array[COMUNI, RICHIESTE] of var 0..10000: RICHIESTE_PER_COMUNE;

var int: non_erogate = 0;

% VINCOLI

% ogni città richiede almeno un progetto, e ogni città ha almeno un progetto approvato
constraint 
  forall(i in COMUNI) (
    exists(j in RICHIESTE) (
      RICHIESTE_PER_COMUNE[i,j] != 0
      )
    );

% se le città sono adiacenti ed entrambe richiedono STRADE, una richiesta viene approvata e l'altra rigettata.
constraint 
  forall(i,j in COMUNI) (
    if strade_tra_comuni[i,j] 
    then RICHIESTE_PER_COMUNE[i, strade] = 0 \/ RICHIESTE_PER_COMUNE[j, strade] = 0 
    endif
  );

% almeno 1.000.000 per tipologia: la spesa minima è di 5.000.000.
constraint
  forall(j in RICHIESTE) (
    sum(i in COMUNI) (RICHIESTE_PER_COMUNE[i,j]) > 1000
  );

% al massimo 10.000.000
var int: somma = sum(i in COMUNI, j in RICHIESTE) (RICHIESTE_PER_COMUNE[i,j]);

constraint
  somma <= 10000;

% scuole

%constraint
%   let { 
%     var float: media = sum(i in COMUNI)(RICHIESTE_PER_COMUNE[i, scuole]) / numero_comuni;
%     } in 
%   forall(c in COMUNI)(
%     if RICHIESTE_PER_COMUNE[c, scuole] * (media / abitanti_per_comune[c]) > (2 * media)
%     then RICHIESTE_PER_COMUNE[c, scuole] = 0
%     endif
%   );

% energia: se una città ha chiesto finanziamenti per tutti gli altri progetti e ha meno di 20.000 abitanti, non viene concesso il finanziamento
% constraint
%   forall(i in COMUNI)(
%     forall(r in {strade, fiumi, scuole, parchi})
%       (RICHIESTE_PER_COMUNE[i, r] > 0) /\ abitanti_per_comune[i] < 20 -> RICHIESTE_PER_COMUNE[i, energia] = 0          
%   );

% parchi: 
% constraint   
%   let { 
%     var int: spesa_parchi = sum(i in COMUNI)(RICHIESTE_PER_COMUNE[i, parchi]);
%     var int: totale_abitanti = sum(a in abitanti_per_comune) (a)
%     } in 
%   forall(c in COMUNI)(
%     RICHIESTE_PER_COMUNE[c, parchi] > spesa_parchi * (abitanti_per_comune[c] / totale_abitanti) -> RICHIESTE_PER_COMUNE[c, parchi] = 0
%   );

% GOAL
% massimizzare spesa: 5.000.000 <= spesa <= 10.000.000
solve maximize somma

% minimizzare numero di richieste non erogate


