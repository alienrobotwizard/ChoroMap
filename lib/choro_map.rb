#!/usr/bin/env ruby

#
# Make me a choropleth map baby.
#
# Modified from:
# http://flowingdata.com/2009/11/12/how-to-make-a-us-county-thematic-map-using-free-tools/
#
# USAGE:
#
#        ./choro_map.rb <datafile> <map> > <output.svg>
#
# Where we assume your <datafile> has rows that look like: "identifier "\t" count".
# Here "identifier" is a county code or state abbreviation on whether <map>
# is "usa" or "counties".
#

require 'rubygems'
require 'nokogiri'

datafilename = ARGV[0]
map = ARGV[1]

data = File.open(datafilename, 'r')

# First, read the data into a hash
counts = { }
data.each do |row|
  identifier = row.split[0]
  counts[identifier] = row.split[1]
end

# Next, open the svg map file
mapname = "maps/" + map + ".svg"
svg_map = Nokogiri::XML(open(mapname))

# Find all paths in the file
paths = svg_map.css('path')

# Next, set colors and path styles. This is an awful color scheme, by the way.
colors = ["#FFFFCC", "#C2E699", "#78C679", "#31A354", "#006837"]
path_style = 'font-size:12px;fill-rule:nonzero;stroke:#FFFFFF;stroke-opacity:1;stroke-width:0.1;stroke-miterlimit:4;stroke-dasharray:none;stroke-linecap:butt;marker-start:none;stroke-linejoin:bevel;fill:'

# Then, go through each path and set its color based on its count
#
# Note: the numbers used in the comparisons below will likely have to change depending
# on the scale of your data.
paths.each do |p|
  count = counts[p['id']].to_f
  next if p['id'].eql?("path57")
  if count > 100
    color_class = 4
  elsif count > 75
    color_class = 3
  elsif count > 50
    color_class = 2
  elsif count > 25
    color_class = 1
  else
    color_class = 0
  end
  color = colors[color_class]
  p['style'] = path_style + color
end

# Finally, output the edited svg image
svg_map.display
