#!/usr/bin/env ruby

require 'rubygems'
require 'kdtree'

class GeoFips
  attr_accessor :tree

  #
  # filname is the file to intialize the kdtree from
  #
  def initialize mapping, options = {}
    read(mapping)
  end

  #
  # Read in mapping and transform into lat,lon,int for
  # use with the kdtree gem
  #
  def read filename
    lines = File.readlines(filename)
    lines.map! do |line|
      row = line.strip.split
      [row[1].to_f,row[2].to_f,row[0].to_i]
    end
    @tree = KDTree.new(lines)
  end

  #
  # It is expected that geo_points is a tsv file
  # with the first column being latitudes and the
  # second being longitudes.
  #
  def convert! geo_points
    File.readlines(geo_points).each do |line|
      row = line.strip.split("\t")
      fips = "%05d" % tree.nearest(row[0].to_f, row[1].to_f) 
      puts [fips, row - [fips, row[0], row[1]]].join("\t") + "\n"
    end
  end
  
end

geofips = GeoFips.new('data/fips_to_geo')
geofips.convert! 'data/geo_points.tsv'
