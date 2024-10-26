# frozen_string_literal: true

module Marameters
  module Signatures
    # Blends super and sub method arguments for forwarding to the super keyword.
    class Super
      def initialize key_length: 1, kinds: KINDS, forwarder: Signatures::Forwarder
        @key_length = key_length
        @kinds = kinds
        @forwarder = forwarder
        freeze
      end

      def call ancestor, descendant
        return "" if ancestor.empty?

        merge(ancestor, descendant).values
                                   .sort_by! { |(kind, *)| kinds.index kind }
                                   .then { |parameters| build parameters }
      end

      private

      attr_reader :key_length, :kinds, :forwarder

      # :reek:DuplicateMethodCall
      def merge ancestor, descendant
        ancestor.to_a.union(descendant.to_a).each.with_object({}) do |parameter, all|
          key = parameter[..key_length]
          kind = key.first

          case kind
            when :req, :opt
              if ancestor.positionals? && !descendant.positionals? then all[:rest] = [:rest]
              elsif ancestor.include? parameter then all[key] = parameter
              else all
              end
            when :keyreq, :key
              included = ancestor.include?(parameter) && descendant.include?(parameter)

              if included then all[key] = parameter
              else all[:keyrest] = [:keyrest]
              end
            else all[kind] = parameter if ancestor.kind? kind
          end
        end
      end

      def build parameters
        parameters.filter_map { |kind, name| forwarder.call kind, name }
                  .join ", "
      end
    end
  end
end
