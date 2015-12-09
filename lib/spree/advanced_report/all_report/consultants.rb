class Spree::AdvancedReport::AllReport::Consultants < Spree::AdvancedReport::AllReport
  def name
    "Current Consultants"
  end

  def description
    "All social consultants"
  end

  def initialize(params)
    super(params)

    self.ruportdata = Table(%w[id email first\ name last\ name phone permalink join\ date signup\ number kit])
    customers = Spree::User.where("positive_opt_in IS NOT NULL").includes(:orders).order("positive_opt_in desc")
    customers.each do |customer|
        ruportdata << {
          "id" => customer.id,
          "email" => customer.email,
          "first name" => customer.first_name,
          "last name" => customer.last_name,
          "phone" => customer.phone,
          "permalink" => "https://www.prizecandle.com/#{customer.permalink}",
          "join date" => customer.positive_opt_in,
          "signup number" => customer.consultant_signup_number,
          "kit" => customer.consultant_level
        }
    end
  end
end