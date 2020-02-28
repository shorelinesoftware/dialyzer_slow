# DialyzerSlow

Reproduce issue repo

## Elixir/Erlang version
mix hex.info
```
Hex:    0.20.5
Elixir: 1.9.4
OTP:    21.3.8

Built with: Elixir 1.9.4 and OTP 20.3
```

## Some testing results

Cmd: `mix dialyzer --halt-exit-status`

plt file is created before run each cases.

1. use `Plug.Router` to define a route with `Mock.make_res_data/0` takes around 2 minutes
```elixir
defmodule DialyzerSlow.Router do
  use Plug.Router

  alias DialyzerSlow.Mock

  @db %{"res" => Mock.make_res_data()}

  get "endpoint1" do
    res = Map.get(@db, "res")
    send_resp(conn, 200, inspect(res))
  end
end
```
2. use a normal function with `Mock.make_res_data/0` takes 20 around seconds
```elixir
defmodule DialyzerSlow.Router do
  alias DialyzerSlow.Mock

  @db %{"res" => Mock.make_res_data()}

  def get do
    Map.get(@db, "res")
  end
end
```
3. Use `Plug.Router` to define route without `Mock.make_res_data/0` takes around 1 second.
```elixir
defmodule DialyzerSlow.Router do
  use Plug.Router

  @db %{"res" => %{}}

  get "endpoint1" do
    res = Map.get(@db, "res")
    send_resp(conn, 200, inspect(res))
  end
end
```
4. use `Plug.Router` to define **3** routes with `Mock.make_res_data/0` takes around 6 minutes. (Current master)
```elixir
defmodule DialyzerSlow.Router do
  use Plug.Router

  alias DialyzerSlow.Mock

  @db %{"res" => Mock.make_res_data()}

  get "endpoint1" do
    res = Map.get(@db, "res")
    send_resp(conn, 200, inspect(res))
  end

  get "endpoint2" do
    res = Map.get(@db, "host")
    send_resp(conn, 200, inspect(res))
  end

  get "endpoint3" do
    res = Map.get(@db, "host")
    send_resp(conn, 200, inspect(res))
  end
end
```

