defmodule XenSession do
  @moduledoc """
  XenSession is the `session` struct used in all XAPI calls.
  """
  defstruct host: nil, session: nil

  defp login_with_password(host, username, password), do: XenClient.xen_method_call(host, "session.login_with_password", [username, password])

  @doc """
  Returns a `XenSession` struct after logging in to the host with provided
  `username` and `password`.
  """
  @spec login(binary, any, any) :: {:ok, %XenSession{host: binary, session: any}} | {:error, any}
  def login(host, username, password) do
    case login_with_password(host, username, password) do
      {:ok, session} -> {:ok, %XenSession{host: host, session: session}}
      {:error, ["HOST_IS_SLAVE", host]} -> login(host, username, password)
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Returns a `XenSession` struct after logging in to the host with provided
  `username` and `password`. Raises error if failed.
  """
  @spec login!(binary, any, any) :: %XenSession{}
  def login!(host, username, password) do
    case login_with_password(host, username, password) do
      {:ok, session} -> %XenSession{host: host, session: session}
      {:error, ["HOST_IS_SLAVE", host]} -> login!(host, username, password)
      {:error, error} -> raise(error)
    end
  end

  @doc """
  Logout the provided `XenSession` from the host.
  """
  @spec logout(%XenSession{host: binary, session: any}) :: {:error, list} | {:fault, [...]} | {:ok, any}
  def logout(xen_session), do: XenClient.session_method_call(xen_session, "session.logout")

end
