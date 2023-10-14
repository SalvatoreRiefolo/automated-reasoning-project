# https://stackoverflow.com/questions/18659858/generating-a-list-of-random-numbers-summing-to-1

import numpy as np
import math
import argparse
from random import sample


MINIZINC = "mzn"
ASP = "lp"

REQUEST_TYPES = {0: "strade", 1: "fiumi",
                 2: "scuole", 3: "parchi", 4: "energia"}

CITIES = [
    ("perugia", 0),
    ("terni", 1),
    ("foligno", 2),
    ("citta_di_castello", 3),
    ("spoleto", 4),
    ("gubbio", 5),
    ("assisi", 6),
    ("corciano", 7),
    ("bastia_umbra", 8),
    ("orvieto", 9),
    ("marsciano", 10),
    ("narni", 11),
    ("umbertide", 12),
    ("todi", 13),
    ("castiglione_del_lago", 14),
    ("magione", 15),
    ("gualdo_tardino", 16),
    ("amelia", 17),
    ("san_giustino", 18),
]

ROADS = [
    [0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1],
    [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0],
    [0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
    [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0],
    [1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
]

N_REQUESTS = 5
N_CITIES = len(CITIES)
CITIZENS_PER_CITY = [161, 106, 55, 38, 36, 30, 27,
                     21, 21, 19, 18, 17, 16, 15, 15, 14, 14, 11, 11]


def generate_requests(n_cities, requests_to_zero):
    requests = (
        np.random.dirichlet(np.ones(N_REQUESTS * n_cities),
                            size=1).flatten().tolist()
    )
    scaled_requests = [math.floor(r * 10_000) for r in requests]

    r = [
        scaled_requests[i: i + N_REQUESTS]
        for i in range(0, len(scaled_requests), N_REQUESTS)
    ]

    if requests_to_zero != 0:
        return zero_random_requests(r, requests_to_zero)

    return r


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
    indices = np.nonzero(requests)
    to_add = math.floor(to_spread / len(indices[0]))

    r = list(requests)
    for row, col in zip(indices[0], indices[1]):
        r[row][col] += to_add

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
    shuffled_cities = sample(CITIES, len(requests))

    for c in shuffled_cities:
        formatted.append(f"citta({c[0]}).\n")

    formatted.append("\n")

    for i, row in enumerate(requests):
        rule = [
            f"richiesta({shuffled_cities[i][0]}, {REQUEST_TYPES[j]}, {r})."
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
    shuffled_cities = sample(CITIES, len(requests))
    city_indices = list(map(lambda c: c[1], shuffled_cities))

    formatted = ["COMUNI = {\n"]
    for city in shuffled_cities:
        formatted.append(f"\t{city[0]},\n")
    formatted.append("};\n")

    formatted.append(f"\nNUMERO_COMUNI = {len(shuffled_cities)};\n")

    abitanti = "\nABITANTI_PER_COMUNE = ["
    n_abitanti = [CITIZENS_PER_CITY[i] for i in city_indices]
    abitanti += ", ".join(list(map(str, n_abitanti)))
    abitanti += "];\n"

    formatted.append(abitanti)

    restricted_roads = get_roads(city_indices)
    formatted.append(to_minizinc_matrix(
        restricted_roads, "STRADE_TRA_COMUNI", lambda x: str(bool(x)).lower()))

    formatted.append(to_minizinc_matrix(
        requests, "RICHIESTE", lambda x: str(int(x))))

    return formatted


def to_minizinc_matrix(matrix, name, converter):
    formatted = []
    formatted.append(f"\n{name} = [|\n")
    for v in matrix:
        row = ", ".join(map(converter, v))
        rule = f"\t{row} |\n"
        formatted.append(rule)

    formatted.append("|];\n")
    return "".join(formatted)


def get_roads(city_indices):
    reduced_road_map = []
    for i in city_indices:
        city_roads = []
        for j in city_indices:
            city_roads.append(ROADS[i][j])
        reduced_road_map.append(city_roads)

    return reduced_road_map


def write_output(file_name, requests, fmt):
    with open(file_name, "w") as f:
        formatted = fmt(requests)
        for line in formatted:
            f.write(line)


def run(file_name, batch_size, request_count, zero_requests, format):
    for i in range(batch_size):
        fn = f"{file_name}{i+1}"
        requests = generate_requests(request_count, zero_requests)

        if format == MINIZINC:
            write_output(
                f"../minizinc/benchmarks/{fn}.dzn", requests, minizinc_formatter)
        elif format == ASP:
            write_output(f"../asp/benchmarks/{fn}.lp", requests, asp_formatter)

    print(
        f"Written n={batch_size} input files with name '{file_name}(n).{format}'\tRequests per file: {request_count}")


if __name__ == "__main__":

    parser = argparse.ArgumentParser("Generatore benchmark inputs")
    parser.add_argument("--full", action="store_true")
    parser.add_argument("-n", "--name", type=str, default="input")
    parser.add_argument("-f", "--format", type=str, choices=[MINIZINC, ASP])
    parser.add_argument("-b", "--batch-size", type=int, default=1)
    parser.add_argument("-z", "--zeroes", type=int, default=0)
    parser.add_argument(
        "-c", "--count", type=int, default=N_CITIES, choices=range(1, N_CITIES)
    )

    opts = parser.parse_args()
    print(opts)
    if opts.full:
        for fmt in [MINIZINC, ASP]:
            run("small", 10, 3, 0, fmt)
            run("medium", 10, 10, 0, fmt)
            run("large", 10, N_CITIES, 0, fmt)
    else:
        run(opts.name, opts.batch_size, opts.count, opts.zeroes, opts.format)
