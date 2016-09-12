# Basic Idea

##
# 1. A # of hash funcs, map to [0, B-1] uniformly at random
# 2. use AB Counters: let C(i, j) be a counter where 
#     {i in [0, A-1], j in [0, B-1]}
# 3. x in stream => all i in [0, A-1] increase C(i, h_i(x))
##

# Algorithm 1
#
# query(x) = median { C(i, h_i(x)) | i in [0, A-1] }


# Algorithm 2
#
#   neighbor(C[i,j]) = C[i,j+1] if j is even
#   neighbor(C[i,j]) = C[i,j-1] if j is odd
# 
#   estimate(x, i) = C[i, h_i(x)] - neighbor(C[i, h_i(x)])
#   query(x) = median { estimate(x, i) | i in [0, A-1] }

class UniformHashFamily
  def initialize range, large_prime=nil
    large_prime = 879_190_841 unless large_prime
    @p = large_prime
    @a = rand(1000000)
    @b = rand(1000)
    @range = range
  end

  def [](v)
    (@a * v + @b)  % @p % @range
  end
end

class ABCounter
  def initialize a, b
    @map = a.times.map do |i|
      b.times.map do |j|
        0
      end
    end
  end

  # inc the counter for a,b, by 1
  def inc a, b
    @map[a][b] += 1
  end

  def [] a, b
    @map[a][b]
  end
end

class BaseAlgorithm
  def median arr
    r = arr.sort
    if r.length == 0
      return nil
    elsif r.length.odd?
      return r[r.length / 2]
    else
      return (r[r.length / 2] + r[r.length / 2 + 1]) / 2.0
    end
  end

  def << v
    @hashes.each_with_index {|h, idx| @counter.inc idx, h[v] }
  end

  def initialize(a, b)
    @hashes = a.times.map { UniformHashFamily.new b} 
    @counter = ABCounter.new a, b
  end
end

class Algorithm < BaseAlgorithm
  def count1 v
    vals = @hashes.each_with_index.map {|h, idx| @counter[idx, h[v]] }
    median vals
  end

  def count2 v
    ni = neighbour(v)
    vals = @hashes.each_with_index.map {|h, idx| @counter[idx, h[v]] - @counter[idx, h[ni]] }
    median vals
  end

  private
  def neighbour(n)
    n.even? ?  n + 1 : n - 1
  end
end

class PureCount
  def initialize
    @counter = Hash.new(0)
  end

  def << v
    @counter[v] += 1
  end

  def query(k)
    @counter[k]
  end
end

