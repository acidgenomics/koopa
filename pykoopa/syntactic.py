#!/usr/bin/env python3

import re


# Kebab case.
# Updated 2019-10-06.
def kebab_case(x):
    x = re.sub("[^0-9a-zA-Z]+", "-", x)
    x = x.lower()
    return x


# Snake case.
# Updated 2019-10-06.
def snake_case(x):
    x = re.sub("[^0-9a-zA-Z]+", "_", x)
    x = x.lower()
    return x
