defmodule XenAPI.Session do
  import XenClient

  @spec login_with_password(binary, any, any) :: {:error, list} | {:fault, [...]} | {:ok, any}
  @doc """
  Attempt to authenticate the user, returning a session reference if successful.
  """
  def login_with_password(host, username, password), do: xen_method_call(host, "session.login_with_password", [username, password])


  @spec logout(%XenSession{}) :: {:error, list} | {:fault, [...]} | {:ok, any}
  @doc """
  Log out of a session
  """
  def logout(xsession), do: session_method_call(xsession, "session.logout")
end
