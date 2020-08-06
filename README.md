# Pagination

**A small library providing a simple pagination based on limit and offset**

## Installation

Add `phoenix_pagination` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:phoenix_pagination, "~> 0.1.0", git: "https://github.com/studioraketa/phoenix_pagination.git"}
  ]
end
```

## Usage

### With your DB queries

Use the `Paginatin.Ecto` module inside your `Repo`.

```elixir
defmodule MyApp.Repo do
  use Ecto.Repo,
    otp_app: :my_app,
    adapter: Ecto.Adapters.Postgres

  use Pagination.Ecto, page_size: 20
end
```

A queryable can be paginated like so:

```elixir
  Repo.paginate(Post, %{"page" => 5})
```

or

```elixir
  Repo.paginate(Post, %{page: 5})
```

The result is a struct:

```elixir
  iex(6)> list = Repo.paginate(Post, %{page: 5})
  ...
  iex(7)> list.current_page
  5
  iex(8)> list.pages_count
  18
  iex(9)> list.entries_count
  350
  iex(10)> list.page_size
  20
  iex(11)> list.entries
  [.....]
```

### In the html templates

Inside your `MyAppWeb` import the `Paginatino.Html` module

```elixir
import Pagination.Html
```

and then in the views you can do the following:

```elixir
  <%= paginate_list(
    @list,
    fn page ->
      Routes.post_path(@conn, :index, [page: page])
    end
  ) %>
```

which will generate the links for you:

```html
<nav class="pagination">
  <a href="/posts?page=6">Previous</a>
  <a href="/posts?page=1">1</a>
  <a href="/posts?page=2">2</a>
  <em>...</em>
  <a href="/posts?page=4">4</a>
  <a href="/posts?page=5">5</a>
  <a href="/posts?page=6">6</a>
  <em class="current-page">7</em>
  <a href="/posts?page=8">8</a>
  <a href="/posts?page=9">9</a>
  <a href="/posts?page=10">10</a>
  <em>...</em>
  <a href="/posts?page=17">17</a>
  <a href="/posts?page=18">18</a>
  <a href="/posts?page=8">Next</a>
</nav>
```

It is possible to overrdie the `Next`, `Previous` and `...` labels like so:

```elixir
  <%= paginate_list(
    @list,
    fn page ->
      Routes.post_path(@conn, :index, [page: page])
    end,
    [
      next_label: "->",
      previous_label: "<-",
      etc_label: "----"
    ]
  ) %>
```

## Development

- Do some changes
- Run `MIX_ENV=test mix ecto.create` to create the test Databas
- Run `MIX_ENV=test mix ecto.migrate` to migrate it
- Run `mix test` to check if everything works

## TODO

- [ ] Work with queries including `group by` clauses.
- [ ] Improve documentation and tests
