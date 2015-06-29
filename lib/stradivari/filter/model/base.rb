module Stradivari
  module Filter
    module Model

      module Base
        def self.included(base)
          base.module_eval do
            extend ClassMethods
          end
        end

        module ClassMethods
          def stradivari_filter_options(options = nil)
            @_stradivari_filter_options = options if options
            @_stradivari_filter_options
          end
          def configure_scope_search(*args)
            $stderr.puts "#{name}.configure_scope_search is deprecated. Please use .stradivari_filter_options (called from #{caller[0]})"
            stradivari_filter_options(*args)
          end

          ##
          # Copy search options and scopes registry on inheritance
          #
          def inherited(subclass)
            super

            subclass.stradivari_filter_options(
              self.stradivari_filter_options
            )

            subclass.stradivari_scopes.update(
              self.stradivari_scopes
            )
          end

          ##
          # Defines a search scope, callable from the query string.
          #
          def stradivari_scope(name, options = {}, &block)
            scope(name, block)
            stradivari_scopes.store(name.to_sym, options)
          end
          def scope_search(*args, &block)
            $stderr.puts "#{name}.scope_search is deprecated. Please use .stradivari_scope (called from #{caller[0]})"
            stradivari_scope(*args, &block)
          end

          ##
          # Keeps the registry of defined stradivari scopes
          #
          def stradivari_scopes
            @_stradivari_scopes ||= {}
          end

          ##
          # Returns the normalized type for the given column name
          #
          def stradivari_type(column_name)
            raise NotImplementedError
          end

          ##
          # Runs a Stradivari search on the given filter options hash.
          #
          def stradivari_filter(stradivari_filter_options)
            raise NotImplementedError
          end
          def extended_search(*args)
            $stderr.puts "#{name}.extended_search is deprecated. Please use .stradivari_filter (called from #{caller[0]})"
            stradivari_filter(*args)
          end

        end
      end

    end
  end
end
