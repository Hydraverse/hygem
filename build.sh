#!/usr/bin/bash -xe
solc --combined-json='bin,hashes' --pretty-json --evm-version constantinople --optimize @openzeppelin/=./openzeppelin/ -o build/ contracts/*.sol --overwrite
