# frozen_string_literal: true

module Reports
  class Base
    private

    def default_styles(package)
      header_styles(package).merge(
        {
          blue_normal: package.workbook.styles.add_style(fg_color: '386190', sz: 12, b: false),
          wrap_text: package.workbook.styles.add_style(
            alignment: { horizontal: :general, vertical: :bottom,
            wrap_text: true }
          ),
          date: date_style(package)
        }
      )
    end

    def date_style(package)
      package.workbook.styles.add_style(format_code: 'd/m/yy')
    end

    def header_styles(package)
      {
        h1: package.workbook.styles.add_style(fg_color: '386190', sz: 16, b: true),
        h2: package.workbook.styles.add_style(bg_color: 'dce6f1', fg_color: '386190', sz: 12, b: true),
        h3: package.workbook.styles.add_style(bg_color: 'dce6f1', fg_color: '386190', sz: 12, b: false),
      }
    end
  end
end
