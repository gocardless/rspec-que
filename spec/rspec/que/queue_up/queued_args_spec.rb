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

  describe "with argument expectations" do
    let(:job_class) { AJob }
    let(:instance) { described_class.new(job_class).with(*arguments) }
    let(:arguments) { [instance_of(BJob), hash_including(thing: 1)] }
    let(:job) { { job_class: "AJob", args: [BJob.new, { thing: 1, 'thing' => 2 }] } }
    let(:proc) { -> { enqueued_jobs << job } }

    it { is_expected.to be(true) }

    context "with mismatching arguments" do
      let(:proc) { -> { enqueued_jobs << { job_class: "AJob", args: [] } } }

      it { is_expected.to be(false) }
      specify do
        matches?
        expect(instance.failure_message).to eq(
          %(expected to enqueue a job of class AJob with args #{arguments},) +
          %( but found job enqueued with [])
        )
      end
    end

    context "with multiple mismatching arguments" do
      let(:proc) do
        lambda do
          enqueued_jobs << { job_class: "AJob", args: [] }
          enqueued_jobs << { job_class: "AJob", args: [23, :skidoo] }
        end
      end

      it { is_expected.to be(false) }
      specify do
        matches?
        expect(instance.failure_message).to eq(
          "expected to enqueue a job of class AJob with args #{arguments}," \
          " but found 2 jobs with args: [[], [23, :skidoo]]"
        )
      end
    end
  end
end
