defmodule EllionCore.Repo do
  use Ecto.Repo,
    otp_app: :ellion,
    adapter: Ecto.Adapters.Postgres
end
