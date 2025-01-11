defmodule EllionWeb.UserController.Show do
  @moduledoc false
  use Goal

  alias EllionCore.Auth.Users

  defparams :get_user do
    required(:id, :uuid)
  end

  def handle(params) do
    params
    |> validate_params()
    |> get_user()
  end

  defp validate_params(params), do: validate(:get_user, params)

  defp get_user({:ok, %{id: id}}), do: Users.get_user(:id, id)
  defp get_user({:error, changeset}), do: {:error, changeset}
end
