class Spree::AdvancedReport::AllReport < Spree::AdvancedReport
  attr_accessor :customers

  def initialize(params)
    super(params)
    params[:includes] ||= {}
    search = Spree::User.includes(params[:includes]).search(params[:search])
    self.customers = search.result
  end
end
