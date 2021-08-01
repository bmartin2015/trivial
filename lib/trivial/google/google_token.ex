defmodule Trivial.GoogleToken do
  use Joken.Config, default_signer: nil

  @iss_urls ["https://accounts.google.com", "accounts.google.com"]

  add_hook(JokenJwks, strategy: Trivial.Google.TokenStrategy)

  @impl true
  def token_config do
    default_claims(skip: [:aud, :iss])
    |> add_claim("iss", nil, &(&1 in @iss_urls))
    |> add_claim("aud", nil, &(&1 == google_client_id()))
  end

  defp google_client_id() do
    Application.fetch_env!(:trivial, :google_client_id)
  end
end
