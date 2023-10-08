# https://stackoverflow.com/questions/18659858/generating-a-list-of-random-numbers-summing-to-1

from pprint import pprint
import numpy as np
import math
import argparse


tipologie = {
    0: "strade",
    1: "fiumi",
    2: "scuole",
    3: "parchi",
    4: "energia"
}

comuni = [
    "perugia",
    "terni",
    "foligno",
    "citta_di_castello",
    "spoleto",
    "gubbio",
    "assisi",
    "corciano",
    "bastia_umbra",
    "orvieto",
    "marsciano",
    "narni",
    "umbertide",
    "todi",
    "castiglione_del_lago",
    "magione",
    "gualdo_tardino",
    "amelia",
    "san_giustino"
]

N_RICHIESTE = 5
N_COMUNI = len(comuni)
N_RICHIESTE_TOTALI = N_COMUNI * N_RICHIESTE


def genera_richieste(n):
    for _ in range(n):
        richieste = np.random.dirichlet(
            np.ones(N_RICHIESTE_TOTALI), size=1).flatten().tolist()

        richieste_arr = [math.floor(r * 10_000_000) for r in richieste]

        print(sum(richieste_arr))

        yield [richieste_arr[i:i + N_RICHIESTE]
               for i in range(0, len(richieste_arr), N_RICHIESTE)]


def genera_indici_casuali():
    n_richieste_da_modificare = math.floor(np.random.rand(1) * N_COMUNI)
    return np.random.choice(
        N_COMUNI, n_richieste_da_modificare, replace=False).tolist()


def azzera_strade_casuali(richieste):
    indici_comuni = genera_indici_casuali()
    r = list(richieste)
    for c in indici_comuni:
        r[c][0] = 0

    return r


def azzera_richieste_casuali(richieste):
    indici_comuni = genera_indici_casuali()

    indici_richieste = np.random.choice(
        N_RICHIESTE, len(indici_comuni)).tolist()

    r = list(richieste)
    for i, c in enumerate(indici_comuni):
        r[c][indici_richieste[i]] = 0

    return r


# batch_casuale = genera_richieste(10)
# batch_strade_azzerate = [azzera_strade_casuali(
#     r) for r in genera_richieste(1)]

# batch_richieste_azzerate = [azzera_richieste_casuali(
#     r) for r in genera_richieste(1)]

# pprint(np.matrix(batch_richieste_azzerate[0]))

# TODO: sommare cifre azzerate per mantenere il totale

def asp_formatter(richieste):
    # formato: [| icecream, 1200, 50, 10, 120, 400
    #           | ... |]
    formattate = []
    for i, row in enumerate(richieste):
        regole = [
            f'richiesta({comuni[i]}, {tipologie[j]}, {r}).' for j, r in enumerate(row)]
        formattate.append('\n'.join(regole) + '\n')

    return formattate


def minizinc_formatter(richieste):
    # formato richiesta(citta, richiesta, costo).
    formattate = ['strade_tra_comuni = [\n']
    for i, row in enumerate(richieste):
        costi = ', '.join([str(r) for r in row])
        regola = f'\t{comuni[i]}, {costi} |\n'
        formattate.append(regola)

    formattate.append('|];')
    return formattate


def scrivi_output(nome_file, formatter):
    with open(nome_file, 'w') as f:
        richieste = formatter(list(genera_richieste(1))[0])
        for line in richieste:
            f.write(line)


if __name__ == "__main__":
    MINIZINC = "mzn"
    ASP = "lp"

    parser = argparse.ArgumentParser("Generatore benchmark inputs")
    parser.add_argument('-f', '--format', type=str, choices=[MINIZINC, ASP])

    opts = parser.parse_args()

    if opts.format == MINIZINC:
        scrivi_output('minizinc/benchmarks/input.dzn', minizinc_formatter)
    elif opts.format == ASP:
        scrivi_output('asp/input.lp', asp_formatter)
