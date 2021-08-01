defmodule Trivial.AccountsTest do
  use Trivial.DataCase

  alias Trivial.Accounts
  alias Trivial.Accounts.{User, UserToken}
  import Trivial.AccountsFixtures

  describe "users" do
    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "get_user_by_sub/1 returns user with give sub when exists" do
      user = user_fixture()
      assert Accounts.get_user_by_sub(user.sub) == user
    end

    test "get_user_by_sub/1 returns nil when does not exist" do
      sub = System.unique_integer() |> Integer.to_string()
      assert Accounts.get_user_by_sub(sub) == nil
    end

    test "create_user/1 with valid data creates a user" do
      %{sub: sub} = valid_attrs = valid_user_attributes()

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.email == "test_user#{sub}@example.com"
      assert user.type == :user
      assert user.sub == sub
    end

    test "create_user/1 with invalid data returns error changeset" do
      invalid_attrs = %{email: nil, sub: nil}
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(invalid_attrs)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "find_or_create_user/1 creates or returns {:ok, user} with valid data" do
      %{"sub" => sub, "email" => email} = auth = auth_fixture()

      assert Accounts.get_user_by_sub(sub) == nil

      assert {:ok,
              %User{
                email: ^email,
                sub: ^sub,
                type: :user
              } = user} = Accounts.find_or_create_user(auth)

      assert Accounts.get_user_by_sub(sub) == user
      assert {:ok, user} == Accounts.find_or_create_user(auth)
    end
  end

  describe "generate_user_session_token/1" do
    setup do
      %{user: user_fixture()}
    end

    test "generates a token", %{user: user} do
      token = Accounts.generate_user_session_token(user)
      assert user_token = Repo.get_by(UserToken, token: token)

      # Creating the same token for another test_user should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%UserToken{
          token: user_token.token,
          user_id: user_fixture().id
        })
      end
    end
  end

  describe "get_user_by_session_token/1" do
    setup do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      %{user: user, token: token}
    end

    test "returns user by token", %{user: user, token: token} do
      assert session_user = Accounts.get_user_by_session_token(token)
      assert session_user.id == user.id
    end

    test "does not return user for invalid token" do
      refute Accounts.get_user_by_session_token("oops")
    end

    test "does not return user for expired token", %{token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "delete_session_token/1" do
    test "deletes the token" do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      assert Accounts.delete_session_token(token) == :ok
      refute Accounts.get_user_by_session_token(token)
    end
  end
end
