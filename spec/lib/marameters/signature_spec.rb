# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Signature do
  subject(:signature) { described_class.new(*parameters) }

  describe ".of" do
    let(:super_params) { [%i[req one]] }
    let(:sub_params) { [%i[req child]] }

    it "answers empty string when super and sub parameters are empty" do
      expect(described_class.of([], []).to_s).to eq("")
    end

    it "answers required positional (super)" do
      signature = described_class.of([%i[req test]], sub_params).to_s
      expect(signature).to eq("test, child")
    end

    it "answers required positional (sub)" do
      signature = described_class.of(super_params, [%i[req test]]).to_s
      expect(signature).to eq("one, test")
    end

    it "answers optional positional (super)" do
      signature = described_class.of([%i[opt test]], sub_params).to_s
      expect(signature).to eq("child, test = nil")
    end

    it "answers optional positional (sub)" do
      signature = described_class.of(super_params, [%i[opt test]]).to_s
      expect(signature).to eq("one, test = nil")
    end

    it "answers named single splat (super)" do
      signature = described_class.of([%i[rest test]], sub_params).to_s
      expect(signature).to eq("child, *")
    end

    it "answers named single splat (sub)" do
      signature = described_class.of(super_params, [%i[rest test]]).to_s
      expect(signature).to eq("one, *test")
    end

    it "answers anonymous single splat (super)" do
      signature = described_class.of([[:rest]], sub_params).to_s
      expect(signature).to eq("child, *")
    end

    it "answers anonymous single splat (sub)" do
      signature = described_class.of(super_params, [[:rest]]).to_s
      expect(signature).to eq("one, *")
    end

    it "answers required keyword (super)" do
      signature = described_class.of([%i[keyreq test]], sub_params).to_s
      expect(signature).to eq("child, **")
    end

    it "answers required keyword (sub)" do
      signature = described_class.of(super_params, [%i[keyreq test]]).to_s
      expect(signature).to eq("one, test:")
    end

    it "answers optional keyword (super)" do
      signature = described_class.of([%i[key test]], sub_params).to_s
      expect(signature).to eq("child, **")
    end

    it "answers optional keyword (sub)" do
      signature = described_class.of(super_params, [%i[key test]]).to_s
      expect(signature).to eq("one, test: nil")
    end

    it "answers named double splat (super)" do
      signature = described_class.of([%i[keyrest test]], sub_params).to_s
      expect(signature).to eq("child, **")
    end

    it "answers named double splat (sub)" do
      signature = described_class.of(super_params, [%i[keyrest test]]).to_s
      expect(signature).to eq("one, **test")
    end

    it "answers anonymous double splat (super)" do
      signature = described_class.of([[:keyrest]], sub_params).to_s
      expect(signature).to eq("child, **")
    end

    it "answers anonymous double splat (sub)" do
      signature = described_class.of(super_params, [[:keyrest]]).to_s
      expect(signature).to eq("one, **")
    end

    it "answers named block (super)" do
      signature = described_class.of([%i[block test]], sub_params).to_s
      expect(signature).to eq("child, &")
    end

    it "answers named block (sub)" do
      signature = described_class.of(super_params, [%i[block test]]).to_s
      expect(signature).to eq("one, &test")
    end

    it "answers anonymous block (super)" do
      signature = described_class.of([[:block]], sub_params).to_s
      expect(signature).to eq("child, &")
    end

    it "answers anonymous block (sub)" do
      signature = described_class.of(super_params, [[:block]]).to_s
      expect(signature).to eq("one, &")
    end

    it "includes defaults" do
      signature = described_class.of super_params, [[:opt, :two, 2], [:key, :three, 3]]
      expect(signature.to_s).to eq("one, two = 2, three: 3")
    end

    it "removes duplicates" do
      signature = described_class.of super_params, [%i[req one], %i[req two], %i[req two]]
      expect(signature.to_s).to eq("one, two")
    end

    it "overrides duplicates" do
      signature = described_class.of [%i[rest test]], [[:rest]]
      expect(signature.to_s).to eq("*")
    end

    it "overrides duplicates with defaults" do
      signature = described_class.of super_params, [[:opt, :two, 1], [:opt, :two, 2]]
      expect(signature.to_s).to eq("one, two = 2")
    end

    it "answers sorted parameters" do
      signature = described_class.of super_params, [[:block], [:keyrest], [:rest], %i[opt two]]
      expect(signature.to_s).to eq("one, two = nil, *, **, &")
    end

    it "answers unique parameters" do
      signature = described_class.of [%i[req one], %i[rest one], %i[keyrest two], %i[block three]],
                                     [%i[req one], [:rest], [:keyrest], [:block]]

      expect(signature.to_s).to eq("one, *, **, &")
    end

    it "answers all parameters" do
      all = [
        %i[req one],
        %i[opt two],
        %i[rest three],
        %i[keyreq four],
        %i[key five],
        %i[keyrest six],
        %i[block seven]
      ]

      signature = described_class.of all, all

      expect(signature.to_s).to eq("one, two = nil, *, four:, five: nil, **, &")
    end
  end

  describe "#for_super" do
    context "with all kinds" do
      let :parameters do
        [
          %i[req one],
          %i[opt two],
          %i[rest three],
          %i[keyreq four],
          %i[key five],
          %i[keyrest six],
          %i[block seven]
        ]
      end

      it "answers named positionals and anonymous forwards" do
        expect(signature.for_super).to eq("one, two, *, four:, five:, **, &")
      end
    end

    context "with only required positional" do
      let(:parameters) { %i[req test] }

      it "answers name" do
        expect(signature.for_super).to eq("test")
      end
    end

    context "with only optional positional" do
      let(:parameters) { %i[opt test] }

      it "answers name" do
        expect(signature.for_super).to eq("test")
      end
    end

    context "with only single splat" do
      let(:parameters) { [:rest] }

      it "answers single splat" do
        expect(signature.for_super).to eq("*")
      end
    end

    context "with only required keyword" do
      let(:parameters) { %i[keyreq four] }

      it "answers key" do
        expect(signature.for_super).to eq("four:")
      end
    end

    context "with only optional keyword" do
      let(:parameters) { %i[key five] }

      it "answers key" do
        expect(signature.for_super).to eq("five:")
      end
    end

    context "with only double splat" do
      let(:parameters) { [:keyrest] }

      it "answers double splat" do
        expect(signature.for_super).to eq("**")
      end
    end

    context "with only block" do
      let(:parameters) { [:block] }

      it "answers ampersand" do
        expect(signature.for_super).to eq("&")
      end
    end

    context "with no kinds" do
      subject(:signature) { described_class.new }

      it "answers empty string" do
        expect(signature.for_super).to eq("")
      end
    end
  end

  shared_examples "a string" do |method|
    context "with argument forwarding" do
      subject(:signature) { described_class.new :all }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq("...")
      end
    end

    context "with required positional" do
      let(:parameters) { %i[req one] }

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
      let(:parameters) { [:opt, :two, "two"] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq(%(two = "two"))
      end
    end

    context "with optional positional (symbol)" do
      let(:parameters) { %i[opt two two] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq("two = :two")
      end
    end

    context "with optional positional (object)" do
      let(:parameters) { [:opt, :two, proc { Object.new }] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq(%(two = Object.new))
      end
    end

    context "with optional positional (lambda)" do
      let(:parameters) { [:opt, :two, -> no { no }] }

      it "answers with proc instance" do
        expectation = proc { signature.public_send method }
        expect(&expectation).to raise_error(ArgumentError, /avoid using parameters/i)
      end
    end

    context "with bare single splat" do
      let(:parameters) { [:rest] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq("*")
      end
    end

    context "with named single splat" do
      let(:parameters) { %i[rest three] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq("*three")
      end
    end

    context "with required keyword" do
      let(:parameters) { %i[keyreq four] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq("four:")
      end
    end

    context "with optional keyword (integer)" do
      let(:parameters) { [:key, :five, 5] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq("five: 5")
      end
    end

    context "with optional keyword (string)" do
      let(:parameters) { [:key, :five, "five"] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq(%(five: "five"))
      end
    end

    context "with optional keyword (symbol)" do
      let(:parameters) { %i[key five five] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq("five: :five")
      end
    end

    context "with optional keyword (object)" do
      let(:parameters) { [:key, :five, proc { Object.new }] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq("five: Object.new")
      end
    end

    context "with optional keyword (lambda)" do
      let(:parameters) { [:key, :two, -> no { no }] }

      it "answers with proc instance" do
        expectation = proc { signature.public_send method }
        expect(&expectation).to raise_error(ArgumentError, /avoid using parameters/i)
      end
    end

    context "with bare double splat" do
      let(:parameters) { [:keyrest] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq("**")
      end
    end

    context "with named double splat" do
      let(:parameters) { %i[keyrest six] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq("**six")
      end
    end

    context "with bare block" do
      let(:parameters) { [:block] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq("&")
      end
    end

    context "with named block" do
      let(:parameters) { %i[block seven] }

      it "answers parameter" do
        expect(signature.public_send(method)).to eq("&seven")
      end
    end

    context "with no parameters" do
      subject(:signature) { described_class.new }

      it "answers empty string" do
        expect(signature.public_send(method)).to eq("")
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
        def self.demo #{described_class.new [:opt, :two, 2]}
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
