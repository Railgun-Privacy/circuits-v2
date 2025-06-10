# Circuits V2
ZK-SNARK circuits for RAILGUN

## Artifact verification
Circom compiler version used was `2.0.6`

Circomlib version used was `2.0.5`

## Scripts

First run:

```sh
npm install
```

To install a local version of the circom compiler at the target version above, run:

```sh
./scripts/fetch_circom
```

To generate all valid permutations of inputs x outputs run:

```sh
./scripts/generate_circuits
```

To check the circuits are valid run:

```sh
./scripts/check_circuits
```

To compile the circuits to R1CS, Sym, JSON, WASM and C, run:

```sh
./scripts/compile_circuits
```


To prepare zkeys for the trusted setup, run:

```sh
./scripts/prepare_ceremony
```

## License

See [License.md](License.md) for details.
