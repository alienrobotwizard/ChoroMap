require 'kdtree'
module FipsFromGeo
  
  #
  # Uses a kdtree to map a given (lat,lon) pair to nearest county.
  # BE AWARE this will work even for (lat,lon) pairs outside the US.
  #
  class Geo2County
    attr_accessor :tree

    #
    # mapping is the file to intialize the kdtree from
    #
    def initialize mapping, options = {}
      read(mapping)
    end

    #
    # Read in mapping and transform into lat,lon,int for
    # use with the kdtree gem
    #
    def read mapping
      lines = File.readlines(mapping)
      lines.map! do |line|
        row = line.strip.split
        [row[1].to_f,row[2].to_f,row[0].to_i]
      end
      @tree = KDTree.new(lines)
    end

    #
    # Return the fips county code nearest to lat,lon
    #
    def nearest_county lat, lon
      "%05d" % tree.nearest(lat.to_f, lon.to_f) 
    end
  end
  
end
