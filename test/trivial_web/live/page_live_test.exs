defmodule TrivialWeb.PageLiveTest do
  use TrivialWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Trivial"
    assert render(page_live) =~ "Trivial"
  end
end
