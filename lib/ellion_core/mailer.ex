defmodule EllionCore.Mailer do
  use Swoosh.Mailer, otp_app: :ellion

  import Ecto.Changeset, only: [change: 2, add_error: 3]

  def send_email(%Swoosh.Email{} = email) do
    case deliver(email) do
      {:ok, _metadata} ->
        {:ok, email}

      {:error, reason} ->
        {%{}, %{email: :map, detail: :string}}
        |> change(%{email: Map.from_struct(email), detail: inspect(reason)})
        |> add_error(:email, "couldn't be sent")
        |> then(&{:error, &1})
    end
  end
end
