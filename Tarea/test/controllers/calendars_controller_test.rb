require "test_helper"
#require 'calendar'


class CalendarsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @calendar1 = create(:calendar, name: "IIC2143", description: "Fechas de pruebas y tareas Ing. Software.")
    @calendar2 = create(:calendar, name: "Personal", description: "Citas medicas, eventos familiares y mas.")
    @calendar3 = create(:calendar, name: "Universidad", description: "Calendario de la universidad con fechas importantes.")
  end

  test "GET /calendars debe retornar todos los calendarios" do # 0.2 punto
    get "/calendars"
    assert_response :success
    calendars = json_response
    assert_equal 3, calendars.size
    assert_includes calendars.map { |c| c["name"] }, @calendar1.name
    assert_includes calendars.map { |c| c["name"] }, @calendar2.name
    assert_includes calendars.map { |c| c["name"] }, @calendar3.name
  end

  test "GET /calendars/:id retorna calendario existente" do # 0.2 punto
    get "/calendars/#{@calendar3.id}"
    assert_response :success
    assert_equal @calendar3.name, json_response["name"]
  end

  test "GET /calendars/:id retorna 404 para id inexistente" do # 0.2 punto
    get "/calendars/999"
    assert_response :not_found
  end

  test "POST /calendars crea calendario válido" do # 0.2 punto
    assert_difference("Calendar.count", 1) do
      post "/calendars", params: {
        calendar: { name: "Nuevo_Calendario", description: "Descripción ejemplo" }
      }
    end
    assert_response :created
    assert_equal "Nuevo_Calendario", json_response["name"]
  end

  test "POST /calendars falla sin nombre" do # 0.2 punto
    post "/calendars", params: { calendar: { description: "Sin nombre" } }
    assert_response 422
  end

  test "DELETE /calendars/:id elimina calendario y sus eventos" do # 0.4 punto
    create(:event, calendar: @calendar2)
    assert_difference("Calendar.count", -1) do
      delete "/calendars/#{@calendar2.id}"
    end
    assert_response :no_content
    assert_equal 0, Event.where(calendar_id: @calendar2.id).count
  end

  test "DELETE /calendars elimina todos los calendarios" do # 0.4 punto
    create_list(:calendar, 3)
    assert_difference("Calendar.count", -6) do
      delete "/calendars"
    end
    assert_response :no_content
  end
end
