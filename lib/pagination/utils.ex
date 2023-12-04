defmodule Pagination.Utils do
  def get(map, key, defaults) do
    maybe_nil(map[key]) ||
      maybe_nil(map[to_string(key)]) ||
      Keyword.fetch!(defaults, key)
  end

  def get(map, key) do
    maybe_nil(map[key]) || maybe_nil(map[to_string(key)])
  end

  defp maybe_nil(""), do: nil
  defp maybe_nil(value), do: value


  def to_i(num) when is_binary(num), do: String.to_integer(num)
  def to_i(num) when is_integer(num), do: num
end
