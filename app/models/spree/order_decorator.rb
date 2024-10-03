module Spree
  module OrderDecorator
    def self.prepended(base)
      base.include Spree::Core::NumberGenerator.new(prefix: 'RORSEN')
    end
  end
end

Spree::Order.prepend Spree::OrderDecorator
