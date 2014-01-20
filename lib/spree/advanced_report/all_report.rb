class Spree::AdvancedReport::AllReport < Spree::AdvancedReport
  attr_accessor :customers

  def initialize(params)
    super(params)
    search = Spree::User.search(params[:search])
    self.customers = search.result
  end
end
