% Vincoli

% Per ogni richiesta, questa può essere approvata al più una volta
0 {approvata(C, I, R, M): richiesta(C, I ,R)} 1 :- citta(C), intervento(I), moltiplicatore(M).

% Spesa totale: 5.000.000 < S < 10.000.000
spesa_totale(T) :- T = #sum{S : richiesta(_, _, S)}.
:- spesa_totale(T), T > 10000000, T < 5000000.

% Almeno una richiesta per città
:- citta(C), {richiesta(C, _, _)} < 1.

% Almeno una richiesta per città approvata
:- citta(C), {approvata(C, _, _, _)} < 1.

% Strade: se due città sono connesse, non possono richiedere entrambe strade
approvata(C1, strade, S1, M) :- citta(C1), citta(C2), C1 < C2, connesse(C1, C2), 
    moltiplicatore(M),
    richiesta(C1, strade, S1),
    richiesta(C2, strade, S2),
    S1 > 0,
    S2 > 0,
    not approvata(C2, strade, S2, M).

% Energia: la richiesta deve essere minore a 4 volte la somma delle altre richieste per la città. 
somma_non_energia(C, S) :- citta(C), S = #sum{A : richiesta(C, R, A), R != energia}. % Somma delle richieste di una città, esclusa energia

approvata(C, energia, A, M) :-
    citta(C), richiesta(C, energia, A), moltiplicatore(M),
    somma_non_energia(C, S),
    S <= 4 * A.

% Parchi: ogni città non può richiedere più di 10.000.000/n_comuni euro.
numero_citta(N) :- N = #count{ C : citta(C)}.

approvata(C, parchi, S, M) :- 
    moltiplicatore(M), citta(C), richiesta(C, parchi, S),
    numero_citta(N),
    S < 10000000 / N.

% Fiumi: ogni città non può richiedere più di 2 volte il totale delle richieste dei fiumi, 
% moltiplicato per la percentuale di abitanti della città rispetto alla regione
numero_abitanti(N) :- N = #sum{ A : abitanti(_, A) }.
richiesta_totale_fiumi(TF) :- TF = #sum{ S : richiesta(_, fiumi, S) }.

approvata(C, fiumi, S, M) :-
    moltiplicatore(M), citta(C), richiesta(C, fiumi, S),
    abitanti(C, N),
    numero_abitanti(A),
    richiesta_totale_fiumi(TF),
    S < (N / A) * 2 * TF.

% Scuole
somma_richiesta(I, S) :- intervento(I), S = #sum{A : richiesta(_,I,A)}.             % Somma delle spese di tutti i comuni per una certa richiesta
conta_citta(CC) :- CC = #count{C : citta(C)}.                                       % Numero totale delle città
media(I, M) :- intervento(I), somma_richiesta(I, S), conta_citta(CC), M = S / CC.   % Media spese per una tipologia di intervento tra tutte le città
ratio(M, C, R) :- citta(C), media(_, M), abitanti(C, A), R = M / A.                 % Spesa media per abitante

approvata(C, scuole, S, M) :- 
    citta(C), richiesta(C, scuole, S), moltiplicatore(M), 
    media(scuole, M),
    ratio(M, C, R),
    S * R <=  2 * M.

% Il numero di richieste cassate. TODO contare quelle non approvate
quantita_cassate(N) :- N = #count{ M : approvata(_, _, _, M), M != 1 }.

richiesta_scalata(V) :- approvata(_,_,R, M), V = R * M.
totale_scalato(T) :- T = #sum {V: richiesta_scalata(V)}.

#show spesa_totale/1.
#show totale_scalato/1.
#show approvata/4.

#maximize { T : totale_scalato(T) }.
#minimize { N : quantita_cassate(N) }.
