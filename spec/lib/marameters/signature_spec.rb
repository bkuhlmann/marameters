# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Signature do
  subject(:signature) { described_class.new parameters }

  describe "#initialize" do
    let(:parameters) { [[:req]] }

    it "is frozen" do
      expect(signature.frozen?).to be(true)
    end
  end

  shared_examples "a string" do |method|
    context "with required positional" do
      let(:parameters) { [%i[req one]] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq("one")
      end
    end

    context "with optional positional (integer)" do
      let(:parameters) { [[:opt, :two, 2]] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq("two = 2")
      end
    end

    context "with optional positional (string)" do
      let(:parameters) { [[:opt, :two, "two"]] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq(%(two = "two"))
      end
    end

    context "with optional positional (symbol)" do
      let(:parameters) { [%i[opt two two]] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq("two = :two")
      end
    end

    context "with optional positional (proc)" do
      let(:parameters) { [[:opt, :two, proc { Object.new }]] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq(%(two = Object.new))
      end
    end

    context "with bare single splat" do
      let(:parameters) { [[:rest, nil]] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq("*")
      end
    end

    context "with named single splat" do
      let(:parameters) { [%i[rest three]] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq("*three")
      end
    end

    context "with no keywords" do
      let(:parameters) { [[:nokey]] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq("**nil")
      end
    end

    context "with required keyword" do
      let(:parameters) { [%i[keyreq four]] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq("four:")
      end
    end

    context "with optional keyword (integer)" do
      let(:parameters) { [[:key, :five, 5]] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq("five: 5")
      end
    end

    context "with optional keyword (string)" do
      let(:parameters) { [[:key, :five, "five"]] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq(%(five: "five"))
      end
    end

    context "with optional keyword (symbol)" do
      let(:parameters) { [%i[key five five]] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq("five: :five")
      end
    end

    context "with optional keyword (object)" do
      let(:parameters) { [[:key, :five, proc { Object.new }]] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq("five: Object.new")
      end
    end

    context "with bare double splat" do
      let(:parameters) { [[:keyrest, nil]] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq("**")
      end
    end

    context "with named double splat" do
      let(:parameters) { [%i[keyrest six]] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq("**six")
      end
    end

    context "with bare block" do
      let(:parameters) { [[:block, nil]] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq("&")
      end
    end

    context "with named block" do
      let(:parameters) { [%i[block seven]] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq("&seven")
      end
    end

    context "with all kinds" do
      let :parameters do
        [
          %i[req one],
          [:opt, :two, 2],
          %i[rest three],
          %i[keyreq four],
          [:key, :five, 5],
          %i[keyrest six],
          %i[block seven]
        ]
      end

      it "answers parameters" do
        expect(signature.public_send(method)).to eq(
          "one, two = 2, *three, four:, five: 5, **six, &seven"
        )
      end
    end

    context "with invalid kind" do
      let(:parameters) { [%i[bogus eight]] }

      it "fails with descriptive message" do
        expectation = proc { signature.public_send method }

        expect(&expectation).to raise_error(
          ArgumentError,
          "Wrong kind (bogus), name (eight), or default ()."
        )
      end
    end

    it "uses signature to build dynamic method" do
      mod = Module.new

      mod.module_eval <<~DEFINITION, __FILE__, __LINE__ + 1
        def self.demo #{described_class.new [[:opt, :two, 2]]}
          two
        end
      DEFINITION

      expect(mod.demo).to eq(2)
    end
  end

  describe "#to_s" do
    it_behaves_like "a string", :to_s
  end

  describe "#to_str" do
    it_behaves_like "a string", :to_str
  end
end
