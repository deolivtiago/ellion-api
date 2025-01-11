defmodule EllionWeb.UserController.Index do
  @moduledoc false
  use Goal

  alias EllionCore.Auth.Users

  defparams :list_users do
    optional(:limit, :integer, min: 1, max: 24, default: 25)
  end

  def handle(params) do
    params
    |> validate_params()
    |> list_users()
  end

  defp validate_params(params), do: validate(:list_users, params)

  defp list_users({:ok, _params}), do: Users.list_users()
  defp list_users({:error, changeset}), do: {:error, changeset}
end
