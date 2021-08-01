defmodule TrivialWeb.UserSessionController do
  use TrivialWeb, :controller

  alias Trivial.Accounts
  alias TrivialWeb.AuthHelper

  @spec new(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def new(conn, _params) do
    render(conn, "new.html", error_message: nil, client_id: google_client_id())
  end

  def callback(conn, %{"credential" => credential, "g_csrf_token" => g_csrf_token} = params) do
    with :ok = validate_csrf(conn, g_csrf_token),
         {:ok, decoded_credential} <- Trivial.GoogleToken.verify_and_validate(credential),
         {:ok, user} <- Accounts.find_or_create_user(decoded_credential) do
      AuthHelper.log_in_user(conn, user, params)
    end
  end

  def callback(conn, _params) do
    conn
    |> put_flash(:error, "Could not log in")
    |> render("new.html", error_message: nil, client_id: google_client_id())
  end

  @spec delete(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> AuthHelper.log_out_user()
  end

  defp validate_csrf(conn, token) do
    csrf_token_cookie =
      conn
      |> Plug.Conn.fetch_cookies()
      |> Map.get(:req_cookies)
      |> Map.get("g_csrf_token")

    if token == csrf_token_cookie do
      :ok
    else
      {:error, :csrf_mismatch}
    end
  end

  defp google_client_id() do
    Application.fetch_env!(:trivial, :google_client_id)
  end
end
