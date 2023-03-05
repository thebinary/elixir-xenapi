defmodule XenAPI.Generate do
  @moduledoc false

  @xapi_json "xenapi.json"

  defp message_map(res, msg) do
    name = Map.get(msg, "name")
    doc = Map.get(msg, "description")
    params = Map.get(msg, "params")
    params_excluding_session_id = Enum.filter(params, fn param -> Map.get(param, "name") != "session_id" end)
    params_list = Enum.map(params_excluding_session_id, fn m ->
      name = Map.get(m, "name")
      case name do
        "self" -> "#{String.downcase(res)}_ref"
        "fn" -> "function"
        _ -> name
      end
    end)
    params_list_str = Enum.reduce(params_list, [], fn acc, p -> [p | [acc | [","]]] end)
    %{resource: res, method: name, params: Code.string_to_quoted!("[#{params_list_str}]"), doc: doc}
  end

  def get_resource_list do
    data = Jason.decode!(File.read!(@xapi_json))
    Enum.map(data, fn res -> Map.get(res, "name") end)
  end

  def get_resource_messages(resource) do
    data = Jason.decode!(File.read!(@xapi_json))
    res_def = hd(Enum.filter(data, fn d -> Map.get(d, "name") == resource end))

    res = Map.get(res_def, "name")
    messages = Map.get(res_def, "messages")

    Enum.map(messages, fn msg -> message_map(res, msg) end)
  end

  defmacro defmsg(resource_term, method_term, params \\ [], doc: doc_term) do
    quote bind_quoted: [resource: resource_term, method: method_term, params: params, doc: doc_term], location: :keep do
      @doc doc
      def unquote(String.to_atom(method))(xen_session, unquote_splicing(params)), do: XenClient.session_method_call(xen_session, unquote("#{resource}.#{method}"), [unquote_splicing(params)])

      @doc doc <> " (Raise error on XMLRPC failure)"
      def unquote(String.to_atom("#{method}!"))(xen_session, unquote_splicing(params)), do: XenClient.session_method_call!(xen_session, unquote("#{resource}.#{method}"), [unquote_splicing(params)])
    end
  end

  defmacro defresource(resource, msgs) do
    quote bind_quoted: [resource: resource, msgs: msgs], location: :keep do
      defmodule Macro.escape(String.to_atom("Elixir.XenAPI.#{resource}")) do
        Enum.map(msgs, fn %{resource: resource, method: method, params: params, doc: doc} ->
          defmsg resource, method, params, doc: doc
        end)
      end
    end

  end

end
