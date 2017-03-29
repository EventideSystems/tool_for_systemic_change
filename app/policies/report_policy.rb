class ReportPolicy < ApplicationPolicy
  def index?
    true
  end
  
  def initiatives_report?
    true
  end

  def initiatives_results?
    true
  end
  
  def stakeholders_report?
    true
  end
  
  def stakeholders_results?
    true
  end
end
