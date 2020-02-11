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

  describe "#exactly(2).times" do
    let(:instance) { described_class.new.exactly(2).times }

    context "when job is enqueued 2 times" do
      let(:proc) do
        lambda do
          enqueued_jobs << {}
          enqueued_jobs << {}
        end
      end

      it { is_expected.to eq(true) }
    end

    context "when job is enqeued less than 2 times" do
      let(:proc) { -> { enqueued_jobs << {} } }

      it { is_expected.to eq(false) }
      specify do
        subject
        expect(instance.failure_message).
          to eq("expected to enqueue a job exactly 2 times, but found 1 jobs")
      end
    end

    context "when job is enqeued more than 2 times" do
      let(:proc) do
        lambda do
          enqueued_jobs << {}
          enqueued_jobs << {}
          enqueued_jobs << {}
        end
      end

      it { is_expected.to eq(false) }
      specify do
        subject
        expect(instance.failure_message).
          to eq("expected to enqueue a job exactly 2 times, but found 3 jobs")
      end
    end

    context "when job is enqeued zero times" do
      let(:proc) { -> {} }

      it { is_expected.to eq(false) }
      specify do
        subject
        expect(instance.failure_message).
          to eq("expected to enqueue a job exactly 2 times, but found nothing")
      end
    end
  end

  describe "#at_least(2).times" do
    let(:instance) { described_class.new.at_least(2).times }

    context "when job is enqueued 2 times" do
      let(:proc) do
        lambda do
          enqueued_jobs << {}
          enqueued_jobs << {}
        end
      end

      it { is_expected.to eq(true) }
    end

    context "when job is enqeued less than 2 times" do
      let(:proc) { -> { enqueued_jobs << {} } }

      it { is_expected.to eq(false) }
      specify do
        subject
        expect(instance.failure_message).
          to eq("expected to enqueue a job at least 2 times, but found 1 jobs")
      end
    end

    context "when job is enqeued more than 2 times" do
      let(:proc) do
        lambda do
          enqueued_jobs << {}
          enqueued_jobs << {}
          enqueued_jobs << {}
        end
      end

      it { is_expected.to eq(true) }
    end

    context "when job is enqeued zero times" do
      let(:proc) { -> {} }

      it { is_expected.to eq(false) }
      specify do
        subject
        expect(instance.failure_message).
          to eq("expected to enqueue a job at least 2 times, but found nothing")
      end
    end
  end

  describe "#at_most(2).times" do
    let(:instance) { described_class.new.at_most(2).times }

    context "when job is enqueued 2 times" do
      let(:proc) do
        lambda do
          enqueued_jobs << {}
          enqueued_jobs << {}
        end
      end

      it { is_expected.to eq(true) }
    end

    context "when job is enqeued less than 2 times" do
      let(:proc) { -> { enqueued_jobs << {} } }

      it { is_expected.to eq(true) }
    end

    context "when job is enqeued more than 2 times" do
      let(:proc) do
        lambda do
          enqueued_jobs << {}
          enqueued_jobs << {}
          enqueued_jobs << {}
        end
      end

      it { is_expected.to eq(false) }
      specify do
        subject
        expect(instance.failure_message).
          to eq("expected to enqueue a job at most 2 times, but found 3 jobs")
      end
    end

    context "when job is enqeued zero times" do
      let(:proc) { -> {} }

      it { is_expected.to eq(true) }
    end
  end

  describe "#once" do
    let(:instance) { described_class.new.once }

    context "when a job is enqueued once" do
      let(:proc) { -> { enqueued_jobs << {} } }

      it { is_expected.to eq(true) }
    end

    context "with other expectations" do
      context "when enqueued once" do
        let(:instance) { described_class.new("AJob").with("arg1").once }
        let(:proc) { -> { enqueued_jobs << { job_class: "AJob", args: ["arg1"] } } }

        it { is_expected.to eq(true) }
      end

      context "when enqueued more than once" do
        let(:instance) { described_class.new("AJob").with("arg1").once }
        let(:proc) do
          lambda do
            enqueued_jobs << { job_class: "AJob", args: ["arg1"] }
            enqueued_jobs << { job_class: "AJob", args: ["arg1"] }
          end
        end

        it { is_expected.to eq(false) }
        specify do
          subject
          expect(instance.failure_message).to eq(
            "expected to enqueue a job of class AJob with args [\"arg1\"], " \
            "but found 2 jobs"
          )
        end
      end

      context "with multiple job classes" do
        let(:instance) { described_class.new("AJob").with("arg1").once }
        let(:proc) do
          lambda do
            enqueued_jobs << { job_class: "AJob", args: ["arg1"] }
            enqueued_jobs << { job_class: "BJob", args: ["arg1"] }
            enqueued_jobs << { job_class: "BJob", args: ["arg1"] }
          end
        end

        it { is_expected.to eq(true) }
      end
    end
  end
end
