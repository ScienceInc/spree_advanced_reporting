class Spree::AdvancedReport::AllReport::SocialEmails < Spree::AdvancedReport::AllReport
  def name
    "Social Emails"
  end

  def description
    "Emails attributed to specific consultants"
  end

  def initialize(params)
    super(params)

    self.ruportdata = Table(%w[email consultant])
    emails = Spree::Attribution.where("consultant_id IS NOT NULL")
    emails.each do |email|
        ruportdata << {
          "email" => email.email,
          "consultant" => email.consultant_id
        }
    end
  end
end