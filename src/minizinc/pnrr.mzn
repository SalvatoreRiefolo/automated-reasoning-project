enum INTERVENTI = {strade, fiumi, scuole, parchi, energia};
enum COMUNI;

var int: NUMERO_COMUNI;
int: SPESA_MINIMA_INTERVENTO = 100;
int: SPESA_MASSIMA = 1000;

array[COMUNI] of var int: ABITANTI_PER_COMUNE;
array[COMUNI, COMUNI] of var bool: STRADE_TRA_COMUNI;
array[COMUNI, INTERVENTI] of var 0..SPESA_MASSIMA: RICHIESTE;
array[COMUNI, INTERVENTI] of var 0..SPESA_MASSIMA: RICHIESTE_APPROVATE;

var int: non_erogate = 0;
var int: somma = sum(c in COMUNI, i in INTERVENTI) (RICHIESTE_APPROVATE[c,i]);
var float: media_richieste = sum(c in COMUNI) (RICHIESTE[c, scuole]) / NUMERO_COMUNI;
var int: abitanti_totali = sum(c in COMUNI) (ABITANTI_PER_COMUNE[c]);

array[INTERVENTI] of var int: totale_per_intervento = 
  [sum(c in COMUNI)(RICHIESTE_APPROVATE[c, i]) | i in INTERVENTI];

% VINCOLI

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

% per ogni tipologia di intervento viene speso almeno 1.000.000
constraint
  forall(i in INTERVENTI) (
    totale_per_intervento[i] >= SPESA_MINIMA_INTERVENTO
  );

% la spesa totale è minore di 10.000.000
constraint
  somma <= SPESA_MASSIMA;

% se le città sono adiacenti ed entrambe richiedono STRADE, una richiesta viene approvata e l'altra rigettata.
constraint
    forall(c1 in COMUNI, c2 in COMUNI where STRADE_TRA_COMUNI[c1, c2] = true /\ c1 < c2) (
        (RICHIESTE_APPROVATE[c2, strade] = 0 /\ RICHIESTE_APPROVATE[c1, strade] = RICHIESTE[c1, strade]) \/
        (RICHIESTE_APPROVATE[c1, strade] = 0 /\ RICHIESTE_APPROVATE[c2, strade] = RICHIESTE[c2, strade])
    );

constraint
    forall(c1 in COMUNI, c2 in COMUNI where STRADE_TRA_COMUNI[c1, c2] = false /\ c1 < c2) (
      (not (RICHIESTE_APPROVATE[c1, strade] == 0) -> RICHIESTE_APPROVATE[c1, strade] = RICHIESTE[c1, strade]) /\
      (not (RICHIESTE_APPROVATE[c2, strade] == 0) -> RICHIESTE_APPROVATE[c2, strade] = RICHIESTE[c2, strade])
    );

% ogni richiesta è approvata così com'è o ridotta del 10/20/30%
constraint 
  forall(c in COMUNI) (
    forall(r in INTERVENTI) (
      RICHIESTE_APPROVATE[c, r] = RICHIESTE_APPROVATE[c, r] \/
      RICHIESTE_APPROVATE[c, r] = RICHIESTE_APPROVATE[c, r] * 0.90 \/
      RICHIESTE_APPROVATE[c, r] = RICHIESTE_APPROVATE[c, r] * 0.80 \/
      RICHIESTE_APPROVATE[c, r] = RICHIESTE_APPROVATE[c, r] * 0.70
    )
  );

%Scuole
constraint
  forall(c in COMUNI)(
    if RICHIESTE[c, scuole] * (media_richieste / ABITANTI_PER_COMUNE[c]) < (2 * media_richieste)
    then RICHIESTE_APPROVATE[c, scuole] = RICHIESTE[c, scuole]
    else RICHIESTE_APPROVATE[c, scuole] = 0
    endif
  );

% Energia: 2 volte la richiesta deve essere minore alla somma delle altre richieste per la città. 
constraint
  forall(c in COMUNI)(
    if sum(r in {strade, fiumi, scuole, parchi}) (RICHIESTE[c, r]) > 2 * RICHIESTE[c, energia]
    then RICHIESTE_APPROVATE[c, energia] = RICHIESTE[c, energia]
    else RICHIESTE_APPROVATE[c, energia] = 0
    endif
  );

% Parchi: ogni città non può richiedere più di 10.000.000/n_comuni euro.
constraint   
  forall(c in COMUNI)(
    if RICHIESTE[c, parchi] < SPESA_MASSIMA / NUMERO_COMUNI
    then RICHIESTE_APPROVATE[c, parchi] = RICHIESTE[c, parchi]
    else RICHIESTE_APPROVATE[c, parchi] = 0
    endif
  );

% Fiumi: ogni città non può richiedere più di 6 volte il totale delle richieste dei fiumi, 
% moltiplicato per la percentuale di abitanti della città rispetto alla regione
var float: somma_richieste_fiumi = sum(c in COMUNI)(RICHIESTE[c, fiumi]);

constraint
  forall(c in COMUNI)(
    RICHIESTE_APPROVATE[c, fiumi] = RICHIESTE[c, fiumi] \/
    RICHIESTE_APPROVATE[c, fiumi] = 0
  );

% OBIETTIVO
% massimizzare spesa: 5.000.000 <= spesa <= 10.000.000
solve maximize(somma);

output  ["\n> Somma: "] ++ [ show(somma) ] ++
        ["\n> Richieste:"++"\n"] ++ [show(RICHIESTE[c,i]) ++ "\t" ++ 
          if i=length(INTERVENTI) then "\n" else " " endif | c in COMUNI, i in INTERVENTI] ++
        ["\n> Approvate:"++"\n"] ++ [show(RICHIESTE_APPROVATE[c,i]) ++ "\t" ++ 
          if i=length(INTERVENTI) then "\n" else " " endif | c in COMUNI, i in INTERVENTI] ++
        ["\n> Totale per intervento:\n"] ++ [ show(totale_per_intervento) ++ "\n"];