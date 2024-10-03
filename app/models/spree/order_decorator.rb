module Spree
  module OrderDecorator
    def self.prepended(base)
      # Usuwamy oryginalny mixin `NumberGenerator` z prefiksem 'R'
      base.send(:include, Spree::Core::NumberGenerator.new(prefix: 'RORSEN'))
    end
  end
end

# Przepinamy dekorator do klasy `Spree::Order`
Spree::Order.prepend Spree::OrderDecorator
