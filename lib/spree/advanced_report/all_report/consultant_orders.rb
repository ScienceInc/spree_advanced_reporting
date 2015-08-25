class Spree::AdvancedReport::AllReport::ConsultantOrders < Spree::AdvancedReport::AllReport
  def name
    "Prize Candle Social Orders"
  end

  def description
    "Orders with consultant attribution"
  end

  def initialize(params)
    super(params)

    self.ruportdata = Table(%w[number email name consultant\ first consultant\ second total item\ total completed])
    orders = Spree::Order.where("consultant_first_id IS NOT NULL or consultant_second_id IS NOT NULL").order("completed_at desc")
    orders.each do |order|
        ruportdata << {
          "number" => order.number,
          "email" => order.email,
          "name" => "#{order.billing_address.first_name} #{order.billing_address.last_name}",
          "consultant first" => order.consultant_first_id,
          "consultant second" => order.consultant_second_id,
          "total" => order.total,
          "item total" => order.item_total,
          "completed" => order.completed_at
        }
    end
  end
end