require 'spec_helper'

RSpec.describe RSpec::Que::Matchers::QueueUp do
  class AJob; end
  class BJob; end
  class CJob; end
  let(:enqueued_jobs) { [] }
  before do
    allow(Que).
      to receive(:execute).and_return(enqueued_jobs)
  end

  let(:job_class) { nil }
  let(:instance) { described_class.new(job_class) }
  subject(:matches?) { instance.matches?(proc) }

  context "when nothing gets enqueued" do
    let(:proc) { -> {} }
    it { is_expected.to be(false) }
    specify do
      matches?
      expect(instance.failure_message).
        to eq("expected to enqueue a job, but found nothing")
    end
  end

  context "when something gets enqueued" do
    let(:proc) { -> { enqueued_jobs << { job_class: "AJob", args: [] } } }

    it { is_expected.to be(true) }

    context "when it enqueues the wrong job" do
      let(:job_class) { BJob }

      it { is_expected.to be(false) }
      specify do
        matches?
        expect(instance.failure_message).
          to eq("expected to enqueue a job of class BJob, but found AJob")
      end
    end

    context "when it enqueues two jobs" do
      let(:job_a) { { job_class: "AJob", args: [] } }
      let(:job_b) { { job_class: "BJob", args: [] } }
      let(:proc) { -> { enqueued_jobs << job_a << job_b } }

      context "and one is of acceptable type" do
        it { is_expected.to be(true) }
      end

      context "and we were expecting none of the first type" do
        let(:job_class) { AJob }
        specify do
          matches?
          expect(instance.failure_message_when_negated).
            to eq "expected not to enqueue a job of class AJob, got 1 enqueued: AJob[]"
        end
      end

      context "and both are of the wrong type" do
        let(:job_class) { CJob }

        it { is_expected.to be(false) }
        specify do
          matches?
          expect(instance.failure_message).
            to eq("expected to enqueue a job of class CJob, but found 2 jobs of class [AJob, BJob]")
        end
      end
    end

    context "and nothing was expected" do
      let(:proc) { -> { enqueued_jobs << { job_class: "AJob", args: [11] } } }

      specify do
        matches?
        expect(instance.failure_message_when_negated).
          to eq("expected not to enqueue a job, got 1 enqueued: AJob[11]")
      end
    end
  end

  context "with argument expectations" do
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
        expect(instance.failure_message).
          to eq("expected to enqueue a job of class AJob with args #{arguments}, but found job enqueued with []")
      end
    end

    context "with multiple mismatching arguments" do
      let(:proc) do
        -> {
          enqueued_jobs << { job_class: "AJob", args: [] }
          enqueued_jobs << { job_class: "AJob", args: [23, :skidoo] }
        }
      end

      it { is_expected.to be(false) }
      specify do
        matches?
        expect(instance.failure_message).
          to eq("expected to enqueue a job of class AJob with args #{arguments}, but found 2 jobs with args: [[], [23, :skidoo]]")
      end
    end
  end
end
