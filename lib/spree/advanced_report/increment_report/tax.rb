class Spree::AdvancedReport::IncrementReport::Tax < Spree::AdvancedReport::IncrementReport
  def name
    "Tax"
  end

  def column
    "Tax"
  end

  def description
    "Total order tax"
  end

  def initialize(params)
    super(params)
    self.total = 0
    self.orders.each do |order|
      date = {}
      INCREMENTS.each do |type|
        date[type] = get_bucket(type, order.completed_at)
        data[type][date[type]] ||= {
          :value => 0,
          :display => get_display(type, order.completed_at),
        }
      end
      tax = tax(order)
      INCREMENTS.each { |type| data[type][date[type]][:value] += tax }
      self.total += tax
    end

    generate_ruport_data
  end

  def format_total
    '$' + ((self.total*100).round.to_f / 100).to_s
  end
end
