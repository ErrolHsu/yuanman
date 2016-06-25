class Cart < ActiveRecord::Base
	has_many :cart_items, dependent: :destroy
	has_many :items, through: :cart_items, source: :product


	def add_product_to_cart(product, quantity)
		cart_item = self.cart_items.build
		cart_item.product = product
		cart_item.quantity = quantity
		cart_item.save
	end

	def total_price
		sum = 0

		self.cart_items.each do |cart_item|
			sum += cart_item.product.price * cart_item.quantity
		end
		
		sum	
	end

end
