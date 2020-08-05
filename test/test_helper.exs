defmodule Pagination.TestCase do
  use ExUnit.CaseTemplate

  using opts do
    quote do
      use ExUnit.Case, unquote(opts)
      import Ecto.Query
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Pagination.Test.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Pagination.Test.Repo, {:shared, self()})
    :ok
  end
end

Pagination.Test.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(Pagination.Test.Repo, :manual)

ExUnit.start()
