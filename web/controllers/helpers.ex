defmodule Designator.Controllers.Helpers do
  import Plug.Conn

  def render_json_response(conn, code, body) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(code, body)
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
    case Integer.parse(value) do
      :error -> :error
      {int_value, _} -> int_value
    end
  end

  def is_invalid_integer(value) do
    case value do
      :error -> true
      _  -> false
    end
  end
end
