require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @calendar1 = create(:calendar, name: "IIC2143")
    @calendar2 = create(:calendar, name: "Personal")
    @calendar3 = create(:calendar, name: "Universidad")

    @event11 = create(:event, calendar: @calendar1, title: "Entrega tarea", date: "2025-08-24T23:59:00Z")
    @event12 = create(:event, calendar: @calendar1, title: "Interrogacion 1", date: "2025-09-26T17:30:00Z")
    @event13 = create(:event, calendar: @calendar1, title: "Ayudantia", date: "2025-08-22T12:20:00Z")

    @event21 = create(:event, calendar: @calendar2, title: "Cita medica", date: "2025-09-26T19:00:00Z")
    @event22 = create(:event, calendar: @calendar2, title: "Cumpleanos", date: "2026-09-08T00:00:00Z")
    @event23 = create(:event, calendar: @calendar2, title: "Reunión familiar", date: "2025-09-01T19:00:00Z")

    @event31 = create(:event, calendar: @calendar3, title: "Voley II", date: "2025-11-01T00:00:00Z")
    @event32 = create(:event, calendar: @calendar3, title: "Reunion ayudantia", date: "2025-10-01T13:30:00Z")
    @event33 = create(:event, calendar: @calendar3, title: "Prueba calculo", date: "2025-09-01T18:30:00Z")
  end

  test "POST /events/:calendar_id crea evento válido" do # 0.4 punto
    assert_difference("Event.count", 1) do
      post "/events/#{@calendar1.id}", params: {
        event: { title: "Nueva Ayudantia", date: "2025-08-22T16:10:00Z" }
      }
    end
    assert_response :created
    assert_equal @calendar1.id, json_response["calendar_id"]
  end

  test "POST /events/:calendar_id falla sin título" do # 0.4 punto
    post "/events/#{@calendar2.id}", params: { event: { date: "2025-10-01T00:00:00Z" } }
    assert_response 422
  end

  test "DELETE /events/:id elimina evento existente" do # 0.4 punto
    assert_difference("Event.count", -1) do
      delete "/events/#{@event31.id}"
    end
    assert_response :no_content
  end

  test "GET /events/:calendar_id retorna eventos del calendario" do # 0.5 punto
    get "/events/#{@calendar2.id}"
    assert_response :success
    assert_equal 3, json_response.size
    assert_includes json_response.map { |e| e["title"] }, @event21.title
    assert_includes json_response.map { |e| e["title"] }, @event22.title
    assert_includes json_response.map { |e| e["title"] }, @event23.title
  end

  test "PATCH /events/:id actualiza evento" do # 0.5 punto
    patch "/events/#{@event32.id}", params: { event: { date: "2026-09-10T13:45:00Z" } }
    assert_response :success
    assert_equal "2026-09-10T13:45:00Z", Time.parse(json_response["date"]).utc.strftime("%Y-%m-%dT%H:%M:%SZ")
  end

  test "GET /events/next/:calendar_id retorna evento próximo" do # 0.25 punto
    post "/events/#{@calendar1.id}", params: { event: { title: "Más cercano", date: "2025-08-24T00:00:00Z" } }
    post "/events/#{@calendar1.id}", params: { event: { title: "Más lejano", date: "2025-09-30T00:00:00Z" } }

    get "/events/next/#{@calendar1.id}", params: { nearDate: "2025-08-23T23:59:00Z" }
    assert_response :success
    assert_equal "Más cercano", json_response["title"]
  end

  test "GET /events/next3/:user_id retorna 3 eventos próximos ordenados" do # 0.25 punto
    user = create(:user)
    post "/users/#{user.id}/subscribe/#{@calendar1.id}"
    post "/users/#{user.id}/subscribe/#{@calendar2.id}"
    post "/users/#{user.id}/subscribe/#{@calendar3.id}"

    get "/events/next3/#{user.id}", params: { nearDate: "2025-09-01T00:00:00Z" }
    assert_response :success
    events = json_response
    assert_equal 3, events.size
    assert_equal [@event33.title, @event23.title, @event12.title], events.map { |e| e["title"] }
  end
end
