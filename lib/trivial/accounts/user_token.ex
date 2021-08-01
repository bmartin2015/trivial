defmodule Trivial.Accounts.UserToken do
  use Ecto.Schema
  import Ecto.Query

  alias Trivial.Accounts.User

  @rand_size 32

  @session_validity_in_days 14

  schema "user_tokens" do
    field :token, :binary
    belongs_to :user, User

    timestamps(updated_at: false)
  end

  @doc """
  Generates a token that will be stored in a signed place,
  such as session or cookie. As they are signed, those
  tokens do not need to be hashed.
  """
  def build_session_token(user) do
    token = :crypto.strong_rand_bytes(@rand_size)
    {token, %Trivial.Accounts.UserToken{token: token, user_id: user.id}}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token.
  """
  def verify_session_token_query(token) do
    query =
      from token in Trivial.Accounts.UserToken,
        where: [token: ^token],
        join: user in assoc(token, :user),
        where: token.inserted_at > ago(@session_validity_in_days, "day"),
        select: user

    {:ok, query}
  end
end
