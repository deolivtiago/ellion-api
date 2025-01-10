defmodule EllionWeb.AuthController.Confirm do
  @moduledoc false
  use Goal

  alias EllionCore.Auth.Users

  defparams :verify_code do
    required(:code, :string, is: 6, trim: true)
    required(:email, :string, format: :email, min: 3, max: 160, trim: true)
  end

  def handle(params) do
    params
    |> validate_params()
    |> confirm_user()
  end

  defp validate_params(params), do: validate(:verify_code, params)

  defp confirm_user({:ok, %{email: email, code: code}}) do
    with {:ok, user} <- Users.get_user(:email, email) do
      Users.confirm_user(user, code)
    end
  end

  defp confirm_user({:error, changeset}), do: {:error, changeset}
end
