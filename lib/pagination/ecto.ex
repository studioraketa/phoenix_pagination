defmodule Pagination.Ecto do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @page_size Keyword.get(opts, :page_size, 25)
      @page 1

      @cursor_page_size Keyword.get(opts, :cursor_page_size, 25)
      @cursor_default_field Keyword.get(opts, :cursor_default_field, :id)
      @cursor_default_direction Keyword.get(opts, :cursor_default_direction, :desc)

      alias Pagination.Ecto

      def paginate(queryable, typ, opts \\ %{})

      def paginate(queryable, :offset, opts) do
        Ecto.paginate(:offset, __MODULE__, queryable, opts, page_size: @page_size, page: @page)
      end

      def paginate(queryable, :cursor, opts) do
        Ecto.paginate(
          :cursor,
          __MODULE__,
          queryable,
          opts,
          [
            page_size: @cursor_page_size,
            field: @cursor_default_field,
            direction: @cursor_default_direction,
          ]
        )
      end
    end
  end

  alias Pagination.Ecto.{Cursor, Offset}

  def paginate(:offset, repo, queryable, opts, defaults) do
    options = Offset.Options.build(opts, repo, defaults)

    Offset.List.build(queryable, options)
  end

  def paginate(:cursor, repo, queryable, opts, defaults) do
    Cursor.Query.assert_cursor_pagination_available!(queryable)

    options = Cursor.Options.build(opts, repo, defaults)

    Cursor.List.build(queryable, options)
  end
end
