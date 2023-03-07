defmodule XenAPI.Generate do
  @moduledoc false

  @xapi_json "xenapi.json"

  defp message_map(res, msg) do
    name = Map.get(msg, "name")
    doc = Map.get(msg, "description")
    params = Map.get(msg, "params")
    result = Map.get(msg, "result")
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
    %{resource: res, method: name, params: Code.string_to_quoted!("[#{params_list_str}]"), result: result, doc: doc}
  end

  def get_json_spec do
    Jason.decode!(File.read!(@xapi_json))
  end

  def get_resource_list(data) do
    Enum.map(data, fn res -> Map.get(res, "name") end)
  end

  def get_resource_def(data, resource) do
    hd(Enum.filter(data, fn d -> Map.get(d, "name") == resource end))
  end

  def get_resource_descr(resource_def) do
    Map.get(resource_def, "description")
  end

  def get_resource_fields(resource_def) do
    Map.get(resource_def, "fields")
    |> Enum.map(& Map.get(&1, "name"))
    |> Enum.map(& String.to_atom/1)
  end

  def get_resource_messages(resource_def) do
    res = Map.get(resource_def, "name")
    messages = Map.get(resource_def, "messages")
    Enum.map(messages, fn msg -> message_map(res, msg) end)
  end

  defmacro defmsg(resource_term, method_term, params \\ [], result, doc: doc_term) do
    quote bind_quoted: [resource: resource_term, method: method_term, params: params, result: result, doc: doc_term], location: :keep do
      return_types = Enum.at(result, 0) |> String.split()
      case return_types do

        [^resource, "record"] ->
          @doc doc <> " Returns `XenAPI.#{resource |> Macro.camelize}` struct."
          def unquote(String.to_atom(method))(xen_session, unquote_splicing(params)) do
            case XenClient.session_method_call(xen_session, unquote("#{resource}.#{method}"), [unquote_splicing(params)]) do
              {:ok, value} -> {:ok, encode(value)}
              result -> result
            end
          end

          @doc doc <> " Returns `XenAPI.#{resource |> Macro.camelize}` struct." <> " (Raise error on XMLRPC failure)"
          def unquote(String.to_atom("#{method}!"))(xen_session, unquote_splicing(params)) do
            case XenClient.session_method_call(xen_session, unquote("#{resource}.#{method}"), [unquote_splicing(params)]) do
              {:error, [err_type, err_reason | _]} -> raise("[ERROR:#{err_type}] #{err_reason}")
              {:fault, [code, fault | _]} -> raise("[FAULT:#{code}] #{fault}")
              {:ok, value} -> encode(value)
            end
          end

        _ ->
          @doc doc
          def unquote(String.to_atom(method))(xen_session, unquote_splicing(params)), do: XenClient.session_method_call(xen_session, unquote("#{resource}.#{method}"), [unquote_splicing(params)])

          @doc doc <> " (Raise error on XMLRPC failure)"
          def unquote(String.to_atom("#{method}!"))(xen_session, unquote_splicing(params)), do: XenClient.session_method_call!(xen_session, unquote("#{resource}.#{method}"), [unquote_splicing(params)])

      end

    end
  end

  defmacro defresource(resource, descr, fields, msgs) do
    quote bind_quoted: [resource: resource, descr: descr, fields: fields, msgs: msgs], location: :keep do
      defmodule Macro.escape(String.to_atom("Elixir.XenAPI.#{resource}")) do
        @moduledoc descr
        defstruct fields

        defp encode(record) do
          obj = unquote(Code.string_to_quoted!("%XenAPI.#{resource}{}"))
          obj = Enum.reduce(unquote(fields), obj, fn field, obj ->
            %{obj | field => Map.get(record, Atom.to_string(field))}
          end)

        end

        Enum.map(msgs, fn %{resource: resource, method: method, params: params, result: result, doc: doc} ->
          defmsg resource, method, params, result, doc: doc
        end)
      end
    end

  end

end
