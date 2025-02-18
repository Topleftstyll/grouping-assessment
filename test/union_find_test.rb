require 'minitest/autorun'

require_relative '../lib/union_find'

class UnionFindTest < Minitest::Test
  def setup
    @union_find = UnionFind.new
  end

  def test_find_initially_returns_the_index_itself
    index = 1

    assert_equal index, @union_find.find(index)
  end

  def test_union_connects_two_elements
    parent_index = 1
    index_to_add = 2

    @union_find.union(parent_index, index_to_add)

    # After union, find should return the same root for both.
    root = @union_find.find(parent_index)
    assert_equal root, @union_find.find(index_to_add)
  end

  def test_chained_unions_return_the_same_root_parent
    # 1 and 2 are connected, 2 and 3 are connected, so 1, 2, 3 are in the same set.
    # index_to_parent would look like { 1 => 2, 2 => 3, 3 => 3 } 3 being the root
    @union_find.union(1, 2)
    @union_find.union(2, 3)

    # 4 and 5 are connected making index_to_parent { 1 => 2, 2 => 3, 3 => 3, 4 => 5, 5 => 5 }
    @union_find.union(4, 5)
    # Connects the 2 chains together and updates the root of 3 to 5 { 1 => 2, 2 => 3, 3 => 5, 4 => 5, 5 => 5 }
    @union_find.union(3, 4)

    # Find will handle the final path compression and update the root of all indices to 1
    # { 1 = >5, 2 => 5, 3 => 5, 4 => 5, 5 => 5 }
    root = @union_find.find(1)
    assert_equal root, @union_find.find(1)
    assert_equal root, @union_find.find(2)
    assert_equal root, @union_find.find(3)
    assert_equal root, @union_find.find(4)
    assert_equal root, @union_find.find(5)
  end
end
