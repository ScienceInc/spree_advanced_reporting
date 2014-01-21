class Spree::AdvancedReport::AllReport::NoncanceledUsers < Spree::AdvancedReport::AllReport
  def name
    "All users with noncanceled subscriptions"
  end

  def description
    "All users with noncanceled subscriptions"
  end

  def initialize(params)
    super(params)

    self.ruportdata = Table(%w[id email name])
    subscriptions = Spree::Subscription::Braintree::UserSubscription.noncanceled.includes(:user)
    seen = {}
    subscriptions.each do |subscription|
      if subscription.user && !seen[subscription.user.id]
        ruportdata << {
          "id" => subscription.user.id,
          "email" => subscription.user.email,
          "name" => "#{subscription.user.firstname} #{subscription.user.lastname}"
        }
        seen[subscription.user.id] = true
      end
    end
  end
end