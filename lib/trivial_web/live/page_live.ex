defmodule TrivialWeb.PageLive do
  use TrivialWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
