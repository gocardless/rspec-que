module RSpec
  module Que
    module Matchers
      class QueueUp
        class QueuedSomething
          def matches?(_job)
            true
          end

          def desc
            "a job"
          end

          def failed_msg(_last_found)
            "nothing"
          end
        end
      end
    end
  end
end

