class RabbitmqConnection
  def self.connection
    @connection ||= Bunny.new(ENV['RABBITMQ_URL'] || 'amqp://guest:guest@localhost:5672').tap do |conn|
      conn.start
    end
  end

  def self.channel
    @channel ||= connection.create_channel
  end

  def self.exchange
    @exchange ||= channel.headers('syncomm', durable: true)
  end

  def self.queue
    @queue ||= channel.queue('orders', durable: true)
  end

  def self.publish(message, headers = {})
    exchange.publish(message.to_json, headers: headers)
    Rails.logger.info "Message published to RabbitMQ: #{message}"
  rescue => e
    Rails.logger.error "Failed to publish message to RabbitMQ: #{e.message}"
  end

  def self.consume
    queue.subscribe(block: false, manual_ack: true) do |_delivery_info, _properties, body|
      Rails.logger.info "Received message from RabbitMQ: #{body}"
      puts "Received message: #{body}"
    end
  rescue => e
    Rails.logger.error "Failed to consume messages from RabbitMQ: #{e.message}"
  end

  def self.close_connection
    connection.close if @connection && @connection.open?
  rescue => e
    Rails.logger.error "Failed to close RabbitMQ connection: #{e.message}"
  end
end
