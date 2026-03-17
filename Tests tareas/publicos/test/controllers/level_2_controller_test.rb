require "test_helper"

class Level2Test < ActionDispatch::IntegrationTest

    setup do
        @brand1 = create(:brand, name: "Colun", country: "Chile")
        @brand2 = create(:brand, name: "Coca Cola", country: "USA")
        @brand3 = create(:brand, name: "Adidas", country: "Alemania")
        @product1 = create(:product, name: "Quesillo", description: "Quesillo de leche", price: 10, brand: @brand1)
        @product2 = create(:product, name: "Leche", description: "Leche entera de 1 litro", price: 20, brand: @brand1)
        @product3 = create(:product, name: "Coquita", description: "Refrescante bebida", price: 30, brand: @brand2)
        @product4 = create(:product, name: "Zapatillas", description: "Zapatillas deportivas", price: 50, brand: @brand3)
        @buyer1 = create(:buyer, name: "Buyer_1", wallet: 1000)
    end

    test "L2 DELETE /brands/:id elimina marca existente sin productos asociados" do # 0.2 punto
        delete "/brands/#{@brand3.id}"
        assert_response :success
    end

    test "L2 DELETE /brands/:id elimina marca y todos sus productos asociados" do # 0.7 punto
        delete "/brands/#{@brand1.id}"
        assert_response :success
        assert_nil Brand.find_by(id: @brand1.id)
        assert_nil Product.find_by(name: "Quesillo")
        assert_nil Product.find_by(name: "Leche")
    end

    test "L2 DELETE /buyers/:id elimina comprador existente sin compras asociadas" do # 0.6 punto
        delete "/buyers/#{@buyer1.id}"
        assert_response :success
        assert_nil Buyer.find_by(id: @buyer1.id)
    end

    test "L2 DELETE /products/:id elimina producto existente no comprado" do # 0.3 punto
        delete "/products/#{@product3.id}"
        assert_response :success
        assert_nil Product.find_by(id: @product3.id)
    end

    test "L2 PATCH /products/:id actualiza producto existente" do # 0.2 punto
        product_params = { description: "Calzado deportivo", price: 110 }
        patch "/products/#{@product4.id}", params: { product: product_params }
        assert_response :success
        assert_equal product_params[:description], json_response["description"]
        assert_equal product_params[:price], json_response["price"]
    end

end