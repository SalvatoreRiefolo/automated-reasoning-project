%include "common.dzn";

enum INTERVENTI;
enum COMUNI;

var int: NUMERO_COMUNI;
var int: SPESA_MINIMA;
var int: SPESA_MASSIMA;

array[COMUNI] of var int: ABITANTI_PER_COMUNE;
array[COMUNI, COMUNI] of var bool: STRADE_TRA_COMUNI;
array[COMUNI, INTERVENTI] of var 0..SPESA_MASSIMA: RICHIESTE;
array[COMUNI, INTERVENTI] of var 0: RICHIESTE_APPROVATE;

var int: non_erogate = 0;
var int: somma = sum(c in COMUNI, i in INTERVENTI) (RICHIESTE_APPROVATE[c,i]);
var float: media_richieste = sum(c in COMUNI)(RICHIESTE[c, scuole]) / NUMERO_COMUNI;

var int: abitanti_totali = sum(c in COMUNI)(ABITANTI_PER_COMUNE[c]);
array[COMUNI] of var float: percentuale_abitanti_per_citta;

% VINCOLI

constraint
  forall(c in COMUNI)(
    percentuale_abitanti_per_citta = ABITANTI_PER_COMUNE[c] / abitanti_totali
  );

% ogni città richiede almeno un progetto
constraint 
  forall(c in COMUNI) (
    exists(i in INTERVENTI) (
      RICHIESTE[c,i] != 0
      )
    );

% ogni città ha almeno un progetto approvato
constraint 
  forall(c in COMUNI) (
    exists(i in INTERVENTI) (
      RICHIESTE_APPROVATE[c,i] != 0
      )
    );

% la spesa totale è minore di 10.000.000 e maggiore di 5.000.000
constraint
  somma <= SPESA_MASSIMA /\ somma > SPESA_MINIMA;

% se le città sono adiacenti ed entrambe richiedono STRADE, una richiesta viene approvata e l'altra rigettata.
constraint 
  forall(i,j in COMUNI) (
    if STRADE_TRA_COMUNI[i,j] 
    then 
      RICHIESTE_APPROVATE[i, strade] = RICHIESTE[i, strade] /\ RICHIESTE_APPROVATE[j, strade] = 0 \/ 
      RICHIESTE_APPROVATE[j, strade] = RICHIESTE[j, strade] /\ RICHIESTE_APPROVATE[i, strade] = 0
    endif
  );

% ogni richiesta è approvata così com'è o ridotta del 10/20/30% TODO: check
constraint 
  forall(c in COMUNI) (
    forall(r in INTERVENTI) (
      RICHIESTE_APPROVATE[c, r] = RICHIESTE_APPROVATE[c, r] \/
      RICHIESTE_APPROVATE[c, r] = RICHIESTE_APPROVATE[c, r] * 0.90 \/
      RICHIESTE_APPROVATE[c, r] = RICHIESTE_APPROVATE[c, r] * 0.80 \/
      RICHIESTE_APPROVATE[c, r] = RICHIESTE_APPROVATE[c, r] * 0.70
    )
  );

% Scuole
constraint
  forall(c in COMUNI)(
    if RICHIESTE[c, scuole] * (media_richieste / ABITANTI_PER_COMUNE[c]) < (2 * media_richieste)
    then RICHIESTE_APPROVATE[c, scuole] = RICHIESTE[c, scuole]
    endif
  );

% Energia: la richiesta deve essere minore a 4 volte la somma delle altre richieste per la città. 
constraint
  forall(c in COMUNI)(
    if sum(r in {strade, fiumi, scuole, parchi}) (RICHIESTE[c, r]) < 4 * RICHIESTE[c, energia]
    then RICHIESTE_APPROVATE[c, energia] = RICHIESTE[c, energia]
    endif
  );

% Parchi: ogni città non può richiedere più di 10.000.000/n_comuni euro.
constraint   
  forall(c in COMUNI)(
    if RICHIESTE[c, parchi] < SPESA_MASSIMA / NUMERO_COMUNI
    then RICHIESTE_APPROVATE[c, parchi] = RICHIESTE[c, parchi]
    endif
  );

% Fiumi: ogni città non può richiedere più di 2 volte il totale delle richieste dei fiumi, 
% moltiplicato per la percentuale di abitanti della città rispetto alla regione
var float: somma_richieste_fiumi = sum(c in COMUNI)(RICHIESTE[c, fiumi]);

constraint
  forall(c in COMUNI)(
    if RICHIESTE[c, fiumi] < 2 * somma_richieste_fiumi * percentuale_abitanti_per_citta[c]
    then RICHIESTE_APPROVATE[c, fiumi] = RICHIESTE[c, fiumi]
    endif
  );


% GOAL
% massimizzare spesa: 5.000.000 <= spesa <= 10.000.000
solve maximize somma

% minimizzare numero di richieste non erogate
