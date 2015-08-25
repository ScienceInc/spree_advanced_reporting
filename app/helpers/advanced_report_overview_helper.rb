module AdvancedReportOverviewHelper
  def csv_link
    link_to("Download as CSV", request.fullpath+'.csv')
  end
end
