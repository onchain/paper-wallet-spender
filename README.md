# Paper Wallet Spender

The paper wallet spender takes private keys and generates a spend transaction to transfer funds out of the wallet.

The transction transfers 1% of the funds to the developer. This helps us maintain the project.

Requires Python 3.7 for zcash blake2b support.

wget https://www.python.org/ftp/python/3.7.0/Python-3.7.0.tgz
tar xzvf Python-3.7.0.tgz
cd Python-3.7.0
./configure
make
sudo cp python /usr/bin/python3

## Installation

We will make binaries available soon.

## Build and Install

We will make binaries available soon.

## Usage

1. Install the Crystal language, https://crystal-lang.org/docs/installation/
2. Clone this repository
3. CD into the folder

## Development

1. We recommend you install sentry to build and watch files. https://github.com/samueleaton/sentry
2. ./sentry -w "./src/**/*.cr" -w "./spec/**/*.cr" -r "crystal" --run-args "spec --debug"
3. Edit code and save, sentry will compile the code and run the tests.

## Contributing

1. Fork it ( https://github.com/[your-github-name]/paper-wallet-spender/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[your-github-name]](https://github.com/[your-github-name]) John Doe - creator, maintainer
