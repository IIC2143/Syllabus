require "test_helper"

class Level1Test < ActionDispatch::IntegrationTest
    setup do
        @brand1 = create(:brand, name: "Colun", country: "Chile")
        @brand2 = create(:brand, name: "Coca Cola", country: "USA")
        @product1 = create(:product, name: "Quesillo", description: "Quesillo de leche", price: 10, brand: @brand1)
        @product2 = create(:product, name: "Leche", description: "Leche entera de 1 litro", price: 20, brand: @brand1)
        @product3 = create(:product, name: "Coquita", description: "Refrescante bebida", price: 30, brand: @brand2)
    end

    test "L1 GET /products retorna todos los productos" do # 0.2 punto
        get "/products"
        assert_response :success
        products = json_response
        assert_equal 3, products.size
        assert_includes products.map { |p| p["name"] }, @product1.name
        assert_includes products.map { |p| p["name"] }, @product2.name
        assert_includes products.map { |p| p["name"] }, @product3.name
    end

    test "L1 GET /products/:id retorna producto existente" do # 0.05 punto
        get "/products/#{@product2.id}"
        assert_response :success
        assert_equal @product2.name, json_response["name"]
        assert_equal @product2.description, json_response["description"]
        assert_equal @product2.price, json_response["price"]
    end
     
    test "L1 GET /products/:id lanza error 404 para producto no existente" do # 0.05 punto
        get "/products/999"
        assert_response :not_found
    end

    test "L1 POST /products/:brand_id crea un nuevo producto" do # 0.2 punto
        product_params = { name: "Yogurt", description: "Yogurt de frutas", price: 15.0 }
        post "/products/#{@brand1.id}", params: { product: product_params }
        assert_response :created
        assert_equal product_params[:name], json_response["name"]
        assert_equal product_params[:description], json_response["description"]
        assert_equal product_params[:price], json_response["price"]
    end

    test "L1 POST /products/:brand_id no crea un producto si la marca no existe" do # 0.2 punto
        product_params = { name: "Yogurt", description: "Yogurt de frutas", price: 15.0 }
        post "/products/999", params: { product: product_params }
        assert_response :unprocessable_entity
    end

    test "L1 POST /products/:brand_id no crea un producto si faltan atributos" do # 0.1 punto
        product_params = { name: "Yogurt", description: "Yogurt de frutas" }
        post "/products/#{@brand1.id}", params: { product: product_params }
        assert_response :unprocessable_entity
    end

    

end