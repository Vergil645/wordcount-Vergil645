#!/usr/bin/env python3

import random
import string
import tempfile
import os


def rand_string(size):
    good_chars = string.ascii_lowercase + string.ascii_uppercase + string.digits
    return ''.join(random.choices(population=good_chars, k=size)).encode('utf-8')


def rand_spaces(size):
    return ''.join(random.choices(population=string.whitespace, k=size)).encode('utf-8')


def gen_file(words_cnt, front_spaces, back_spaces):
    file = tempfile.NamedTemporaryFile()
    if front_spaces:
        file.write(rand_spaces(random.randint(1, 10)))
    if words_cnt >= 1:
        file.write(rand_string(random.randint(1, 50)))
        for _ in range(words_cnt - 1):
            file.write(rand_spaces(random.randint(1, 50)))
            file.write(rand_string(random.randint(1, 50)))
    if back_spaces:
        file.write(rand_spaces(random.randint(1, 10)))
    file.flush()
    return file


def test(words_cnt, front_spaces, back_spaces):
    with gen_file(words_cnt, front_spaces, back_spaces) as file:
        real = os.popen(f'cat {file.name} | ./wordcount').read()
        if words_cnt != int(real):
            print(f'Expected {words_cnt} words, but counted {real}')
            exit(1)


def test_all_spaces(words_cnt):
    test(words_cnt, False, False)
    test(words_cnt, True, False)
    test(words_cnt, False, True)
    test(words_cnt, True, True)


random.seed(2517)
test_all_spaces(0)
for _ in range(100):
    cnt = random.randint(100, 5000)
    test_all_spaces(cnt)
