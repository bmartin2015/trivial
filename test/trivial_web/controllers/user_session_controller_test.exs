defmodule TrivialWeb.UserSessionControllerTest do
  use TrivialWeb.ConnCase, async: true

  import Mock
  import Trivial.AccountsFixtures

  alias Trivial.GoogleToken

  setup do
    %{user: user_fixture()}
  end

  describe "GET /users/log_in" do
    test "renders log in page", %{conn: conn} do
      response =
        conn
        |> get(Routes.user_session_path(conn, :new))
        |> html_response(200)

      assert response =~ "<h1>Log in</h1>"
    end

    test "redirects if already logged in", %{conn: conn, user: user} do
      assert conn
             |> log_in_user(user)
             |> get(Routes.user_session_path(conn, :new))
             |> redirected_to() == "/"
    end
  end

  describe "POST /auth/google/callback" do
    test "with valid callback info", %{conn: conn} do
      decoded_credential = auth_fixture()

      with_mock GoogleToken, verify_and_validate: fn _credential -> {:ok, decoded_credential} end do
        assert conn
               |> put_req_cookie("g_csrf_token", "test_token")
               |> post("/auth/google/callback", %{
                 "credential" => "test",
                 "g_csrf_token" => "test_token"
               })
               |> redirected_to() == "/"
      end
    end

    test "with missing callback info", %{conn: conn} do
      response =
        conn
        |> put_req_cookie("g_csrf_token", "test_token")
        |> post("/auth/google/callback", %{})
        |> html_response(200)

      assert response =~ "<h1>Log in</h1>"
    end
  end

  describe "DELETE /users/log_out" do
    test "logs the user out", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> delete(Routes.user_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :user_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the user is not logged in", %{conn: conn} do
      conn = delete(conn, Routes.user_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :user_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end
  end
end
