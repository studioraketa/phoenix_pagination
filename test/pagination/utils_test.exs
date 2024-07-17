defmodule Pagination.UtilsTest do
  use ExUnit.Case

  alias Pagination.Utils

  describe "to_i" do
    test "to_i/1 returns an integer when given a string" do
      assert Utils.to_i("2") == 2
    end

    test "to_i/1 returns an integer when given an integer" do
      assert Utils.to_i(5) == 5
    end
  end

  describe "get/2" do
    test "get/2 retrns nil when the value for the given key is an empty string" do
      assert Utils.get(%{key: ""}, :key) == nil
    end

    test "get/2 retrns the correct value for a hash with atom keys" do
      assert Utils.get(%{key: "2"}, :key) == "2"
    end

    test "get/2 retrns the correct value for a hash with string keys" do
      assert Utils.get(%{"key" => "2"}, :key) == "2"
    end
  end

  describe "get/3" do
    test "get/3 retrns the default value when the given key has no present value" do
      assert Utils.get(%{key: ""}, :key, [key: 5]) == 5
    end

    test "get/3 retrns the correct value for a hash with atom keys" do
      assert Utils.get(%{key: "2"}, :key, [key: 5]) == "2"
    end

    test "get/3 retrns the correct value for a hash with string keys" do
      assert Utils.get(%{"key" => "2"}, :key, [key: 5]) == "2"
    end
  end
end
