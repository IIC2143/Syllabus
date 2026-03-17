require "test_helper"

class Level3Test < ActionDispatch::IntegrationTest

    setup do
        @brand1 = create(:brand, name: "Colun", country: "Chile")
        @brand2 = create(:brand, name: "Coca Cola", country: "USA")
        @brand3 = create(:brand, name: "Adidas", country: "Alemania")
        @product1 = create(:product, name: "Quesillo", description: "Quesillo de leche", price: 10, brand: @brand1)
        @product2 = create(:product, name: "Leche", description: "Leche entera de 1 litro", price: 20, brand: @brand1)
        @product3 = create(:product, name: "Coquita", description: "Refrescante bebida", price: 30, brand: @brand2)
        @product4 = create(:product, name: "Zapatillas", description: "Zapatillas deportivas", price: 2500, brand: @brand3)
        @buyer2 = create(:buyer, name: "Buyer_2", wallet: 2000)
        @buyer1 = create(:buyer, name: "Buyer_1", wallet: 1000)
    end

    test "L3 POST /buyers/:buyer_id/buy/:product_id permite a un comprador realizar una compra" do # 0.1 punto
        post "/buyers/#{@buyer1.id}/buy/#{@product1.id}"
        assert_response :success
        @buyer1.reload
        assert_includes @buyer1.products, @product1
    end

    test "L3 POST /buyers/:buyer_id/buy/:product_id permite la compra y actualiza la wallet" do # 0.3 punto
        initial_wallet = @buyer1.wallet
        post "/buyers/#{@buyer1.id}/buy/#{@product1.id}"
        @buyer1.reload
        assert_equal initial_wallet - @product1.price, @buyer1.wallet
    end

    test "L3 POST /buyers/:buyer_id/buy/:product_id permite la compra y actualiza la disponibilidad del producto" do # 0.4 punto
        post "/buyers/#{@buyer1.id}/buy/#{@product1.id}"
        @product1.reload
        assert_equal false, @product1.available
    end

    test "L3 POST /buyers/:buyer_id/buy/:product_id no permite una compra sin suficiente dinero" do # 0.1 punto
        post "/buyers/#{@buyer2.id}/buy/#{@product4.id}"
        assert_response :unprocessable_entity
        @buyer2.reload
        assert_equal 2000, @buyer2.wallet
    end

    test "L3 POST /buyers/:buyer_id/buy/:product_id no permite una compra si no existe el producto" do # 0.05 punto
        post "/buyers/#{@buyer1.id}/buy/99999"
        assert_response :not_found
    end

    test "L3 POST /buyers/:buyer_id/buy/:product_id no permite una compra si no existe el comprador" do # 0.05 punto
        post "/buyers/99999/buy/#{@product1.id}"
        assert_response :not_found
    end

    test "L3 GET /buyers/products/:buyer_id retorna los productos comprados por un comprador" do # 0.2 punto
        post "/buyers/#{@buyer1.id}/buy/#{@product1.id}"
        post "/buyers/#{@buyer1.id}/buy/#{@product2.id}"
        get "/buyers/products/#{@buyer1.id}"
        assert_response :success
        products = json_response
        assert_equal 2, products.size
        assert_includes products.map { |p| p["name"] }, @product1.name
        assert_includes products.map { |p| p["name"] }, @product2.name
    end

    test "L3 GET /buyers/products/:buyer_id retorna una lista vacía cuando el comprador no ha comprado productos" do # 0.1 punto
        get "/buyers/products/#{@buyer2.id}"
        assert_response :success
        products = json_response
        assert_equal 0, products.size
    end
end