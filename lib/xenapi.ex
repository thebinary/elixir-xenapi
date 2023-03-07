defmodule XenAPI do
  @moduledoc """
  Collection Module for XenAPI resources.

  After compiled modules generation the resources will be available as module `XenAPI.<resource>`.

  For eg: for `VM` resource the module will be `XenAPI.VM` and `VM.get_all` function will be
  available as `XenAPI.VM.get_all`
  """

  import XenAPI.Generate

  # Generate XenAPI resource modules to be compiled.
  data = get_json_spec()

  data
  |> get_resource_list
  |> Enum.map(fn resource ->
    module_name = resource |> Macro.camelize
    resource_def = data |> get_resource_def(resource)
    module_descr = resource_def |> get_resource_descr
    fields = resource_def |> get_resource_fields
    messages = resource_def |> get_resource_messages
    IO.puts("Generating #{module_name}")
    defresource module_name, module_descr, fields, messages
  end)

end
