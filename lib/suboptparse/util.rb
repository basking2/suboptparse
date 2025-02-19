# frozen_string_literal: true

module SubOptParse
  # Utility methods that may help in writing commands.
  module Util
    # Merge obj2 into obj1, if possible.
    # Only hashes and lists are mergable.
    # :stopdoc:
    # rubocop:disable Metrics/PerceivedComplexity, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
    # :startdoc:
    def self.recursive_merge(obj1, obj2)
      if obj1.nil?
        obj2
      elsif obj2.nil?
        obj1
      elsif obj1.instance_of?(Hash) && obj2.instance_of?(Hash)
        obj2.each { |k, v| obj1[k] = recursive_merge(obj1[k], v) }
        obj1
      elsif obj1.instance_of?(Array) && obj2.instance_of?(Array)
        h = {}
        obj1.each { |v| h[v] = recursive_merge(h[v], v) }
        obj2.each { |v| h[v] = recursive_merge(h[v], v) }
        h.values
      else
        # Can't merge. Return object 2.
        obj2
      end
    end
    # :stopdoc:
    # rubocop:enable Metrics/PerceivedComplexity, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
    # :startdoc:
  end
end
