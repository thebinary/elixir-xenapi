defmodule XenAPI do
  @moduledoc """
  Collection Module for XenAPI resources.

  After compiled modules generation the resources will be available as module `XenAPI.<resource>`.

  For eg: for `VM` resource the module will be `XenAPI.VM` and `VM.get_all` function will be
  available as `XenAPI.VM.get_all`
  """

  import XenAPI.Generate

  # Generate XenAPI resource modules to be compiled. (skipping "session" resource)
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
