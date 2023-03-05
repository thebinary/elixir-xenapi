# XenAPI

Elixir package to interact with Xen XML-RPC

## Installation

```elixir
def deps do
  [
    {:xenapi, "~> 0.1.1"}
  ]
end
```

## Usage

All `XenAPI` resource module functions require session argument of type `XenSession`.
For the Xen XMLRPC to succeed the XenSession should have a valid logged-in session ref.

### Logging In
To login to a XenServer and obtain a `XenSession` use:
```elixir
{:ok, xen_session} = XenSession.login(host, username, password)
```

### Calling XenAPI 
Now the logged in XenSession can be passed on to the XenAPI calls. eg:
```elixir
xen_session 
  |> XenAPI.VM.get_all
```

### Logging Out
To logout the XenSession from the Xen server use:
```elixir
xen_session 
  |> XenSession.logout
```