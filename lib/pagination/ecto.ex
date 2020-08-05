defmodule Pagination.Ecto do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @page_size Keyword.fetch!(opts, :page_size)
      @page 1

      alias Pagination.Ecto

      def paginate(queryable, opts \\ %{}) do
        Ecto.paginate(__MODULE__, queryable, opts, page_size: @page_size, page: @page)
      end
    end
  end

  alias Pagination.Ecto.{List, Options}

  def paginate(repo, queryable, opts, defaults) do
    options = Options.build(opts, repo, defaults)

    List.build(queryable, options)
  end
end
