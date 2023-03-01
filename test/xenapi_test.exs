defmodule XenAPITest do
  use ExUnit.Case
  doctest XenAPI

  test "return error in xen_method_call to unreachable host" do
    assert XenAPI.xen_method_call("127.0.0.1:65535", "xyz") == {:error, ["HTTP_ERROR", :econnrefused]}
  end

end
