defmodule Designator.Controllers.Helpers do
  import Plug.Conn

  def render_blank(conn) do
    conn
    |> send_resp(204, "")
  end

  def authenticate(conn, username, password) do
    desired_username = Application.fetch_env!(:designator, :api_auth)[:username]
    desired_password = Application.fetch_env!(:designator, :api_auth)[:password]

    if username == desired_username && password == desired_password do
      conn
    else
      conn
      |> Plug.Conn.halt
    end
  end

  def get_integer_param(params, key, default) do
    case Map.get(params, key) do
      nil -> default
      value -> convert_to_int(value)
    end
  end

  def convert_to_int(value) when is_integer(value) do
    value
  end

  def convert_to_int(value) when is_binary(value) do
    {int_value, _} = Integer.parse(value)
    int_value
  end

  def convert_to_int(value) when is_list(value) do
    {int_value, _} = Integer.parse(to_string(value))
    int_value
  end
end
