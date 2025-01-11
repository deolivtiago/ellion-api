defmodule EllionWeb.UserController.Delete do
  @moduledoc false
  use Goal

  alias EllionCore.Auth.Users

  defparams :delete_user do
    required(:id, :uuid)
  end

  def handle(params) do
    params
    |> validate_params()
    |> get_user()
    |> delete_user()
  end

  defp validate_params(params), do: validate(:delete_user, params)

  defp get_user({:ok, %{id: id}}), do: Users.get_user(:id, id)
  defp get_user({:error, changeset}), do: {:error, changeset}

  defp delete_user({:ok, user}), do: Users.delete_user(user)
  defp delete_user({:error, changeset}), do: {:error, changeset}
end
