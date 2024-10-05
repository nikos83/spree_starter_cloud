class UpdateOrderService
  def initialize(message)
    @message = message
  end

  def call
    order_number = @message['number']
    order = Spree::Order.find_by(number: order_number.strip)
    return Rails.logger.error("Order not found: #{order_number}") unless order

      order.update(
        shipment_state: @message['shipment_state'],
        updated_at: Time.now,
      )

      shipment = order.shipments.last
      return Rails.logger.error("Order not found: #{order_number}") unless shipment

      shipment.update(
        tracking: @message['shipments'].first['tracking'],
        updated_at: Time.now,
        state:  @message['shipments'].first['state'],
      )
  end
end