module Spree
  module PaymentDecorator
    def self.prepended(base)
      base.after_save :send_order_to_rabbitmq
    end

    def send_order_to_rabbitmq
      SendOrderToRabbitmqService.new(order).call if state == 'completed' && order.payment_state == 'paid' && order.state == 'complete'
    end
  end
end
::Spree::Payment.prepend Spree::PaymentDecorator if ::Spree::Order.included_modules.exclude?(Spree::PaymentDecorator)
