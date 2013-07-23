module Pump
  class Collection
    def initialize
      @pumps = {}
    end

    def add(set, format, value)
      @pumps[format] ||= {}
      @pumps[format][set || :default] = value
    end

    def get(set, format)
      pumps = @pumps[format]
      pumps && (pumps[set] || pumps[:default])
    end

    def size
      @pumps.values.map(&:size).inject(0) {|sum, it| sum += it; it}
    end
  end
end