defmodule EllionWeb.AuthController.Verify do
  @moduledoc false
  use Goal

  alias EllionCore.Auth.Users

  defparams :send_code do
    required(:email, :string, format: :email, min: 3, max: 160, trim: true)
  end

  def handle(params) do
    params
    |> validate_params()
    |> verify_user()
  end

  defp validate_params(params), do: validate(:send_code, params)

  defp verify_user({:ok, %{email: email}}) do
    with {:ok, user} <- Users.get_user(:email, email),
         {:ok, _email} <- Users.verify_user(user, :confirm_account) do
      {:ok, user}
    end
  end

  defp verify_user({:error, changeset}), do: {:error, changeset}
end
