module Stradivari
  module Filter

    class Builder < Stradivari::Builder
      Implementations = {
        selection:  'SelectionField',
        date_range: 'DateRangeField',
        number:     'NumberField',
        boolean:    'BooleanField',
        checkbox:   'CheckboxField',
        search:     'SearchField'
      }

      Implementations.each do |id, name|
        require "stradivari/filter/builder/#{id}_field"
        Implementations[id] = const_get(name)
      end.freeze

      autoload :ActionField, 'stradivari/filter/builder/action_field'

      class << self
        def value(params, name)
          params[name] || params["#{name}_eq"]
        end

        def active?(params, name)
          value(params, name).present?
        end
      end
    end

  end
end