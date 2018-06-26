require 'csv'
  module Report
    class TransitionCardStakeholders
      def initialize(scorecard)
        @scorecard = scorecard
      end
      
      def to_csv
        CSV.generate do |csv|
          
        end
      end
    end
  end
end