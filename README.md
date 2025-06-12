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

Test can now be run with:

```sh
npm test
```

To check the circuits are valid run:

```sh
npm run check
```

To compile the circuits to R1CS, Sym, JSON, WASM and C, run:

```sh
npm run build
```

To prepare zkeys for the trusted setup, run:

```sh
./scripts/prepare_ceremony # Use --help for more options
```

## License

See [License.md](License.md) for details.
