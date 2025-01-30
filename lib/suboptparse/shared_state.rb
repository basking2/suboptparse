
require_relative "./util"

module SubOptParse

  # A helper class that may be used in SubOptParse.shared_state.
  # 
  # This class wraps a Hash and allows other hash-like objects to be
  # merged into this hash without creating a new container object.
  class SharedState
    # The current state.
    attr_accessor :curr

    def initialize(initial_state={})
      @curr = initial_state
    end

    def merge!(other)
      @curr = SubOptParse::Util.recursive_merge(@curr, other)
    end

    # Convenience function equivalent to shared_state.curr[name] = value.
    def []=(name, value)
      @curr[name] = value
    end

    # Convenience function equivalent to shared_state.curr[name].
    def [](name)
      @curr[name]
    end
  end
end