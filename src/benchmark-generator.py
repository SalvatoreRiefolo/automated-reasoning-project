# https://stackoverflow.com/questions/18659858/generating-a-list-of-random-numbers-summing-to-1

import numpy as np
import math
import argparse
from random import sample

request_types = {0: "strade", 1: "fiumi", 2: "scuole", 3: "parchi", 4: "energia"}

cities = [
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
    "san_giustino",
]

N_REQUESTS = 5
N_CITIES = len(cities)
CITIZENS_PER_CITY = [161,106,55,38,36,30,27,21,21,19,18,17,16,15,15,14,14,11,11]

def generate_requests(n_cities):
    requests = (
        np.random.dirichlet(np.ones(N_REQUESTS * n_cities), size=1).flatten().tolist()
    )
    scaled_requests = [math.floor(r * 10_000_000) for r in requests]

    return [
        scaled_requests[i : i + N_REQUESTS]
        for i in range(0, len(scaled_requests), N_REQUESTS)
    ]


def get_random_indices(n_cities):
    n_requests_to_change = math.ceil(np.random.rand(1) * n_cities)
    return np.random.choice(n_cities, n_requests_to_change, replace=False).tolist()


def zero_random_roads(requests):
    city_indices = get_random_indices()
    r = list(requests)
    for c in city_indices:
        r[c][0] = 0

    return spread(r)


def zero_random_requests(requests, n_cities):
    city_indices = get_random_indices(n_cities)

    request_indices = np.random.choice(N_REQUESTS, len(city_indices)).tolist()

    tot = 0
    r = list(requests)
    for i, c in enumerate(city_indices):
        tot += r[c][request_indices[i]]
        r[c][request_indices[i]] = 0

    return spread(r, tot)


def spread(requests, to_spread):
    indices = []

    for i, r in enumerate(requests):
        for j, amount in enumerate(r):
            if amount != 0:
                indices.append((i, j))

    to_add = math.floor(to_spread / len(indices))

    r = list(requests)
    for index in indices:
        r[index[0]][index[1]] += to_add

    return r


def asp_formatter(requests):
    """
    formato: 
        citta(citta).
        ...
        richiesta(citta, intervento, costo).
        ...
    """
    formatted = []
    shuffled_cities = sample(cities, len(cities))

    for i, row in enumerate(requests):
        rule = [
            f"richiesta({shuffled_cities[i]}, {request_types[j]}, {r})."
            for j, r in enumerate(row)
        ]
        formatted.append("\n".join(rule) + "\n\n")

    return formatted


def minizinc_formatter(requests):
    """
    formato: 
        COMUNI: {c1, ...};
        ABITANTI_PER_COMUNE: [100, ...];
        RICHIESTE: [| 
            1200, 50, 10, 120, 400|
            ... 
        |];
        STRADE_TRA_COMUNI : [| 
            true, false, ...|
            ... 
        |];
    """
    formatted = ["COMUNI = {\n"]
    shuffled_cities = sample(cities, len(cities))
    for city in shuffled_cities[:len(requests)]:
        formatted.append(f"\t{city},\n")

    formatted.append("};\n")
    formatted.append("\nRICHIESTE = [|\n")
    for row in requests:
        amounts = ", ".join([str(r) for r in row])
        rule = f"\t{amounts} |\n"
        formatted.append(rule)

    formatted.append("|];")
    return formatted


def write_output(file_name, requests, fmt):
    with open(file_name, "w") as f:
        formatted = fmt(requests)
        for line in formatted:
            f.write(line)


if __name__ == "__main__":
    MINIZINC = "mzn"
    ASP = "lp"

    parser = argparse.ArgumentParser("Generatore benchmark inputs")
    parser.add_argument("-n", "--name", type=str, default="input")
    parser.add_argument("-f", "--format", type=str, choices=[MINIZINC, ASP])
    parser.add_argument("-b", "--batch", type=int, default=1)
    parser.add_argument(
        "-c", "--count", type=int, default=N_CITIES, choices=range(1, N_CITIES)
    )

    opts = parser.parse_args()
    for i in range(opts.batch):
        fn = f"{opts.name}{i+1}"
        requests = generate_requests(opts.count)

        if opts.format == MINIZINC:
            write_output(f"minizinc/benchmarks/{fn}.dzn", requests, minizinc_formatter)
        elif opts.format == ASP:
            write_output(f"asp/benchmarks/{fn}.lp", requests, asp_formatter)

# TODO rivedere formatter minizinc
# TODO aggiungere città a formatter asp