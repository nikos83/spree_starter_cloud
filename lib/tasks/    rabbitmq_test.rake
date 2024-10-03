namespace :rabbitmq do
  desc "Publikuj testową wiadomość do kolejki fulfilled.orders"
  task publish_test_message: :environment do
    require 'bunny'
    require 'json'

    begin
      # Połączenie z RabbitMQ
      connection = Bunny.new(ENV['RABBITMQ_URL'] || 'amqp://guest:guest@localhost:5672')
      connection.start

      channel = connection.create_channel
      queue = channel.queue('fulfilled.orders')

      # Przykładowa wiadomość w formacie JSON
      message = {
        number: "RORSEN044191198",
        channel: "store",
        shipment_state: "shipped",
        shipping_method: "courier",
        updated_at: Time.now.to_s,
        shipments: [
          {
            number: 1146431293,
            tracking: "660321168301401022394231",
            updated_at: Time.now.to_s,
            state: "shipped"
          }
        ]
      }.to_json

      # Publikacja wiadomości do kolejki
      queue.publish(message, persistent: true)
      puts "Wiadomość opublikowana w kolejce 'fulfilled.orders': #{message}"

      connection.close
    rescue StandardError => e
      puts "Błąd podczas publikacji wiadomości: #{e.message}"
    end
  end
end
