require "test_helper"
require_relative "../support/api_test_helpers"

class RoomsControllerTest < ActionDispatch::IntegrationTest
  include ApiTestHelpers

  def setup
    @room = create_room(name: "Sala Andes", building: "San Joaquín", capacity: 30)
    @other_room = create_room(name: "Sala Cordillera", building: "Casa Central", capacity: 12)
  end

  test "POST /rooms creates a room and validates required attributes and positive integer capacity" do # [easy] 0.3 puntos
    post "/rooms", params: {
      room: { name: "Sala Biblioteca", building: "Biblioteca", capacity: 45 }
    }, as: :json

    body = assert_json_response(201)
    assert_equal "Sala Biblioteca", body.fetch("name")
    assert_equal "Biblioteca", body.fetch("building")
    assert_equal 45, body.fetch("capacity")
    assert Room.exists?(body.fetch("id"))

    assert_no_difference("Room.count") do
      post "/rooms", params: {
        room: { building: "Lo Contador", capacity: 0 }
      }, as: :json
    end

    errors = assert_json_response(422)
    assert errors.key?("name")
    assert errors.key?("capacity")

    assert_no_difference("Room.count") do
      post "/rooms", params: {
        room: { name: "Sin edificio", capacity: 20 }
      }, as: :json
    end

    errors = assert_json_response(422)
    assert errors.key?("building")

    assert_no_difference("Room.count") do
      post "/rooms", params: {
        room: { name: "Capacidad decimal", building: "Lo Contador", capacity: 12.5 }
      }, as: :json
    end

    errors = assert_json_response(422)
    assert errors.key?("capacity")
  end

  test "GET /rooms and /rooms/:id return rooms and JSON 404 for a missing room" do # [easy] 0.4 puntos
    get "/rooms", as: :json

    body = assert_json_response(200)
    assert_equal [@room.id, @other_room.id].sort, body.map { |room| room.fetch("id") }.sort

    get "/rooms/#{@room.id}", as: :json

    body = assert_json_response(200)
    assert_equal @room.id, body.fetch("id")
    assert_equal @room.name, body.fetch("name")
    assert_equal @room.building, body.fetch("building")
    assert_equal @room.capacity, body.fetch("capacity")

    get "/rooms/999999", as: :json

    body = assert_json_response(404)
    assert body.key?("error")
  end

  test "GET /rooms/:room_id/reservations returns reservations, an empty collection, and JSON 404 for a missing room" do # [medium] 0.6 puntos
    student = create_student(name: "Ana", email: "ana@example.test")
    reservation = create_reservation(
      purpose: "Estudio", reservation_date: Date.new(2030, 5, 15), module_selected: 2,
      room: @room, student: student
    )
    create_reservation(
      purpose: "Otra sala", reservation_date: Date.new(2030, 5, 15), module_selected: 2,
      room: @other_room, student: student
    )
    empty_room = create_room(name: "Sala Vacía", capacity: 18)

    get "/rooms/#{@room.id}/reservations", as: :json

    body = assert_json_response(200)
    assert_equal [reservation.id], body.map { |item| item.fetch("id") }
    assert body.all? { |item| item.fetch("room_id") == @room.id }

    get "/rooms/#{empty_room.id}/reservations", as: :json
    assert_equal [], assert_json_response(200)

    get "/rooms/999999/reservations", as: :json

    body = assert_json_response(404)
    assert body.key?("error")
  end

  test "GET /rooms/min_capacity/:capacity filters rooms and returns an empty collection when none qualify" do # [hard] 0.5 puntos
    large_room = create_room(name: "Sala Grande", building: "San Joaquín", capacity: 50)
    create_room(name: "Sala Pequeña", building: "San Joaquín", capacity: 8)

    get "/rooms/min_capacity/30", as: :json

    body = assert_json_response(200)
    assert_equal [@room.id, large_room.id].sort, body.map { |room| room.fetch("id") }.sort

    get "/rooms/min_capacity/100", as: :json
    assert_equal [], assert_json_response(200)
  end

  test "DELETE /rooms/:id cascades only to its reservations" do # [medium] 0.4 puntos
    student_for_deleted_room = create_student(name: "Bruno", email: "bruno@example.test")
    deleted_reservation = create_reservation(
      purpose: "Reserva eliminada", reservation_date: Date.new(2030, 5, 16), module_selected: 3,
      room: @room, student: student_for_deleted_room
    )
    preserved_student = create_student(name: "Carla", email: "carla@example.test")
    preserved_reservation = create_reservation(
      purpose: "Reserva conservada", reservation_date: Date.new(2030, 5, 16), module_selected: 3,
      room: @other_room, student: preserved_student
    )

    delete "/rooms/#{@room.id}", as: :json

    assert_no_content_response
    assert_not Room.exists?(@room.id)
    assert_not Reservation.exists?(deleted_reservation.id)
    assert Student.exists?(student_for_deleted_room.id)
    assert Room.exists?(@other_room.id)
    assert Reservation.exists?(preserved_reservation.id)
  end
end
