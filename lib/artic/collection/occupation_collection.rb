# frozen_string_literal: true
module Artic
  module Collection
    class OccupationCollection < SimpleDelegator
      def initialize(elements = [])
        super([] + elements)
      end
    end
  end
end
