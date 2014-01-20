class Spree::AdvancedReport::AllReport::StoreCredits < Spree::AdvancedReport::AllReport
  def name
    "Remaining Store Credits"
  end

  def description
    "Remaining store credits of all customers"
  end

  def initialize(params)
    super(params)

    self.ruportdata = Table(%w[id email name remaining\ amount])
    customers = Spree::User.includes(:store_credits)
    customers.each do |customer|
      remaining_amount = customer.store_credits.inject(0) { |sum, store_credit| sum += store_credit.remaining_amount }
      if remaining_amount > 0
        ruportdata << {
          "id" => customer.id,
          "email" => customer.email,
          "name" => "#{customer.firstname} #{customer.lastname}",
          "remaining amount" => remaining_amount
        }
      end
    end
  end
end