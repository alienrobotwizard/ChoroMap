#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'

class Choromap
  attr_accessor :counts, :svg_map, :colors

  def initialize(filename, options = {:color_scheme => 'YlOrRd'})
    @counts = {}
    @colors = hex_color_array(options[:color_scheme])
    read(filename)
  end

  #
  # Data file MUST be of the form:
  #
  # county_code'\t'count
  #
  # OR
  #
  # state_abbrv'\t'count
  #
  def read filename
    File.readlines(filename).each do |line|
      row = line.strip.split
      counts[row.first] = row.last.to_i
    end
  end

  def choropleth! map_type
    mapname = "maps/" + map_type + ".svg"
    @svg_map = Nokogiri::XML(open(mapname))
    paths    = svg_map.css('path')
    edit_paths paths
    @svg_map.display
  end

  
  #
  # Color themes direct from colorbrewer2.org
  #
  def hex_color_array color_scheme
    case color_scheme
    when 'YlOrRd' then
      ["#FFFFB2", "#FED976", "#FEB24C", "#FD8D3C", "#FC4E2A", "#E31A1C", "#B10026"]
    when 'RdPu' then
      ["#FEEBE2", "#FCC5C0", "#FA9FB5", "#F768A1", "#DD3497", "#AE017E", "#7A0177"]
    when 'YlGn' then
      ["#FFFFCC", "#D9F0A3", "#ADDD8E", "#78C679", "#41AB5D", "#238443", "#005A32"]           
    when 'YlGnBu' then
      ["#FFFFCC", "#C7E9B4", "#7FCDBB", "#41B6C4", "#1D91C0", "#225EA8", "#0C2C84"]           
    when 'YlOrBr' then
      ["#FFFFD4", "#FEE391", "#FEC44F", "#FE9929", "#EC7014", "#CC4C02", "#8C2D04"]           
    end
  end
  
  def edit_paths paths
    ignore_paths = ["State_Lines", "separator", "path57"]
    path_style   = 'font-size:12px;fill-rule:nonzero;stroke:#FFFFFF;stroke-opacity:1;stroke-width:0.1;stroke-miterlimit:4;stroke-dasharray:none;stroke-linecap:butt;marker-start:none;stroke-linejoin:bevel;fill:'
    paths.each do |path|
      count = counts[path['id']]
      count ||= 0
      next if ignore_paths.include? path['id']
      #
      # Brittle, change binning manually...
      #
      if count > 12
        color_lvl = 6
      elsif count > 10
        color_lvl = 5
      elsif count > 6
        color_lvl = 4
      elsif count > 4
        color_lvl = 3
      elsif count > 2
        color_lvl = 2
      elsif count > 0
        color_lvl = 1
      else
        color_lvl = 0
      end
      #
      color         = colors[color_lvl]
      path['style'] = path_style + color
    end
  end

end

raise "\n\nUsage: ./choro_map.rb <datafile> map\n" unless ARGV.length == 2

mapper = Choromap.new(ARGV[0], :color_scheme => 'YlOrRd')
mapper.choropleth! ARGV[1]
