class Spree::AdvancedReport::TopReport::TopConsultants < Spree::AdvancedReport::TopReport
  def name
    "Top Consultants"
  end

  def description
    "Top consultants, calculated by commissionable revenue"
  end

  def initialize(params, limit)
    super(params)

    orders.each do |order|
      if order.user
        data[order.consultant_first_id] ||= {
          :email => order.consultant_first.email,
          :commissionable => 0,
          :revenue => 0,
          :units => 0
        }
        data[order.consultant_first_id][:commissionable] += order.commissionable_total
        data[order.consultant_first_id][:revenue] += revenue(order)
        data[order.consultant_first_id][:units] += units(order)
      end
    end

    self.ruportdata = Table(%w[email Units Revenue Commissionable])
    data.inject({}) { |h, (k, v) | h[k] = v[:commissionable]; h }.sort { |a, b| a[1] <=> b [1] }.reverse[0..limit].each do |k, v|
      ruportdata << { "email" => data[k][:email], "Units" => data[k][:units], "Revenue" => data[k][:revenue], "Commissionable" => data[k][:commissionable] } 
    end
    ruportdata.replace_column("Revenue") { |r| "$%0.2f" % r.Revenue }
    ruportdata.rename_column("email", "Customer Email")
  end
end
