defmodule Trivial.Repo do
  use Ecto.Repo,
    otp_app: :trivial,
    adapter: Ecto.Adapters.Postgres
end
