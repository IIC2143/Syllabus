require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user1 = create(:user, name: "Pedro Pascal", email: "pedrito@example.com")
    @user2 = create(:user, name: "Edo Caroe", email: "contacto@edocaroe.cl")
    @user3 = create(:user, name: "Isabel Allende", email: "asistente@isabelallende.com")
  end

  test "GET /users retorna todos los usuarios" do # 0.2 punto
    get "/users"
    assert_response :success
    assert_equal 3, json_response.size
  end

  test "POST /users crea usuario válido" do # 0.2 punto
    assert_difference("User.count", 1) do
      post "/users", params: {
        user: { 
          name: "Ana", 
          email: "ana@example.com" }
      }
    end
    assert_response :created
  end

  test "POST /users falla sin email" do # 0.2 punto
    post "/users", params: { user: { name: "Sin Email" } }
    assert_response 422
  end

  test "DELETE /users/:id elimina usuario existente" do # 0.2 punto
    assert_difference("User.count", -1) do
      delete "/users/#{@user1.id}"
    end
    assert_response :no_content
  end

  test "DELETE /users elimina todos los usuarios" do # 0.2 punto
    create_list(:user, 3)
    assert_difference("User.count", -6) do
      delete "/users"
    end
    assert_response :no_content
  end

  test "POST /users/:user_id/subscribe/:calendar_id suscribe usuario a calendario" do # 0.25 punto
    calendar = create(:calendar)
    post "/users/#{@user1.id}/subscribe/#{calendar.id}"
    assert_response :success
    # Verifica que el usuario esté suscrito al calendario
    # ya sea con una relación directa o a través de un join table
    # o un model intermedio (siempre que se use has_many :through)
    assert_includes @user1.reload.calendars, calendar
  end

  test "POST /users/:user_id/subscribe/:calendar_id retorna 404 si calendario no existe" do # 0.25 punto
    post "/users/#{@user2.id}/subscribe/999"
    assert_response :not_found
  end

end
