% Vincoli

% Per ogni richiesta, questa può essere approvata al più una volta
0 {approvata(C, I, R, M): richiesta(C, I, R)} 1 :- citta(C), intervento(I), moltiplicatore(M).


%1 {richiesta_scalata(C, I, S): richiesta(C, I, R)} 1 :- citta(C), intervento(I), moltiplicatore(M), S = R * M.

:- citta(C), {richiesta(C, _, _)} < 1.      % Almeno una richiesta per città
:- citta(C), {approvata(C, _, _, _)} < 1.   % Almeno una richiesta per città approvata

% Strade: se due città sono connesse, non possono richiedere entrambe l'intevento
:- citta(C1), citta(C2), moltiplicatore(M), connesse(C1, C2), approvata(C1, strade, S1, M), approvata(C2, strade, S2, M).

% Energia: la richiesta deve essere minore a 2 volte la somma delle altre richieste per la città. 
somma_non_energia(C, S) :- citta(C), S = #sum{A, I : richiesta(C, I, A), I != energia}. % Somma delle richieste di una città, esclusa energia

:- citta(C), richiesta(C, energia, A), moltiplicatore(M), approvata(C, energia, A, M), 
   somma_non_energia(C, S), (2 * A) > S.

% Parchi: ogni città non può richiedere più di 10.000.000/n_comuni euro.
numero_citta(N) :- N = #count{ C : citta(C)}.

:- citta(C), richiesta(C, parchi, A), moltiplicatore(M), approvata(C, parchi, A, M),
   numero_citta(N), A > richiesta_massima / N.

% Scuole
somma_richiesta(I, S) :- intervento(I), S = #sum{A : richiesta(_,I,A)}.             % Somma delle spese di tutti i comuni per una certa richiesta
conta_citta(CC) :- CC = #count{C : citta(C)}.                                       % Numero totale delle città
media(I, M) :- intervento(I), somma_richiesta(I, S), conta_citta(CC), M = S / CC.   % Media spese per una tipologia di intervento tra tutte le città
rapporto(M, C, R) :- citta(C), media(_, M), abitanti(C, A), R = M / A.              % Spesa media per abitante

:-  citta(C), richiesta(C, scuole, S), moltiplicatore(M), approvata(C, scuole, S, M),
    media(scuole, M),
    rapporto(M, C, R),
    S * R >  2 * M.

% Il numero di richieste cassate.
quantita_ridotte(N) :- N = #count{ M : approvata(_, _, _, M), M != 1 }.

n_richieste(N) :- N = #count {A, I: richiesta(_, I, A)}.
n_approvate(N) :- N = #count {A, I: approvata(_, I, A, _)}.
quantita_non_approvate(NA) :- n_richieste(N), n_approvate(M), NA = N-M.

richiesta_scalata(I, V) :- intervento(I), approvata(_,I, R, M), V = R * M.
spesa_totale(T) :- T = #sum{S, C, I : richiesta(C, I, S)}.
totale_scalato(T) :- T = #sum {V: richiesta_scalata(_, V)}.

% Spesa totale: 5.000.000 < S < 10.000.000
:- totale_scalato(T), T > richiesta_massima.

% Spesa minima intervento: 1.000.000
totale_intervento(I, T) :- intervento(I), T = #sum{V: richiesta_scalata(I, V)}.
:- intervento(I), totale_intervento(I, T), T < richiesta_minima_intervento.

#show n_richieste/1.
#show n_approvate/1.
#show spesa_totale/1.
#show totale_scalato/1.
#show quantita_ridotte/1.
#show quantita_non_approvate/1.
#show approvata/4.
#show totale_intervento/2.

#maximize { T : totale_scalato(T) }.
#minimize { R + NA: quantita_ridotte(R), quantita_non_approvate(NA) }.