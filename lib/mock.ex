defmodule DialyzerSlow.Mock do
  @moduledoc false

  alias DialyzerSlow.Mock

  defmodule Resource do
    @moduledoc false
    defstruct tags: []
  end

  defmodule Tag do
    @moduledoc false
    defstruct name: nil, value: nil, sub_tags: []
  end

  defstruct resources: []

  def make_res_data do
    owners = ["x", "y", "z"]

    resources =
      ["us", "eu"]
      |> Enum.map(fn country ->
        Enum.map(["a", "b", "c"], fn city ->
          Enum.map(["0", "1", "2", "4"], fn number ->
            1..100
            |> Enum.map(fn _ -> ?a..?z |> Enum.take_random(10) |> List.to_string() end)
            |> Enum.map(fn address ->
              %Tag{
                name: "country",
                value: country,
                sub_tags: [
                  %Tag{
                    name: "city",
                    value: "#{country}-#{city}",
                    sub_tags: [
                      %Tag{
                        name: "number",
                        value: "#{country}-#{city}-#{number}",
                        sub_tags: [%Tag{name: "address", value: address}]
                      }
                    ]
                  }
                ]
              }
            end)
          end)
        end)
      end)
      |> List.flatten()
      |> Enum.map(fn tag ->
        %Resource{
          tags:
            owners
            |> Enum.take_random(1)
            |> Enum.map(fn owner -> %Tag{name: "owner", value: owner} end)
            |> Enum.concat([
              %Tag{name: "k1", value: "v1"},
              %Tag{name: "k2", value: "v2"},
              tag
            ])
        }
      end)

    %Mock{resources: resources}
  end
end
