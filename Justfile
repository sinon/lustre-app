set dotenv-load

server:
        @gleam --version
        gleam run -m lustre/dev start

build:
        @gleam --version
        gleam run -m lustre/dev build app --minify
