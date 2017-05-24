# frozen_string_literal: true

module RSpec
  module Que
    module Matchers
      class QueueUp
        class QueueCount
          EXACTLY = :==
          AT_LEAST = :>=
          AT_MOST = :<=

          def initialize(parent_matcher, comparator, number)
            @number = number
            @comparator = comparator
            @parent = parent_matcher
          end

          def once
            exactly(1)
            @parent
          end

          def twice
            exactly(2)
            @parent
          end

          def exactly(n)
            set(EXACTLY, n)
          end

          def at_least(n)
            set(AT_LEAST, n)
          end

          def at_most(n)
            set(AT_MOST, n)
          end

          def times
            @parent
          end

          def matches?(actual_number)
            actual_number.send(@comparator, @number)
          end

          def desc
            case @comparator
            when EXACTLY then "exactly #{@number} times"
            when AT_LEAST then "at least #{@number} times"
            when AT_MOST then "at most #{@number} times"
            end
          end

          def failed_msg(candidates)
            "#{candidates.length} jobs"
          end

          def default?
            @comparator == EXACTLY && @number == 1
          end

          private

          def set(comparator, number)
            @comparator = comparator
            @number = number
            self
          end
        end
      end
    end
  end
end
