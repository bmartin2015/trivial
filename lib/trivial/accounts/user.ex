defmodule Trivial.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          email: String.t(),
          type: atom(),
          sub: String.t()
        }

  @derive {Jason.Encoder, only: [:id, :email, :type, :uid]}

  schema "users" do
    field :email, :string
    field :type, Ecto.Enum, values: [:user, :admin], default: :user
    field :sub, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :sub])
    |> validate_required([:email, :sub])
  end
end
