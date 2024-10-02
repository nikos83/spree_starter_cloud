namespace :rabbitmq do
  desc "Initialize RabbitMQ Exchange and Queue"
  task setup: :environment do
    require 'bunny'

    begin
      connection = Bunny.new(ENV['RABBITMQ_URL'] || 'amqp://guest:guest@localhost:5672')
      connection.start

      channel = connection.create_channel

      exchange = channel.headers('syncomm', durable: true)
      queue = channel.queue('orders', durable: true)
      queue.bind(exchange, arguments: { 'object_type' => 'order', 'routing_key' => 'store' })
      
      connection.close
    rescue => e
      puts "Error RabbitMQ: #{e.message}"
    end
  end
end
