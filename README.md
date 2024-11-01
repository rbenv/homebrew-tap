# Homebrew tap for ruby-build

## Installing Ruby 2.4 – 3.0

```sh
brew install rbenv/tap/openssl@1.1
rbenv install 3.0.7 -- --with-openssl-dir="$(brew --prefix openssl@1.1)"
```

## Installing Ruby 2.3 or older on macOS

```sh
brew install rbenv/tap/openssl@1.0
rbenv install 2.3.8 -- --with-openssl-dir="$(brew --prefix openssl@1.0)"
```
