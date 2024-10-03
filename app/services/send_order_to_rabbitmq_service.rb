class SendOrderToRabbitmqService
  def initialize(order)
    @order = order
  end

  def call
    return unless @order.completed?

    # Uproszczone dane do wysłania do RabbitMQ
    message = {
      number: @order.number,
      channel: "store",
      item_total: @order.item_total.to_f,
      adjustment_total: @order.adjustment_total.to_f,
      total: @order.total.to_f,
      payment_total: @order.payment_total.to_f,
      currency: @order.currency,
      state: @order.state,
      shipping_method: @order.shipments.first&.shipping_method&.name || 'No shipping method',
      created_at: @order.created_at.iso8601,
      updated_at: @order.updated_at.iso8601,
      shipping_state: @order.payment_state,
      billing_address: format_address(@order.billing_address),
      shipping_address: format_address(@order.shipping_address),
      items: format_items(@order.line_items)
    }

    # Wysyłanie wiadomości do RabbitMQ
    RabbitmqConnection.publish(message, { 'object_type' => 'order', 'routing_key' => 'store' })

    Rails.logger.info "Order ##{@order.number} sent to RabbitMQ"
  rescue => e
    Rails.logger.error "Failed to send order to RabbitMQ: #{e.message}"
  end

  private

  def format_address(address)
    return {} unless address
    {
      first_name: address.firstname,
      last_name: address.lastname,
      phone: address.phone,
      street: address.address1,
      zip: address.zipcode,
      city: address.city,
      country: address.country.iso
    }
  end
  
  def format_items(line_items)
    line_items.map do |item|
      price = item.price.to_f
      quantity = item.quantity.to_i
      final_price = price * quantity
      {
        sku: item.variant.sku,
        quantity: quantity,
        price: price,
        final_price: final_price.round(2),
        size: extract_size(item)
      }
    end
  end
  def extract_size(line_item)
    size_option_value = line_item.variant.option_values.joins(:option_type).find_by(spree_option_types: { name: 'size' })
    size_option_value&.presentation || 'No size available'
  end
end
