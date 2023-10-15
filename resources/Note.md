# CONSEGNA

    PNRR

    La comunità europea finanzia i progetti PNRR a cui possono partecipare i comuni con più di 10.000 abitanti. Si consideri una regione (per esempio la Puglia) o un suo sottoinsieme. Basandosi su wikipedia, google maps o simili, si crei un vettore con le città selezionate il numero di abitanti (in migliaia, troncato) e un grafo che dice se c'è un collegamento diretto tra i comuni selezionati (voglio dire, se per andare da A a C si passa per B, o vicinissimi a B, collegheremo A-B e B-C ma non A-C direttamente). Metti questi dati nella relazione.

    Il PNRR consiste in 10 Milioni di Euro complessivo per 5 tipologie di interventi: scuole, strade, energie rinnovabili, parchi giochi, sistemazione di torrenti/fiumi. Non vi è una divisione a monte dei fondi per tipologia ma almeno 1 Milione per tipologia va erogato.

    I dati di input sono l'elenco città e i progetti richiesti (al massimo uno per tipologia) e i costi richiesti. Si vuole allocare al meglio la quoat di 10 Milioni in modo tale che
    • Se due comuni sono collegati nel grafo l'intervento sulle strade sarà finanziato al massimo a uno dei due.
    • Le richieste possono essere approvate come sono o ridotte del 10%, del 20% o del 30%.
    • Ad ogni comune sia approvato almeno un progetto.
    • I 10 Milioni vanno usati il più possibile (magari per ragioni di somme non si arriva esattamente a 10 ma ci dobbiamo andare vicino).
    • Per scuole, energie rinnovabili e parchi giochi, si rigettano progetti troppo esosi. Come calcoliamo se sono esosi? Puoi usare la fantasia. Ad esempio, per le scuole. Consideriamo la media delle cifre richieste per le scuole FRATTO il numero di abitanti per quella città. Se sono oltre il doppio della media vengono cassate.
    • Puoi aggiungere altri vincoli Hard se ti sembrano ragionevoli.
    • A parità di vincoli hard, minimizza la somma di richieste non erogate (ovvero la cifra dei progetti bocciati e le cifre ridotte del 10, 20, 30%)

    Write a Minizinc and an ASP program capable of finding a solution to the
    following  problem.
    Prepare a battery of 30 benchmark instances.
    Generate them randomly but prepare some easy/small instances (a couple
    of running time seconds),
    some average instances (a couple of minutes) and some hard instances
    (exceeding timeout).

    Run both the Minizinc and the ASP encoding on all the instances,
    possibly exploring different search strategies,
    with a timeout of 5 minutes for each test
    (``configuration'' option in Minizinc, --time-limit option in clingo, in
    both cases you can use linux tricks)

    In case of COPs, report the best value for the solution found within the
    timeout.

    Write a short report (5-10) pages report containing
    1) the problem as written above
    2) your models (and the reasons for some choices),
    3) a presentation of the execution results.

    Prepare the programs and the benchmark instances used in a unique zip file.

---

## Tipi di richiesta

- STRADE
- FIUMI
- SCUOLE
- ENERGIE
- PARCHI

## Input

- elenco città
- progetti con costo richiesti
- n. abitanti (totale: 945.000)

## Vincoli

- se città sono adiacenti & entrambe richiedono STRADE, approva al massimo ad una delle due
- ogni comune richiede almeno un progetto e viene approvato almeno un progetto
- almeno 1 milione erogato per tipologia
- al massimo 10 milioni

- richieste possono essere approvate come sono o ridotte di 10/20/30%
- si rifiutano richieste troppo costose (definire criteri)

## Obiettivo

- massimizzare spesa <= 10.000.000
- minimizzare somma delle richieste non erogate/ridotte

---

# Note implementazione

### Scuole:

mean = 100.000
2mean = 200.000

req: 150.000 ratio: 100.000/161.000 = 0.62
req: 50.000 ratio: 100.000/55.000 = 1.81
req: 100.000 ratio: 100.000/20.000 = 5

{
mean = sum(requests)
mean2 = 2*mean

    forall cities:
        ratio = mean / city.people
        if request * ratio > mean2 then reject

}

### Parchi:

se la spesa supera 2 volte la % di abitanti della citta rispetto alla somma delle richieste per i parchi non viene concesso il finanziamento
(people/all_people) \* sum(requests) > c.parks

### Energie:

se la somma di tutti i finanziamenti per una città, meno quello per energia, è 4 volte la spesa per l'energia , non viene concesso il finanziamento

sum(c.requests) - c.parks > 4 \* c.parks

### Istanze:

- 2 non risolvibili
- 5 facili
- 5 medie
- 5 difficili
- 13 random

## Script

    > minizinc --solver Chuffed -f --time-limit 300000 --output-time pnrr.mzn common.dzn benchmarks/input.dzn
    > clingo pnrr.lp common.lp benchmarks/input.lp

## Scratchpad

% strada tra c1 e c2
0 1 0
1 0 0
0 0 0

c1 c2 = 1; c1 c3 = 0;
c2 c1 = 1; c2 c3 = 0;
c3 c1 = 0; c3 c2 = 0;

V1 0; V1 V3;
0 V1; 0 V3; % INCONSITENZA, non c'è un path ed entrambe dovrebbero prendere il valore della richiesta.
