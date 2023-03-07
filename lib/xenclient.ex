defmodule XenClient do
  @moduledoc false

  use HTTPoison.Base

  @impl true
  def process_request_body(body) do
    try do
      XMLRPC.encode!(body)
    rescue
      _ -> "<encode_error>"
    end
  end

  @impl true
  def process_response_body(body), do: XMLRPC.decode(body)

  @doc """
  Make a raw Xen XMLRPC method call on given `host` with provided `method_name` and `params`.
  """
  @spec xen_method_call(binary, binary, list) :: {:ok, any} | {:fault, list} | {:error, list}
  def xen_method_call(host, method_name, params \\ []) do
    request_body = %XMLRPC.MethodCall {method_name: method_name, params: params}

    body_string = try do
      response = post!(host, request_body)
      response.body
    rescue
      e in HTTPoison.Error -> {:error, ["HTTP_ERROR", e.reason]}
    end

    case body_string do
      {:ok, %{:param => %{"Status" => "Success", "Value" => value}}} -> {:ok, value}
      {:ok, %{:param => %{"Status" => "Failure", "ErrorDescription" => error }}} -> {:error, error}
      {:ok, %XMLRPC.Fault{fault_code: code, fault_string: fault}} -> {:fault, [code, fault]}
      {:error, ["HTTP_ERROR", reason]} -> {:error, ["HTTP_ERROR", reason]}
      _ -> {:error, ["UNKNOWN"]}
    end

  end


  @doc """
  Make a Xen XMLRPC method call with provided `session`.
  """
  def session_method_call(%XenSession{:host => host, :session => session}, method_name, params \\ []) do
    xen_method_call(host, method_name, [session | params])
  end

  @doc """
  Make a Xen XMLRPC method call with provided `session`. Raise error on failure.
  """
  def session_method_call!(%XenSession{:host => host, :session => session}, method_name, params \\ []) do
    case xen_method_call(host, method_name, [session | params]) do
      {:ok, value} -> value
      {:error, [err_type, err_reason | _]} -> raise("[ERROR:#{err_type}] #{err_reason}")
      {:fault, [code, fault | _]} -> raise("[FAULT:#{code}] #{fault}")
    end
  end
end
