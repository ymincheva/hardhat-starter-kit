# 🚀 Hardhat Starter Kit

Basic hardhat starter project kit with some added configuration and goodies.

## 💡 Some prerequisites

Node version: `18.6.0`

If you use another version, please use [n](https://github.com/tj/n) to manage.

Highly suggest to use `hardhat-shorthand` package for easier development.

```shell
npm install --global hardhat-shorthand
```

More info in official [Hardhat docs](https://hardhat.org/hardhat-runner/docs/guides/command-line-completion).

## 🛠 Installation

```shell
yarn
```

## ⚙️ Config

Copy the example `.env` file and add the needed credentials.

```shell
cp example.env .env
```

Register at [Infura](https://www.infura.io/) ot [Alchemy](https://www.alchemy.com/) to get the `PROVIDER_URL`.

Export your wallet private key to `WALLET_PRIVATE_KEY`.

Register at [Etherscan](https://etherscan.io/) to get `ETHERSCAN_API_KEY`.

## 🖋 Scripts

To compile contracts:

```shell
hh compile
```

To run tests:

```shell
hh test
```

To deploy contracts on Goerli testnet with script:

```shell
hh run scripts/deploy.js --network goerli
```
