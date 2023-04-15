# Autopilot Contracts

[![Test smart contracts](https://github.com/pcaversaccio/hardhat-project-template-ts/actions/workflows/test-contracts.yml/badge.svg)](https://github.com/pcaversaccio/hardhat-project-template-ts/actions/workflows/test-contracts.yml)

[All Commands](./README-ALL-COMMANDS.md)

## Deployment

:warning: Only goerli is configured

1. Add MNEMONIC in env
2. `yarn deploy:goerli`
3. `npx hardhat verify --network goerli contractAddress "0x0576a174D229E3cFA37253523E645A78A0C91B57"`

Factory Deployed Address: 0x7c7FBb99431050bbbe532712cD331105D461C5B7

## Tests

`forge test`
