require 'axlsx'

module Stradivari
  module XLSX
    class Generator < CSV::Generator

      class Column < CSV::Generator::Column
        def to_s(object)
          if @renderer.present?
            capture_haml { view.instance_exec(object, &@renderer) }
          elsif opts.fetch(:type, nil)
            object.public_send(@name)
          else
            build(object)
          end
        end
      end

      def to_s
        xlsx.to_stream.read.html_safe.force_encoding('BINARY')
      end

      protected
        def xlsx
          Axlsx::Package.new do |package|
            package.use_shared_strings = true
            package.workbook.add_worksheet(name: opts.fetch(:sheet, nil)) do |sheet|
              render_data(sheet)
            end
          end
        end

        def render_data(sheet)
          if @data.present?
            render_header(sheet)
            render_body(sheet)
          else
            render_no_data(sheet)
          end
        end

        def render_no_data(sheet)
          sheet.add_row([TABLE_OPTIONS[:no_data]])
        end

        def render_header(sheet)
          heading = sheet.styles.add_style sz: 15,
            bg_color: 'dddddd', fg_color: '000000',
            border: Axlsx::STYLE_THIN_BORDER, font_name: 'Verdana'

          sheet.add_row @columns.map(&:title),
            types: [:string] * @columns.size,
            style: heading
        end

        def render_body(sheet)
          @body_style = sheet.styles.add_style font_name: 'Verdana', sz: 10

          @data.each do |object|
            sheet.add_row(*render_row(object))

            if children = self.children(object)
              children.each do |child|
                sheet.add_row(*render_row(child))
              end
            end
          end
        end

      private
        def render_row(object)
          [ @columns.map {|col| col.to_s(object).to_s.strip }, types: types, style: @body_style ]
        end

        def types
          @_types ||= @columns.map {|c| c.opts.fetch(:type, nil)}
        end
    end
  end
end

