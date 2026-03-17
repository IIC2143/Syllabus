require "test_helper"

class Level4Test < ActionDispatch::IntegrationTest

    setup do
        @brand1 = create(:brand, name: "Colun", country: "Chile")
        @brand2 = create(:brand, name: "Coca Cola", country: "USA")
        @brand3 = create(:brand, name: "Adidas", country: "Alemania")
        @product1 = create(:product, name: "Quesillo", description: "Quesillo de leche", price: 10, brand: @brand1)
        @product2 = create(:product, name: "Leche", description: "Leche entera de 1 litro", price: 20, brand: @brand1)
        @product3 = create(:product, name: "Coquita", description: "Refrescante bebida", price: 30, brand: @brand2)
        @product4 = create(:product, name: "Zapatillas", description: "Zapatillas deportivas", price: 2500, brand: @brand3)
        @buyer1 = create(:buyer, name: "Buyer_1", wallet: 1000)
        @buyer2 = create(:buyer, name: "Buyer_2", wallet: 2000)
        @buyer3 = create(:buyer, name: "Buyer_3", wallet: 100000000)

    end

    test "L4 GET /buyers/favorite_country/:buyer_id retorna el país favorito de un comprador" do # 0.4 punto
        post "/buyers/#{@buyer1.id}/buy/#{@product1.id}"
        post "/buyers/#{@buyer1.id}/buy/#{@product2.id}"
        post "/buyers/#{@buyer1.id}/buy/#{@product3.id}"
        get "/buyers/favorite_country/#{@buyer1.id}"
        assert_response :success
        favorite_country = json_response["favorite_country"]
        assert_equal "Chile", favorite_country
    end

    test "L4 GET /total_profit" do # 0.2 punto
        post "/buyers/#{@buyer3.id}/buy/#{@product1.id}"
        post "/buyers/#{@buyer3.id}/buy/#{@product2.id}"
        post "/buyers/#{@buyer3.id}/buy/#{@product3.id}"
        post "/buyers/#{@buyer3.id}/buy/#{@product4.id}"
        get "/total_profit"
        assert_response :success
        total_profit = json_response["total_profit"]
        expected_profit = @product1.price + @product2.price + @product3.price + @product4.price
        assert_equal expected_profit, total_profit
    end

    test "L4 DELETE /products/:id elimina producto existente comprado" do # 0.05 punto
        post "/buyers/#{@buyer1.id}/buy/#{@product2.id}"
        delete "/products/#{@product2.id}"
        assert_response :success
        assert_nil Product.find_by(id: @product2.id)
        @buyer1.reload
        assert_not_includes @buyer1.products, @product2

    end

    test "L4 DELETE /products/:id elimina producto existente comprado y devuelve el monto al comprador" do # 0.25 punto
        post "/buyers/#{@buyer1.id}/buy/#{@product2.id}"
        delete "/products/#{@product2.id}"
        assert_response :success
        @buyer1.reload
        assert_equal 1000, @buyer1.wallet
    end


end