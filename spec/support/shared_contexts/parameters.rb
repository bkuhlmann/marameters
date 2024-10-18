# frozen_string_literal: true

RSpec.shared_context "with parameters" do
  let(:mixed) { test_module.instance_method(:mixed).parameters }
  let(:named) { test_module.instance_method(:named).parameters }
  let(:none) { BasicObject.instance_method(:initialize).parameters }

  let :test_module do
    Module.new do
      def named one, two = nil, *three, four:, five: nil, **six, &seven
        [one, two, three, four, five, six, seven]
      end

      def mixed(one, two = nil, *, four:, five: nil, **, &)
        [one, two, four, five]
      end
    end
  end

  let :named_proof do
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
end
