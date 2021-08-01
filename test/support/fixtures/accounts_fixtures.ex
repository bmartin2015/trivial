defmodule Trivial.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Trivial.Accounts` context.
  """

  alias Trivial.Accounts

  def valid_user_attributes(attrs \\ %{}) do
    sub = unique_user_sub()

    Enum.into(attrs, %{
      email: unique_user_email(sub),
      sub: sub
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, test_user} =
      attrs
      |> valid_user_attributes()
      |> Accounts.create_user()

    test_user
  end

  def auth_fixture(attrs \\ %{}) do
    sub = unique_user_sub()

    Enum.into(attrs, %{
      "sub" => sub,
      "email" => unique_user_email(sub)
    })
  end

  defp unique_user_sub, do: System.unique_integer() |> Integer.to_string()

  defp unique_user_email(sub), do: "test_user#{sub}@example.com"
end
