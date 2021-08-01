defmodule Trivial.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Trivial.Repo

  alias Trivial.Accounts.{User, UserToken}

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_user!(integer()) :: User.t()
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user by google uid.

  ## Examples

    iex> get_user_by_uid("1234")
    {:ok, %User{}}

    iex> get_user_by_uid("1234")
    nil

  """
  @spec get_user_by_sub(String.t()) :: {:ok, User.t()} | nil
  def get_user_by_sub(sub) do
    Repo.get_by(User, sub: sub)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_user(Usert.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an existing user, or creates a new user

  ## Examples

      iex> find_or_create_user(%Ueberauth.Auth{})
      {:ok, %User{}}

      iex> find_or_create_user(%Ueberauth.Auth{})
      {:error, %Ecto.Changeset{}}
  """
  @spec find_or_create_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def find_or_create_user(%{"sub" => sub} = params) do
    case get_user_by_sub(sub) do
      nil ->
        create_user(params)

      user ->
        {:ok, user}
    end
  end

  ## Session Stuff

  @doc """
  Generates a session token.
  """
  @spec generate_user_session_token(User.t()) :: binary()
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the test_user with the given signed token.
  """
  @spec get_user_by_session_token(binary()) :: User.t() | nil
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_session_token(token) do
    UserToken
    |> Repo.get_by(token: token)
    |> Repo.delete!()

    :ok
  end
end
