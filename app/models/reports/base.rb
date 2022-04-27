# frozen_string_literal: true

module Reports
  class Base
    private

    def date_style(package)
      package.workbook.styles.add_style format_code: 'd/m/yy'
    end
  end
end
