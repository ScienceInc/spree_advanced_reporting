module Spree
  class AdvancedReport
    include Ruport
    attr_accessor :orders, :product_text, :date_text, :taxon_text, :ruportdata, :data, :params, :taxon, :product, :product_in_taxon

    def name
      "Base Advanced Report"
    end

    def description
      "Base Advanced Report"
    end

    def default_date_range_to_yesterday(params)
      return unless params[:search][:completed_at_gt].blank? && params[:search][:completed_at_lt].blank?
      params[:search][:completed_at_gt] = Time.now.yesterday
      params[:search][:completed_at_lt] = Time.now
    end

    def default_date_range_to_match_all_orders(params)
      return unless Order.count > 0
      params[:search][:completed_at_gt] = Order.minimum(:completed_at) if params[:search][:completed_at_gt].blank?
      params[:search][:completed_at_lt] = Order.maximum(:completed_at) if params[:search][:completed_at_lt].blank?
    end

    def set_date_text(params)
      gt = Time.zone.parse(params[:search][:completed_at_gt].to_s).beginning_of_day
      lt = Time.zone.parse(params[:search][:completed_at_lt].to_s).end_of_day
      self.date_text = "Date Range:"
      self.date_text = "#{self.date_text} From #{gt} to #{lt}" if !gt.blank? && !lt.blank?
      self.date_text = "#{self.date_text} After #{gt}"         if !gt.blank? && lt.blank?
      self.date_text = "#{self.date_text} Before #{lt}"        if gt.blank?  && !lt.blank?
      self.date_text = "#{self.date_text} All"                 if gt.blank?  && lt.blank?
    end

    def initialize(params)
      self.params = params
      self.data = {}
      self.ruportdata = {}

      params[:search] ||= {}

      default_date_range_to_yesterday(params)
      # default_date_range_to_match_all_orders(params)      
      set_date_text(params)

      params[:search][:completed_at_not_null] = true
      params[:search][:state_not_eq] = 'canceled'

      search = Order.search(params[:search])
      # self.orders = search.state_does_not_equal('canceled')
      self.orders = search.result

      self.product_in_taxon = true
      if params[:advanced_reporting]
        if params[:advanced_reporting][:taxon_id] && params[:advanced_reporting][:taxon_id] != ''
          self.taxon = Taxon.find(params[:advanced_reporting][:taxon_id])
        end
        if params[:advanced_reporting][:product_id] && params[:advanced_reporting][:product_id] != ''
          self.product = Product.find(params[:advanced_reporting][:product_id])
        end
      end
      if self.taxon && self.product && !self.product.taxons.include?(self.taxon)
        self.product_in_taxon = false
      end

      if self.product
        self.product_text = "Product: #{self.product.name}<br />"
      end
      if self.taxon
        self.taxon_text = "Taxon: #{self.taxon.name}<br />"
      end


    end

    def download_url(base, format, report_type = nil)
      elements = []
      params[:advanced_reporting] ||= {}
      params[:advanced_reporting]["report_type"] = report_type if report_type
      if params
        [:search, :advanced_reporting].each do |type|
          if params[type]
            params[type].each { |k, v| elements << "#{type}[#{k}]=#{v}" }
          end
        end
      end
      base.gsub!(/^\/\//,'/')
      base + '.' + format + '?' + elements.join('&')
    end

    def revenue(order)
      rev = order.item_total
      if !self.product.nil? && product_in_taxon
        rev = order.line_items.select { |li| li.product == self.product }.inject(0) { |a, b| a += b.quantity * b.price }
      elsif !self.taxon.nil?
        rev = order.line_items.select { |li| li.product && li.product.taxons.include?(self.taxon) }.inject(0) { |a, b| a += b.quantity * b.price }
      end
      self.product_in_taxon ? rev : 0
    end

    def profit(order)
      profit = order.line_items.inject(0) { |profit, li| profit + (li.variant.price - li.product.cost_price.to_f)*li.quantity }
      if !self.product.nil? && product_in_taxon
        profit = order.line_items.select { |li| li.product == self.product }.inject(0) { |profit, li| profit + (li.variant.price - li.product.cost_price.to_f)*li.quantity }
      elsif !self.taxon.nil?
        profit = order.line_items.select { |li| li.product && li.product.taxons.include?(self.taxon) }.inject(0) { |profit, li| profit + (li.variant.price - li.product.cost_price.to_f)*li.quantity }
      end
      profit += order.adjustment_total
      self.product_in_taxon ? profit : 0
    end

    def units(order)
      units = order.line_items.sum(:quantity)
      if !self.product.nil? && product_in_taxon
        units = order.line_items.select { |li| li.product == self.product }.inject(0) { |a, b| a += b.quantity }
      elsif !self.taxon.nil?
        units = order.line_items.select { |li| li.product && li.product.taxons.include?(self.taxon) }.inject(0) { |a, b| a += b.quantity }
      end
      self.product_in_taxon ? units : 0
    end

    def order_count(order)
      self.product_in_taxon ? 1 : 0
    end

    def tax(order)
      tax = order.adjustments.where(:originator_type => "Spree::TaxRate").inject(0) { |sum, adj| sum += adj.amount }
      self.product_in_taxon ? tax : 0
    end
  end
end
