defmodule EllionCore.Auth.UserTokens.UserToken.List do
  @moduledoc false

  alias EllionCore.Auth.UserTokens.UserToken
  alias EllionCore.Repo

  @doc false
  def call do
    UserToken
    |> Repo.all()
    |> Repo.preload(:user)
  end
end
