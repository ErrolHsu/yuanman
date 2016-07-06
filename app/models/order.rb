class Order < ActiveRecord::Base
	include AASM

	belongs_to :user

	has_many :items, class_name: "OrderItem", dependent: :destroy
	has_one  :info,  class_name: "OrderInfo", dependent: :destroy
	has_one  :trade_info, dependent: :destroy

	accepts_nested_attributes_for :info

	before_create :generate_token, :generate_order_number

	def generate_token
		self.token = SecureRandom.uuid
	end

	def generate_order_number
		random_code = SecureRandom.uuid.gsub(/-/, '').upcase[0, 8]
		self.order_number = Time.zone.now.strftime("%y%m%d%H%M%S") + random_code
	end

	def build_item_cache_from_cart(cart)
		cart.items.each do |cart_item|
			item = self.items.build 
			item.product_name = cart_item.title
			item.quantity = cart.cart_items.find_by(product_id: cart_item).quantity
			item.price = cart_item.price
			item.save
		end	
	end

	def calculate_total!(cart)
		self.total = cart.total_price + 100
		self.save
	end

	def set_payment_with!(method)
		self.update_columns(payment_method: method )
	end

	def pay!
		self.update_columns(is_paid: true )
	end

	def trade_info_save(info)
		t_info = self.build_trade_info
  	t_info.pay_info = info
  	t_info.save
  end

	aasm do 
		state :order_placed, initial: true
		state :paid
		state :shipped
		state :order_cancelled
		state :good_returned

		event :make_payment, after_commit: :pay! do 
			transitions from: :order_placed, to: :paid
		end
		
		event :ship do 
			transitions from: :paid, 			   to: :shipped
		end
		
		event :return_good do 
			transitions from: :shipped,			 to: :good_returned
		end	

		event :cancell_order do 
			transitions from: [:order_placed, :paid], to: :order_cancelled
		end	
	end	

end
