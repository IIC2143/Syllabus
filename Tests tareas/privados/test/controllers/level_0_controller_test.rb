require "test_helper"

class Level0Test < ActionDispatch::IntegrationTest

  setup do
      @brand1 = create(:brand, name: "Nestle", country: "Suiza")
      @brand2 = create(:brand, name: "Cheetos", country: "Estados Unidos")
      @brand3 = create(:brand, name: "Bimbo", country: "Mexico")
      @buyer1 = create(:buyer, name: "Checo", wallet: 10000)
      @buyer2 = create(:buyer, name: "Max", wallet: 7000000)
      @buyer3 = create(:buyer, name: "Carlos", wallet: 300000)
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
    brand_params = { name: "Ferrero", country: "Italia" }
    post "/brands", params: { brand: brand_params }
    assert_response :created
    assert_equal brand_params[:name], json_response["name"]
    assert_equal brand_params[:country], json_response["country"]
  end

  test "L0 POST /brands no crea una marca sin nombre" do # 0.1 punto
    brand_params = { country: "Chile" }
    post "/brands", params: { brand: brand_params }
    assert_response :unprocessable_entity
  end

  test "L0 POST /brands no crea una marca sin país" do # 0.1 punto
    brand_params = { name: "Carozzi" }
    post "/brands", params: { brand: brand_params }
    assert_response :unprocessable_entity
  end

  test "L0 POST /buyers crea un nuevo comprador" do # 0.1 punto
    buyer_params = { name: "Pancho", wallet: 1000000 }
    post "/buyers", params: { buyer: buyer_params }
    assert_response :created
    assert_equal buyer_params[:name], json_response["name"]
    assert_equal buyer_params[:wallet], json_response["wallet"]
  end

  test "L0 POST /buyers no crea un comprador sin nombre" do # 0.1 punto
    buyer_params = { wallet: 12345678 }
    post "/buyers", params: { buyer: buyer_params }
    assert_response :unprocessable_entity
  end

  test "L0 POST /buyers no crea un comprador sin wallet" do # 0.1 punto
    buyer_params = { name: "Coni Huerta" }
    post "/buyers", params: { buyer: buyer_params }
    assert_response :unprocessable_entity
  end

end