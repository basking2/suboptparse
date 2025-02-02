#! /usr/bin/env ruby
# frozen_string_literal: true

require "suboptparse"

$LOAD_PATH << File.dirname(__FILE__)

so = SubOptParser.new do |opt|
  opt.autorequire_root = "suboptparse/autoreqtest"
  opt.shared_state = {}
end

so.call("a")
