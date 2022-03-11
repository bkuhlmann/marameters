# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Signature do
  subject(:signature) { described_class.new parameters }

  describe "#to_s" do
    context "with required positional" do
      let(:parameters) { {req: :one} }

      it "answers parameter" do
        expect(signature.to_s).to eq("one")
      end
    end

    context "with optional positional (integer)" do
      let(:parameters) { {opt: [:two, 2]} }

      it "answers parameter" do
        expect(signature.to_s).to eq("two = 2")
      end
    end

    context "with optional positional (string)" do
      let(:parameters) { {opt: [:two, "two"]} }

      it "answers parameter" do
        expect(signature.to_s).to eq(%(two = "two"))
      end
    end

    context "with optional positional (symbol)" do
      let(:parameters) { {opt: %i[two two]} }

      it "answers parameter" do
        expect(signature.to_s).to eq("two = :two")
      end
    end

    context "with optional positional (object)" do
      let(:parameters) { {opt: [:two, "*Object.new"]} }

      it "answers parameter" do
        expect(signature.to_s).to eq("two = Object.new")
      end
    end

    context "with bare single splat" do
      let(:parameters) { {rest: nil} }

      it "answers parameter" do
        expect(signature.to_s).to eq("*")
      end
    end

    context "with named single splat" do
      let(:parameters) { {rest: :three} }

      it "answers parameter" do
        expect(signature.to_s).to eq("*three")
      end
    end

    context "with required keyword" do
      let(:parameters) { {keyreq: :four} }

      it "answers parameter" do
        expect(signature.to_s).to eq("four:")
      end
    end

    context "with optional keyword (integer)" do
      let(:parameters) { {key: [:five, 5]} }

      it "answers parameter" do
        expect(signature.to_s).to eq("five: 5")
      end
    end

    context "with optional keyword (string)" do
      let(:parameters) { {key: [:five, "five"]} }

      it "answers parameter" do
        expect(signature.to_s).to eq(%(five: "five"))
      end
    end

    context "with optional keyword (symbol)" do
      let(:parameters) { {key: %i[five five]} }

      it "answers parameter" do
        expect(signature.to_s).to eq("five: :five")
      end
    end

    context "with optional keyword (object)" do
      let(:parameters) { {key: [:five, "*Object.new"]} }

      it "answers parameter" do
        expect(signature.to_s).to eq("five: Object.new")
      end
    end

    context "with bare double splat" do
      let(:parameters) { {keyrest: nil} }

      it "answers parameter" do
        expect(signature.to_s).to eq("**")
      end
    end

    context "with named double splat" do
      let(:parameters) { {keyrest: :six} }

      it "answers parameter" do
        expect(signature.to_s).to eq("**six")
      end
    end

    context "with bare block" do
      let(:parameters) { {block: nil} }

      it "answers parameter" do
        expect(signature.to_s).to eq("&")
      end
    end

    context "with named block" do
      let(:parameters) { {block: :seven} }

      it "answers parameter" do
        expect(signature.to_s).to eq("&seven")
      end
    end

    context "with all kinds" do
      let :parameters do
        {
          req: :one,
          opt: [:two, 2],
          rest: :three,
          keyreq: :four,
          key: [:five, 5],
          keyrest: :six,
          block: :seven
        }
      end

      it "answers parameters" do
        expect(signature.to_s).to eq("one, two = 2, *three, four:, five: 5, **six, &seven")
      end
    end

    context "with invalid kind" do
      let(:parameters) { {bogus: :eight} }

      it "fails with descriptive message" do
        expectation = proc { signature.to_s }

        expect(&expectation).to raise_error(
          ArgumentError,
          "Wrong kind (bogus), name (eight), or default ()."
        )
      end
    end

    it "uses signature to build dynamic method" do
      mod = Module.new

      mod.module_eval <<~DEFINITION, __FILE__, __LINE__ + 1
        def self.demo #{described_class.new({opt: [:two, 2]})}
          two
        end
      DEFINITION

      expect(mod.demo).to eq(2)
    end
  end
end
