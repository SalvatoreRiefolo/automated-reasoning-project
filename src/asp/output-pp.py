#!/usr/bin/env python3

import sys
import re

data = sys.stdin.read()

result = re.findall('ANSWER(.*)COST', data, flags=re.S)
parts = result[0].split(' ')

print(data)
print("\n-----\n\nResults:\n\n")
[print(f"%> {s}") for s in sorted(map(str.strip, parts))]