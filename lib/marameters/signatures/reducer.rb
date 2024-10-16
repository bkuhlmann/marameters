# frozen_string_literal: true

module Marameters
  module Signatures
    # Ensures duplicate parameters are removed while allowing default overrides.
    Reducer = lambda do |ancestor, descendant, key_length: 1|
      forwards = [[:rest], [:keyrest], [:block]]

      reduced = ancestor.union(descendant).each.with_object({}) do |parameter, all|
        key = parameter[..key_length].compact
        kind = key.first

        case kind
          when :rest, :keyrest, :block then all[kind] = parameter
          else all[key] = parameter
        end
      end

      parameters = reduced.values

      return parameters if descendant in [[:rest, *]]

      positionals = %i[req opt]
      ancestor_positions = ancestor.select { |kind, *| positionals.include? kind }

      descendant_positions = descendant.map { |item| item[..1] }
                                       .select { |kind, *| positionals.include? kind }

      double_splat = parameters.find { |kind, *| kind == :keyrest }

      if (ancestor - parameters) == forwards then forwards
      elsif !double_splat && descendant == [[:rest]] then descendant
      elsif double_splat && descendant_positions.empty?
        parameters - ancestor_positions
      else
        parameters
      end
    end
  end
end
