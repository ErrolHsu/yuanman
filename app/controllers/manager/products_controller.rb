class Manager::ProductsController < ManagerController


	def index
		@products = Product.all.includes(:photo)
	end

	def new
		@product = Product.new
		@photo = @product.build_photo
	end

	def create
		@product = Product.new(product_params)

		if @product.save
			redirect_to products_path
		else
			render :new
		end		
	end

	def edit
		@product = Product.find(params[:id])
		@photo = @product.photo || @product.build_photo
	end

	def update
		@product = Product.find(params[:id])

		if @product.update(product_params)
			redirect_to root_path
		else
		 render :edit
		end 	
	end

	def destroy
		@product = Product.find(params[:id])

		if @product.destroy

			flash[:warning] = "#{@product.title} 已被刪除"
			redirect_to :back
		else
			render :index
		end	
	end

	def off_shelf
		@product = Product.find(params[:id])
		@product.off_shelf

		flash[:success] = "#{@product.title} 已下架"
		redirect_to :back
	end

	def on_shelf
		@product = Product.find(params[:id])
		@product.on_shelf

		flash[:success] = "#{@product.title} 已上架"
		redirect_to :back		
	end


	private

		def product_params
			params.require(:product).permit(:title, :description, :quantity, :price,
																			 photo_attributes: [:image, :id])
		end

end
