every 1.minutes do
  rake "rabbitmq:consume_messages"
end
