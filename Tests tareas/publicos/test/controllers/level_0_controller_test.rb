require "test_helper"

class Level0Test < ActionDispatch::IntegrationTest

  setup do
      @brand1 = create(:brand, name: "Colun", country: "Chile")
      @brand2 = create(:brand, name: "Coca Cola", country: "USA")
      @brand3 = create(:brand, name: "Adidas", country: "Alemania")
      @buyer1 = create(:buyer, name: "Buyer_1", wallet: 1000)
      @buyer2 = create(:buyer, name: "Buyer_2", wallet: 2000)
      @buyer3 = create(:buyer, name: "Buyer_3", wallet: 3000)
  end

  test "L0 GET /brands retorna todas las marcas existentes" do # 0.1 punto
    get "/brands"
    assert_response :success
    brands = json_response
    assert_equal 3, brands.size
    assert_includes brands.map { |b| b["name"] }, @brand1.name
    assert_includes brands.map { |b| b["name"] }, @brand2.name
    assert_includes brands.map { |b| b["name"] }, @brand3.name
  end

  test "L0 GET /brands/:id retorna marca existente" do # 0.05 punto
    get "/brands/#{@brand3.id}"
    assert_response :success
    assert_equal @brand3.name, json_response["name"]
  end

  test "L0 GET /brands/:id lanza error 404 para marca no existente" do # 0.05 punto
    get "/brands/999"
    assert_response :not_found
  end

  test "L0 GET /buyers retorna todos los compradores existentes" do # 0.1 punto
    get "/buyers"
    assert_response :success
    buyers = json_response
    assert_equal 3, buyers.size
    assert_includes buyers.map { |b| b["name"] }, @buyer1.name
    assert_includes buyers.map { |b| b["name"] }, @buyer2.name
    assert_includes buyers.map { |b| b["name"] }, @buyer3.name
  end

  test "L0 GET /buyers/:id retorna comprador existente" do # 0.05 punto
    get "/buyers/#{@buyer3.id}"
    assert_response :success
    assert_equal @buyer3.name, json_response["name"]
  end

  test "L0 GET /buyers/:id lanza error 404 para comprador no existente" do # 0.05 punto
    get "/buyers/999"
    assert_response :not_found
  end

  test "L0 POST /brands crea una nueva marca" do # 0.1 punto
    brand_params = { name: "Del Valle", country: "Mexico" }
    post "/brands", params: { brand: brand_params }
    assert_response :created
    assert_equal brand_params[:name], json_response["name"]
    assert_equal brand_params[:country], json_response["country"]
  end

  test "L0 POST /brands no crea una marca sin nombre" do # 0.1 punto
    brand_params = { country: "Mexico" }
    post "/brands", params: { brand: brand_params }
    assert_response :unprocessable_entity
  end

  test "L0 POST /brands no crea una marca sin país" do # 0.1 punto
    brand_params = { name: "Del Valle" }
    post "/brands", params: { brand: brand_params }
    assert_response :unprocessable_entity
  end

  test "L0 POST /buyers crea un nuevo comprador" do # 0.1 punto
    buyer_params = { name: "JP Sandoval", wallet: 1000000 }
    post "/buyers", params: { buyer: buyer_params }
    assert_response :created
    assert_equal buyer_params[:name], json_response["name"]
    assert_equal buyer_params[:wallet], json_response["wallet"]
  end

  test "L0 POST /buyers no crea un comprador sin nombre" do # 0.1 punto
    buyer_params = { wallet: 1000000 }
    post "/buyers", params: { buyer: buyer_params }
    assert_response :unprocessable_entity
  end

  test "L0 POST /buyers no crea un comprador sin wallet" do # 0.1 punto
    buyer_params = { name: "JP Sandoval" }
    post "/buyers", params: { buyer: buyer_params }
    assert_response :unprocessable_entity
  end

end