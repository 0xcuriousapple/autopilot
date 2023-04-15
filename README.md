# AutoPilot Contracts
### For Client : [AutoPilot Client](https://github.com/abhishekvispute/autopilot-client) 
### For Bot : [AutoPilot Bot](https://github.com/abhishekvispute/autopilot-bot)

![Autopilot](https://user-images.githubusercontent.com/46760063/232250693-309424cc-00d5-41e2-9e54-68e09a000fab.jpg)

This project builds upon the concept of account abstraction, enabling users to seamlessly automate future actions for their wallets. Each account consists of two distinct actors: the owner, who is the user themselves, and a bot.
The owner grants the bot permission to perform a specified range of actions, which are executed according to a predetermined schedule and interval. By automating these tasks, the bot efficiently carries out the owner's desired actions without necessitating the owner's intervention moving forward.
The system is non-custodial, as funds remain solely in your wallet. Furthermore, it is permissionless, as the bot can only perform actions explicitly permitted by the user.

We use ERC4337 contracts and extends them. We override the validateSignature method to accommodate signatures from both the owner and the bot, ensuring the signer's identity is recorded. Later, during the execution process, we permit only the authorized actions for each party according to their respective schedules, while allowing the owner to perform all actions.
Our client incorporates the Account Abstraction SDK, and we use StackUp as our bundler. The contracts have been deployed on both Görli and Polygon Mumbai networks. The rationale behind deploying on Polygon is the reduced gas costs associated with highly active bots. We believe that for intricate bot strategies, affordable gas prices are crucial

### [Presentation](https://www.canva.com/design/DAFgEAZu_ok/05yy8N_N6BOtS37AkaDVuA/edit?utm_content=DAFgEAZu_ok&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton)

### [Demo](https://youtu.be/97zefOnTsAU)

## Deployment

1. Add MNEMONIC in env
2. `yarn deploy:network`
3. `npx hardhat verify --network "network" contractAddress "0x0576a174D229E3cFA37253523E645A78A0C91B57"`

Factory Deployed Address: </br>
Goerli: `0x7c7FBb99431050bbbe532712cD331105D461C5B7` </br>
Polygon Mumbai: `0xEd069d7fD0BAf7Ab8F9c43cE809B1E3a2B271F8d`

Example Accounts:</br> 
Goerli: `0xe670d4245f776ef9a0f3278a57ad11da5f8cbe67` </br>
Polygon Mumbai: `0x26f15e27214e59bbc1269086644f76ea461cac35`

## Account Verification 

Proxy: 

Implementation
`npx hardhat verify --network "network" contractAddress "0x0576a174D229E3cFA37253523E645A78A0C91B57" "FactoryAddress`

## Tests

`forge test` </br></br>
[![Tests](https://github.com/pcaversaccio/hardhat-project-template-ts/actions/workflows/test-contracts.yml/badge.svg)](https://github.com/pcaversaccio/hardhat-project-template-ts/actions/workflows/test-contracts.yml)
