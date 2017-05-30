# frozen_string_literal: true

require "spec_helper"

RSpec.describe RSpec::Que::Matchers::QueueUp do
  class AJob; end
  class BJob; end
  let(:enqueued_jobs) { [] }
  before do
    allow(Que).
      to receive(:execute).and_return(enqueued_jobs)
  end

  let(:job_class) { nil }
  let(:instance) { described_class.new(job_class) }
  subject(:matches?) { instance.matches?(proc) }

  describe "with jobs queued of a certain priority" do
    let(:proc) do
      lambda do
        enqueued_jobs << { job_class: "AJob", args: ['kyubey'], priority: 1 }
        enqueued_jobs << { job_class: "AJob", args: ['beetle'], priority: 30 }
      end
    end

    describe '#of_priority' do
      it "should match jobs of the specified priority" do
        expect(instance.of_priority(30).matches?(proc)).to eq(true)
        expect(instance.failure_message_when_negated).to eq(
          %(expected not to enqueue a job of priority 30, got 1 enqueued: AJob[beetle])
        )
      end
    end
  end
end
