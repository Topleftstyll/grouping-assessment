class UnionFind
  def initialize
    @parent = {}
  end

  def parent
    @parent
  end

  def find(index)
    @parent[index] = index unless @parent.key?(index)
    @parent[index] = find(@parent[index]) if @parent[index] != index
    @parent[index]
  end

  def union(parent_index, index_to_add)
    @parent[find(parent_index)] = find(index_to_add)
  end
end
