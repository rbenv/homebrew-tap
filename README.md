# Homebrew tap for ruby-build

## Installing Ruby 2.4 – 3.0

```sh
brew install rbenv/tap/openssl@1.1
rbenv install 3.0.7 -- --with-openssl-dir="$(brew --prefix openssl@1.1)"
```

> [!NOTE]
> Installing Ruby 3.0 on macOS 14+ is likely to fail with the error message:  
> `bigdecimal.c: error: 'maybe_unused' attribute cannot be applied to types`.  
> If that happens, this [upstream patch](https://github.com/ruby/ruby/commit/1dfe75b0beb7171b8154ff0856d5149be0207724) might help:
> ```sh
> curl -fsSL https://github.com/ruby/ruby/commit/1dfe75b0beb7171b8154ff0856d5149be0207724.patch | \
>   rbenv install 3.0.7 --patch -- --with-openssl-dir="$(brew --prefix openssl@1.1)"
> ```

## Installing Ruby 2.3 or older on macOS

```sh
brew install rbenv/tap/openssl@1.0
rbenv install 2.3.8 -- --with-openssl-dir="$(brew --prefix openssl@1.0)"
```
