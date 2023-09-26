% Richieste
intervento(strade).
intervento(fiumi).
intervento(scuole).
intervento(parchi).
intervento(energia).

% Città
citta(perugia).
citta(terni).
citta(foligno).
citta(citta_di_castello).
citta(spoleto).
citta(gubbio).
citta(assisi).
citta(corciano).
citta(bastia_umbra).
citta(orvieto).
citta(marsciano).
citta(narni).
citta(umbertide).
citta(todi).
citta(castiglione_del_lago).
citta(magione).
citta(gualdo_tardino).
citta(amelia).
citta(san_giustino).

% Abitanti per città
abitanti(perugia,161).
abitanti(terni,106).
abitanti(foligno,55).
abitanti(citta_di_castello,38).
abitanti(spoleto,36).
abitanti(gubbio,30).
abitanti(assisi,27).
abitanti(corciano,21).
abitanti(bastia_umbra,21).
abitanti(orvieto,19).
abitanti(marsciano,18).
abitanti(narni,17).
abitanti(umbertide,16).
abitanti(todi,15).
abitanti(castiglione_del_lago,15).
abitanti(magione,14).
abitanti(gualdo_tardino,14).
abitanti(amelia,11).
abitanti(san_giustino,11).

% Città connesse da strade
connesse(perugia,corciano).
connesse(perugia,bastia_umbra).
connesse(perugia,marsciano).
connesse(perugia,umbertide).
connesse(terni,spoleto).
connesse(terni,narni).
connesse(foligno,assisi).
connesse(citta_di_castello,umbertide).
connesse(citta_di_castello,san_giustino).
connesse(spoleto,terni).
connesse(gubbio,umbertide).
connesse(gubbio,gualdo_tardino).
connesse(assisi,foligno).
connesse(assisi,bastia_umbra).
connesse(corciano,perugia).
connesse(corciano,magione).
connesse(bastia_umbra,perugia).
connesse(bastia_umbra,assisi).
connesse(orvieto,todi).
connesse(marsciano,perugia).
connesse(marsciano,todi).
connesse(narni,terni).
connesse(narni,amelia).
connesse(umbertide,perugia).
connesse(umbertide,citta_di_castello).
connesse(umbertide,gubbio).
connesse(todi,orvieto).
connesse(todi,marsciano).
connesse(todi,amelia).
connesse(castiglione_del_lago,magione).
connesse(magione,corciano).
connesse(magione,castiglione_del_lago).
connesse(gualdo_tardino,gubbio).
connesse(amelia,narni).
connesse(amelia,todi).
connesse(san_giustino,citta_di_castello).

% Vincoli

richiesta(perugia, strade, 1).
richiesta(corciano, strade, 2).
richiesta(todi, strade, 6).

% Spesa totale: 5.000.000 < S < 10.000.000
spesa_totale(T) :- T = #sum{S : richiesta(_, _, S)}.
:- spesa_totale(T), T > 10, T < 5.

% Almeno una richiesta approvata
:- citta(C), not {richiesta(C, _, S)} > 0.

% Se due città sono connesse, non possono richiedere entrambe strade
approvata(C1, strade, S1) :- citta(C1), citta(C2), C1 < C2, connesse(C1, C2), 
    richiesta(C1, strade, S1), S1 > 0,
    richiesta(C2, strade, S2), S2 > 0.

#show approvata/3.