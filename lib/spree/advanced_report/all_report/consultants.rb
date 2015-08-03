class Spree::AdvancedReport::AllReport::Consultants < Spree::AdvancedReport::AllReport
  def name
    "Current Consultants"
  end

  def description
    "All social consultants"
  end

  def initialize(params)
    super(params)

    self.ruportdata = Table(%w[id email first\ name last\ name join\ date signup\ number])
    customers = Spree::User.where("positive_opt_in IS NOT NULL").order("positive_opt_in desc")
    customers.each do |customer|
        ruportdata << {
          "id" => customer.id,
          "email" => customer.email,
          "first name" => customer.first_name,
          "last name" => customer.last_name,
          "join date" => customer.positive_opt_in,
          "signup number" => customer.consultant_signup_number
        }
    end
  end
end