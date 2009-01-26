#
#--
# Copyright (c) 2009, John Mettraux, jmettraux@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#++
#

#
# "made in Japan"
#
# jmettraux@gmail.com
#

require 'rufus/tokyo/base'


module Rufus::Tokyo

  module Tcutil #:nodoc#

    extend FFI::Library
    extend TokyoApiMixin

    #
    # find Tokyo Cabinet lib

    ffi_paths(Rufus::Tokyo.cabinet_paths)

    attach_function :mapnew, :tcmapnew, [], :pointer

    attach_function :mapput2, :tcmapput2, [ :pointer, :string, :string ], :void
    attach_function :mapout2, :tcmapout2, [ :pointer, :string ], :int
    attach_function :mapclear, :tcmapclear, [ :pointer ], :void

    attach_function :mapdel, :tcmapdel, [ :pointer ], :void

    attach_function :mapget2, :tcmapget2, [ :pointer, :string ], :string

    attach_function :mapiterinit, :tcmapiterinit, [ :pointer ], :void
    attach_function :mapiternext2, :tcmapiternext2, [ :pointer ], :string

    attach_function :maprnum, :tcmaprnum, [ :pointer ], :uint64
  end

  #
  # A Tokyo Cabinet in-memory (tcutil.h) map
  #
  class Map

    include Enumerable

    @@api = Rufus::Tokyo::Tcutil
    def api; @@api; end

    #
    # Creates an empty instance of a Tokyo Cabinet in-memory map
    #
    def initialize ()
      @map = api.mapnew
    end

    #
    # Inserts key/value pair
    #
    def []= (k, v)
      api.mapput2(m, k, v)
      v
    end

    #
    # Deletes an entry
    #
    def delete (k)
      v = self[k]
      return nil unless v
      (api.mapout2(m, k) == 1) || raise("failed to remove key '#{k}'")
      v
    end

    #
    # Empties the map
    #
    def clear
      api.mapclear(m)
    end

    #
    # Returns the value bound for the key k or nil else.
    #
    def [] (k)
      m; api.mapget2(m, k) rescue nil
    end

    #
    # Returns an array of all the keys in the map
    #
    def keys
      a = []
      api.mapiterinit(m)
      while (k = (api.mapiternext2(m) rescue nil)); a << k; end
      a
    end

    #
    # Returns an array of all the values in the map
    #
    def values
      collect { |k, v| v }
    end

    #
    # Our classical 'each'
    #
    def each
      keys.each { |k| yield(k, self[k]) }
    end

    #
    # Returns the count of entries in the map
    #
    def size
      api.maprnum(m)
    end

    alias :length :size

    #
    # Frees the map (nukes it from memory)
    #
    def free
      api.mapdel(@map)
      @map = nil
    end

    alias :destroy :free

    #
    # Returns the pointer to the underlying Tokyo Cabinet map
    #
    def pointer
      @map || raise('map got freed, cannot use anymore')
    end

    alias :m :pointer

    #
    # Turns a Ruby hash into a Tokyo Cabinet Map and returns it
    #
    def self.from_h (h)
      h.inject(Map.new) { |m, (k, v)| m[k] = v; m }
    end

    #
    # Turns this Tokyo Cabinet map into a Ruby hash
    #
    def to_h
      self.inject({}) { |h, (k, v)| h[k] = v; h }
    end

    #
    # Returns a new Ruby hash which is a merge of this Map and the given hash
    #
    def merge (h)
      self.to_h.merge(h)
    end

    #
    # Merges the entries in the given hash into this map
    #
    def merge! (h)
      h.each { |k, v| self[k] = v }
      self
    end
  end
end

