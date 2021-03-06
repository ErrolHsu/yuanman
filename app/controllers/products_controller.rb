class ProductsController < ApplicationController


	def index


    @products = Product.products_are_selling.includes(:photo).order(created_at: :DESC).page(params[:page]).per(6)

		@articles = Article.order(created_at: :DESC).limit(4).select("id, title, created_at, article_img")

		@sticky_1 = Article.select("id, title, created_at, article_img, sticky").find_by(sticky: 1)
		@sticky_2 = Article.select("id, title, created_at, article_img, sticky").find_by(sticky: 2)

		@marked_product = Product.be_marked.products_are_selling.includes(:photo).order(created_at: :DESC)

		respond_to do |format|
			format.html
			format.js
		end	

	end

	def total_articles
		@articles = Article.page(params[:page]).per(10)
	end

	def show
		@product = Product.find(params[:id])
		@marked_product = Product.be_marked.products_are_selling.includes(:photo, :category).order(created_at: :DESC)
	end

	def add_to_cart
		@product = Product.find_by(id: params[:id])
		quantity = params[:quantity]

		if !current_cart.items.include?(@product)
			current_cart.add_product_to_cart(@product, quantity)
			flash[:success] = "你已成功將 #{@product.title} #{params[:quantity]}個加入購物車"
		else
			item = current_cart.quantity_plus(@product)
			flash[:success] = "#{@product.title}"
		end
			
		redirect_to :back

		rescue

    logger.error("Attempt to access invalid product #{params[:id]}")
    flash[:notice] = '商品不存在或已被刪除'
    redirect_to root_path

	end


end
