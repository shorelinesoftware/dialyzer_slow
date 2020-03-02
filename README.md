# DialyzerSlow

Reproduce issue repo, solved!

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

## Root casue
(Reply from Jose)
The issue is that `DialyzerSlow.Mock.make_res_data` actually generates a very large data structure. Since this structure may take a while to compute, you put it behind a module attribute, like this:

    @db %{"res" => Mock.make_res_data()}

And then you use it in multiple places:

    get "endpoint1" do
      res = Map.get(@db, "res")
      send_resp(conn, 200, inspect(res))
    end

The problem is, every time you access the `@db` module attribute, you are getting a full copy of the data-structure and injecting it into the source code. So if you use `@db` three times, it is three copies in memory and Dialyzer just spends an absurd amount of time trying to retrieve its full type.


### Solutions:
There are two possible solutions to the problem. One option is to fetch the data at runtime always but never at compile time:

```elixir
  get "endpoint1" do
    res = Map.get(db(), "res")
    send_resp(conn, 200, inspect(res))
  end

  defp db do
    Mock.make_res_data()
  end
```

Of course, this solution occurs a runtime cost now and it may not be what you want. A less radical alternative is to mix both solution so you at least inject `@db` only once:

```elixir
  get "endpoint1" do
    res = Map.get(db(), "res")
    send_resp(conn, 200, inspect(res))
  end

  @db %{"res" => Mock.make_res_data()}
  defp db, do: @db
```

This should limit the compilation time considerably (probably around 20s according to your initial benchmark). Another approach to consider is to also decrease the size of the data a bit.



