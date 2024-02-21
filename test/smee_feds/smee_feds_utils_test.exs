defmodule SmeeFedsUtilsTest do
  use ExUnit.Case

  alias SmeeFeds.Utils

  describe "to_safe_atoms/1" do

    test "converts a single binary to a list containing an atom" do
      assert [:hello] = Utils.to_safe_atoms("hello")
    end

    test "converts a list of binaries to a list containing atoms" do
      assert [:hello, :world] = Utils.to_safe_atoms(["hello", "world"])

    end

    test "converts a list of binaries and atoms to a list containing atoms" do
      assert [:foo, :bar] = Utils.to_safe_atoms(["foo", :bar])

    end

    test "nils vanish from the resulting list" do
      assert [:foo, :bar] = Utils.to_safe_atoms(["foo", :bar, nil, nil])
    end

  end

  describe "to_safe_atom/1" do

    test "converts a single binary to an atom" do
      assert :hello = Utils.to_safe_atom("hello")
    end

    test "binary that's equivalent to an atom that already exists is returned as an atom" do
      assert :foo = Utils.to_safe_atom("foo")
    end

    test "a binary that does not already exist as an atom is returned as a nil" do
      assert is_nil(Utils.to_safe_atom("banana"))
    end

  end

end
