#!/bin/bash

for t in tests/test_*.spk; do
    ./runtest.sh "$t"
done
