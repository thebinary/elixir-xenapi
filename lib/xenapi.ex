defmodule XenAPI do
  @moduledoc """
  Documentation for `XenAPI`.
  """

  @doc """
  Returns a XenSession after login to the `host` with provided
  `username` and `password`
  """
  def get_session(host, username, password) do
    case XenAPI.Session.login_with_password(host, username, password) do
      {:error, ["HOST_IS_SLAVE", host]} -> get_session(host, username, password)
      {:ok, session} -> %XenSession{host: host, session: session}
    end
  end

end
