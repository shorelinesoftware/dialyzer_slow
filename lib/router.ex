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
