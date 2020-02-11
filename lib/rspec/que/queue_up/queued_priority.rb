# frozen_string_literal: true

module RSpec
  module Que
    module Matchers
      class QueueUp
        class QueuedPriority
          def initialize(priority)
            @priority = priority
          end

          def matches?(job)
            job[:priority] == @priority
          end

          def desc
            "of priority #{@priority}"
          end

          def failed_msg(candidates)
            if candidates.length == 1
              "job of priority #{candidates.first[:priority]}"
            else
              "jobs of priority #{candidates.map { |c| c[:priority] }}"
            end
          end
        end
      end
    end
  end
end
