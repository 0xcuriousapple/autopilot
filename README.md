# AutoPilot Contracts
### For Client : [AutoPilot Client](https://github.com/abhishekvispute/autopilot-client) 
### For Bot : [AutoPilot Bot](https://github.com/abhishekvispute/autopilot-bot)

![Autopilot](https://user-images.githubusercontent.com/46760063/232172915-276c8dfb-83fb-49c6-9744-dacb7804b721.jpg)
## Deployment

:warning: Only goerli is configured

1. Add MNEMONIC in env
2. `yarn deploy:goerli`
3. `npx hardhat verify --network goerli contractAddress "0x0576a174D229E3cFA37253523E645A78A0C91B57"`

Factory Deployed Address: `0x7c7FBb99431050bbbe532712cD331105D461C5B7` </br>

**Account Verification** 

Proxy: 

Implementation
`npx hardhat verify --network goerli contractAddress "0x0576a174D229E3cFA37253523E645A78A0C91B57" "FactoryAddress"`

## Tests

`forge test` </br></br>
[![Tests](https://github.com/pcaversaccio/hardhat-project-template-ts/actions/workflows/test-contracts.yml/badge.svg)](https://github.com/pcaversaccio/hardhat-project-template-ts/actions/workflows/test-contracts.yml)
