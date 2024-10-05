namespace :rabbitmq do
  desc "Consume messages from RabbitMQ and process orders"
  task consume_messages: :environment do
    namespace :rabbitmq do
      begin
        connection = Bunny.new(ENV['RABBITMQ_URL'] || 'amqp://guest:guest@localhost:5672')
        connection.start
  
        channel = connection.create_channel
        queue = channel.queue('fulfilled.orders', durable: false)
  
        queue.subscribe(block: true) do |delivery_info, _properties, body|
          @rabbit_body = body
          message = JSON.parse(@rabbit_body)
          UpdateOrderService.new(message).call

          channel.ack(delivery_info.delivery_tag)
        end
  
  
        connection.close
      rescue StandardError => e
        puts "Błąd podczas odbierania wiadomości: #{e.message}"
      end
    end
  end
end
