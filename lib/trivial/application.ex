defmodule Trivial.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Trivial.Repo,
      # Start the Telemetry supervisor
      TrivialWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Trivial.PubSub},
      # Start the Endpoint (http/https)
      TrivialWeb.Endpoint,
      # Start a worker by calling: Trivial.Worker.start_link(arg)
      # {Trivial.Worker, arg}
      {Trivial.Google.TokenStrategy, time_interval: 60_000}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Trivial.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TrivialWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
