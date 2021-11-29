#!/usr/bin/bash -xe
solc --combined-json='bin,hashes' --abi --pretty-json --evm-version constantinople --optimize --overwrite \
    @openzeppelin/=./openzeppelin/ \
    -o build/ \
    contracts/hydragem/hydragem.sol
