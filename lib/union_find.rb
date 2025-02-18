# Video on UnionFind Path Compression
# https://www.youtube.com/watch?v=VHRhJWacxis&list=PLDV1Zeh2NRsBI1C-mR6ZhHTyfoEJWlxvq&index=4
class UnionFind
  def initialize
    @index_to_parent = {}
  end

  def find(index)
    @index_to_parent[index] = index unless @index_to_parent.key?(index)
    @index_to_parent[index] = find(@index_to_parent[index]) if @index_to_parent[index] != index

    @index_to_parent[index]
  end

  def union(parent_index, index_to_add)
    @index_to_parent[find(parent_index)] = find(index_to_add)
  end
end
