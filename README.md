# Homebrew tap for ruby-build

## Installing Ruby 2.3 or older on macOS

1. `brew install rbenv/tap/openssl@1.0`
2. `RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.0)" rbenv install 2.3.8`
