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
array[COMUNI, RICHIESTE] of var 0..10000000: RICHIESTE;
array[COMUNI, RICHIESTE] of var 0..10000000: RICHIESTE_APPROVATE;

var int: non_erogate = 0;
var int: somma = sum(i in COMUNI, j in RICHIESTE) (RICHIESTE_APPROVATE[i,j]);

% VINCOLI

% ogni città richiede almeno un progetto
constraint 
  forall(i in COMUNI) (
    exists(j in RICHIESTE) (
      RICHIESTE[i,j] != 0
      )
    );

% ogni città ha almeno un progetto approvato
constraint 
  forall(i in COMUNI) (
    exists(j in RICHIESTE) (
      RICHIESTE_APPROVATE[i,j] != 0
      )
    );

% la spesa totale è minore di 10.000.000 e maggiore di 5.000.000
constraint
  somma <= 10000000 /\ somma > 5000000;

% se le città sono adiacenti ed entrambe richiedono STRADE, una richiesta viene approvata e l'altra rigettata.
constraint 
  forall(i,j in COMUNI) (
    if strade_tra_comuni[i,j] 
    then RICHIESTE_APPROVATE[i, strade] = 0 \/ RICHIESTE_APPROVATE[j, strade] = 0 
    endif
  );

% ogni richiesta è approvata così com'è o ridotta del 10/20/30% TODO: check
constraint 
  forall(c in COMUNI) (
    forall(r in RICHIESTE) (
      RICHIESTE_APPROVATE[c, r] = RICHIESTE_APPROVATE[c, r] \/
      RICHIESTE_APPROVATE[c, r] = RICHIESTE_APPROVATE[c, r] * 0.90 \/
      RICHIESTE_APPROVATE[c, r] = RICHIESTE_APPROVATE[c, r] * 0.80 \/
      RICHIESTE_APPROVATE[c, r] = RICHIESTE_APPROVATE[c, r] * 0.70
    )
  );

% scuole
constraint
  let { 
    var float: media = sum(i in COMUNI)(RICHIESTE_APPROVATE[i, scuole]) / numero_comuni;
    } in 
  forall(c in COMUNI)(
    if RICHIESTE_APPROVATE[c, scuole] * (media / abitanti_per_comune[c]) > (2 * media)
    then RICHIESTE_APPROVATE[c, scuole] = 0
    endif
  );

% energia:
constraint
  forall(c in COMUNI)(
    if sum(r in {strade, fiumi, scuole, parchi}) (RICHIESTE[c, r]) > 4 * RICHIESTE[i, energia]
    then RICHIESTE_APPROVATE[c, energia] = RICHIESTE[c, energia]
    else RICHIESTE_APPROVATE[c, energia] = 0
    endif
  );

% parchi: 
var int: totale_abitanti = sum(a in abitanti_per_comune) (a)
var int: spesa_parchi = sum(i in COMUNI)(RICHIESTE[i, parchi]);

constraint   
  forall(c in COMUNI)(
    RICHIESTE_APPROVATE[c, parchi] > spesa_parchi * (abitanti_per_comune[c] / totale_abitanti) -> RICHIESTE_APPROVATE[c, parchi] = 0
  );

% GOAL
% massimizzare spesa: 5.000.000 <= spesa <= 10.000.000
solve maximize somma

% minimizzare numero di richieste non erogate


