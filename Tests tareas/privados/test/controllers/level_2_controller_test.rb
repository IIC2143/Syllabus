require "test_helper"

class Level2Test < ActionDispatch::IntegrationTest

    setup do
        @brand1 = create(:brand, name: "Nestle", country: "Suiza")
        @brand2 = create(:brand, name: "Cheetos", country: "Estados Unidos")
        @brand3 = create(:brand, name: "Bimbo", country: "Mexico")
        @brand4 = create(:brand, name: "Carozzi", country: "Chile")
        @buyer1 = create(:buyer, name: "Checo", wallet: 10000)
        @product1 = create(:product, name: "Leche en polvo", description: "Leche nido para menores de 3 años", price: 30, brand: @brand1)
        @product2 = create(:product, name: "Trencito", description: "Delicioso chocolate de 150gr", price: 15, brand: @brand1)
        @product3 = create(:product, name: "Cheetos crunchy", description: "Más crujientes y picantes", price: 10, brand: @brand2)
        @product4 = create(:product, name: "Bimbo pan", description: "Pan de caja Bimbo", price: 20, brand: @brand3)
    end

    test "L2 DELETE /brands/:id elimina marca existente sin productos asociados" do # 0.2 punto
        delete "/brands/#{@brand4.id}"
        assert_response :success
    end

    test "L2 DELETE /brands/:id elimina marca y todos sus productos asociados" do # 0.7 punto
        delete "/brands/#{@brand1.id}"
        assert_response :success
        assert_nil Brand.find_by(id: @brand1.id)
        assert_nil Product.find_by(name: @product1.name)
        assert_nil Product.find_by(name: @product2.name)
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
        product_params = { name: "Pan de molde", price: 10 }
        patch "/products/#{@product4.id}", params: { product: product_params }
        assert_response :success
        assert_equal product_params[:name], json_response["name"]
        assert_equal product_params[:price], json_response["price"]
    end

end