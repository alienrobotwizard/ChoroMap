#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'geo2county' ; include FipsFromGeo

#
# Using wukong for 2 reasons:
#
# 1. We would like to stream data through line by line. This
# way of doing it is quite scalable and works with Hadoop streaming.
#
# 2. Often more than one (lat,lon,*stuff) record in the input dataset gets
# mapped to the same fips county code. Consequently there needs to be a
# group by fips county code. In this simple example *stuff is just
# a count and so in the reduce phase we simply sum the counts for a given
# fips county code (used as key field)
#
class FipsFromGeoMapper < Wukong::Streamer::RecordStreamer
  attr_accessor :geo_2_fips

  def initialize *args
    super *args
    @geo_2_fips = Geo2County.new('../data/fips_to_geo')
  end
  
  def process lat, lon, *_, &blk
    yield [geo_2_fips.nearest_county(lat.to_f, lon.to_f), *_].flatten
  end
end

#
# Here we read in the records from the map phase. Everything with the
# same fips county code is collected and their counts are summed.
#
class FipsFromGeoReducer < Wukong::Streamer::AccumulatingReducer
  attr_accessor :record

  def get_key fips, *args
    fips
  end
  
  def start! fips, *args
    @record = []
  end

  def accumulate fips, *args
    @record << args.first.to_i # assuming args only consists of counts
  end

  #
  # Yield final [fips, count] record
  #
  def finalize
    yield [key, record.inject(0){|s,v| s += v; s} ] 
  end
  
end

Wukong::Script.new(FipsFromGeoMapper, FipsFromGeoReducer).run
