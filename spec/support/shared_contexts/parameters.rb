# frozen_string_literal: true

RSpec.shared_context "with parameters" do
  let(:none) { BasicObject.instance_method(:initialize).parameters }
  let(:comprehensive) { test_module.instance_method(:trial).parameters }

  let :test_module do
    Module.new do
      def trial one, two = nil, *three, four:, five: nil, **six, &seven
        [one, two, three, four, five, six, seven]
      end
    end
  end

  let :comprehensive_proof do
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
