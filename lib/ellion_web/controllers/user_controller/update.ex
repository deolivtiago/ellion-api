defmodule EllionWeb.UserController.Update do
  @moduledoc false
  use Goal

  alias EllionCore.Auth.Users

  defparams :update_user do
    required(:id, :uuid)

    required(:first_name, :string, min: 2, max: 255, squish: true)
    optional(:last_name, :string, max: 255, squish: true)

    required(:email, :string, format: :email, min: 3, max: 160, trim: true)

    optional(:avatar_url, :string, max: 255, format: :url)
    optional(:role, :enum, values: ~w(user admin))
  end

  def handle(params) do
    params
    |> validate_params()
    |> get_user()
    |> update_user()
  end

  defp validate_params(params), do: validate(:update_user, params)

  defp get_user({:ok, %{id: id} = attrs}) do
    with {:ok, user} <- Users.get_user(:id, id) do
      {:ok, %{user: user, attrs: attrs}}
    end
  end

  defp get_user({:error, changeset}), do: {:error, changeset}

  defp update_user({:ok, %{user: user, attrs: attrs}}), do: Users.update_user(user, attrs)
  defp update_user({:error, changeset}), do: {:error, changeset}
end
