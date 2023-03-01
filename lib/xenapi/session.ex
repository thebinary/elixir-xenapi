defmodule XenAPI.Session do
  import XenSession
  import XenClient

  @spec login_with_password(binary, any, any) :: {:error, list} | {:fault, [...]} | {:ok, any}
  @doc """
  Attempt to authenticate the user, returning a session reference if successful.
  """
  def login_with_password(host, username, password), do: xen_method_call(host, "session.login_with_password", [username, password])

  @spec logout(%XenSession{:host => binary, :session => binary}, any) :: {:error, list} | {:fault, [...]} | {:ok, any}
  @doc """
  Log out of a session
  """
  def logout(%XenSession{:host => host, :session => session}, session), do: xen_method_call(host, "session.logout", [session])
end
