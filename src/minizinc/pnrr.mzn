% Cifre espresse in migliaia
% 1    = 1.000
% 10   = 10.000
% 100  = 100.000
% 1000 = 1.000.000

enum RICHIESTE = {strade, fiumi, scuole, parchi, energia};
enum COMUNI = {
  perugia,
  terni,
  foligno,
  citta_di_castello,
  spoleto,
  gubbio,
  assisi,
  corciano,
  bastia_umbra,
  orvieto,
  marsciano,
  narni,
  umbertide,
  todi,
  castiglione_del_lago,
  magione,
  gualdo_tardino,
  amelia,
  san_giustino
  };
  

% abitanti per comune in migliaia
array[COMUNI] of var int: abitanti_per_comune = [161,106,55,38,36,30,27,21,21,19,18,17,16,15,15,14,14,11,11];

array[COMUNI, COMUNI] of var bool: strade_tra_comuni = [|
  false,false,false,false,false,false,false,true,true,false,true,false,true,false,false,false,false,false,false    |
  false,false,false,false,true,false,false,false,false,false,false,true,false,false,false,false,false,false,false  |
  false,false,false,false,false,false,true,false,false,false,false,false,false,false,false,false,false,false,false |
  false,false,false,false,false,false,false,false,false,false,false,false,true,false,false,false,false,false,true  |
  false,true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false |
  false,false,false,false,false,false,false,false,false,false,false,false,true,false,false,false,true,false,false  |
  false,false,true,false,false,false,false,false,true,false,false,false,false,false,false,false,false,false,false  |
  true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,true,false,false,false  |
  true,false,false,false,false,false,true,false,false,false,false,false,false,false,false,false,false,false,false  |
  false,false,false,false,false,false,false,false,false,false,false,false,false,true,false,false,false,false,false |
  true,false,false,false,false,false,false,false,false,false,false,false,false,true,false,false,false,false,false  |
  false,true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,true,false  |
  true,false,false,true,false,true,false,false,false,false,false,false,false,false,false,false,false,false,false   |
  false,false,false,false,false,false,false,false,false,true,true,false,false,false,false,false,false,true,false   |
  false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,true,false,false,false |
  false,false,false,false,false,false,false,true,false,false,false,false,false,false,true,false,false,false,false  |
  false,false,false,false,false,true,false,false,false,false,false,false,false,false,false,false,false,false,false |
  false,false,false,false,false,false,false,false,false,false,false,true,false,true,false,false,false,false,false  |
  false,false,false,true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false |
|];

array[COMUNI, RICHIESTE] of var 0..10000: RICHIESTE_PER_COMUNE;

% VINCOLI

% ogni città richiede almeno un progetto
% ogni città ha almeno un progetto approvato
constraint 
  forall(i in COMUNI) (
    exists(j in RICHIESTE) (
      RICHIESTE_PER_COMUNE[i,j] != 0
      )
    );

% se le città sono adiacenti ed entrambe richiedono STRADE, una richiesta viene approvata e l'altra rigettata.
constraint 
  forall(i,j in COMUNI) (
    if strade_tra_comuni[i,j] then RICHIESTE_PER_COMUNE[i, strade] = 0 \/ RICHIESTE_PER_COMUNE[j, strade] = 0 endif
  );

% almeno 1.000.000 per tipologia: la spesa minima è di 5.000.000.
constraint
  forall(j in RICHIESTE) (
    sum(i in COMUNI) (RICHIESTE_PER_COMUNE[i,j]) > 1000
  );

% al massimo 10.000.000
var int: somma = sum(i in COMUNI, j in RICHIESTE) (RICHIESTE_PER_COMUNE[i,j]);

var int: non_erogate = 0;

constraint
  somma <= 10000;

% scuole: se la media delle richieste per le scuole è > 

% energia: se una città ha chiesto finanziamenti per tutti gli altri progetti e ha meno di 20.000 abitanti, non viene concesso il finanziamento
constraint
  forall(i in COMUNI)(
    forall(r in {strade, fiumi, scuole, parchi})
      (RICHIESTE_PER_COMUNE[i, r] > 0) /\ abitanti_per_comune[i] < 20 -> RICHIESTE_PER_COMUNE[i, energia] = 0          
  );

% parchi: 

% GOAL
% massimizzare spesa: 5.000.000 <= spesa <= 10.000.000
% minimizzare numero di richieste non erogate

solve maximize somma
