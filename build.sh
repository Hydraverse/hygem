#!/usr/bin/bash -xe
solc --combined-json='bin,hashes' --pretty-json --evm-version constantinople --optimize --overwrite \
    @openzeppelin/=./openzeppelin/ \
    -o build/ \
    contracts/hydragem/hydragem.sol
