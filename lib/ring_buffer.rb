require 'byebug'
require_relative "static_array"

class RingBuffer
  attr_reader :length

  def initialize
    @store = StaticArray.new(8)
    @length = 0
    @capacity = 8
    @start_idx = 0
  end

  def physical_idx(logical_idx)
    (logical_idx + @start_idx) % @capacity
  end

  # O(1)
  def [](index)
    check_index(index)
    @store[physical_idx(index)]
  end

  # O(1)
  def []=(index, val)
    check_index(index)
    @store[physical_idx(index)] = val
  end

  # O(1)
  def pop
    raise "index out of bounds" if length == 0

    delete_val = self[length - 1]
    self[length - 1] = nil
    @length -= 1
    delete_val
  end

  # O(1) ammortized
  def push(val)
    resize! if @length == @capacity
    @length += 1
    self[@length - 1] = val
    @store
  end

  # O(1)
  def shift
    raise "index out of bounds" if @length == 0
    delete_val = self[0]
    self[0] = nil
    @length -= 1
    @start_idx += 1
    delete_val
  end

  # O(1) ammortized
  def unshift(val)
    resize! if @length == @capacity
    @length += 1
    @start_idx = (@start_idx - 1) % @capacity
    self[0] = val
    @store
  end

  protected
  attr_accessor :capacity, :start_idx, :store
  attr_writer :length

  def check_index(index)
    raise "index out of bounds" unless index.between?(0, @length - 1)
  end

  def resize!
    new_capacity = 2 * @capacity
    new_store = StaticArray.new(new_capacity)
    @length.times {|i| new_store[i] = self[i]}
    @store = new_store
    @capacity = new_capacity
    @start_idx = 0
  end
end
