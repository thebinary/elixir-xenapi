defmodule XenAPI do
  @moduledoc """
  Collection Module for XenAPI resources.
  """

  import XenAPI.Generate

  get_resource_list()
  |> Enum.filter(fn x -> x != "session" end)
  |> Enum.map(fn resource ->
    module_name = cond do
      String.first(resource) !=  String.upcase(String.first(resource)) -> String.capitalize(resource)
     true -> resource
    end
    messages = get_resource_messages(resource)
    IO.puts("Generating #{module_name}")
    defresource module_name, messages
  end)

end
