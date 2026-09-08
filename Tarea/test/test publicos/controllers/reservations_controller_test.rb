require "test_helper"
require_relative "../support/api_test_helpers"

class ReservationsControllerTest < ActionDispatch::IntegrationTest
  include ApiTestHelpers

  def setup
    @room = create_room(name: "Sala Reservas", capacity: 30)
    @other_room = create_room(name: "Sala Alternativa", capacity: 20)
    @student = create_student(name: "Carla", email: "carla@example.test")
    @other_student = create_student(name: "Diego", email: "diego@example.test")
    @reservation = create_reservation(
      purpose: "Preparación I1", reservation_date: Date.new(2030, 8, 20), module_selected: 3,
      room: @room, student: @student
    )
  end

  test "POST /reservations creates a reservation and validates required attributes" do # [medium] 0.15 puntos
    post "/reservations", params: {
      reservation: {
        purpose: "Reunión de proyecto",
        reservation_date: "2030-08-21",
        module_selected: 5,
        room_id: @room.id,
        student_id: @other_student.id
      }
    }, as: :json

    body = assert_json_response(201)
    assert_equal "Reunión de proyecto", body.fetch("purpose")
    assert_equal "2030-08-21", body.fetch("reservation_date")
    assert_equal 5, body.fetch("module_selected")
    assert_equal @room.id, body.fetch("room_id")
    assert_equal @other_student.id, body.fetch("student_id")
    assert Reservation.exists?(body.fetch("id"))

    assert_no_difference("Reservation.count") do
      post "/reservations", params: {
        reservation: {
          reservation_date: "2030-08-22", module_selected: 3,
          room_id: @room.id, student_id: @student.id
        }
      }, as: :json
    end
    errors = assert_json_response(422)
    assert errors.key?("purpose")

    assert_no_difference("Reservation.count") do
      post "/reservations", params: {
        reservation: {
          purpose: "Sin fecha", module_selected: 3,
          room_id: @room.id, student_id: @student.id
        }
      }, as: :json
    end
    errors = assert_json_response(422)
    assert errors.key?("reservation_date")

    assert_no_difference("Reservation.count") do
      post "/reservations", params: {
        reservation: {
          purpose: "Sin módulo", reservation_date: "2030-08-22",
          room_id: @room.id, student_id: @student.id
        }
      }, as: :json
    end
    errors = assert_json_response(422)
    assert errors.key?("module_selected")

    assert_no_difference("Reservation.count") do
      post "/reservations", params: {
        reservation: {
          purpose: "Sin sala", reservation_date: "2030-08-22", module_selected: 3,
          student_id: @student.id
        }
      }, as: :json
    end
    errors = assert_json_response(422)
    assert errors.key?("room") || errors.key?("room_id")

    assert_no_difference("Reservation.count") do
      post "/reservations", params: {
        reservation: {
          purpose: "Sin estudiante", reservation_date: "2030-08-22", module_selected: 3,
          room_id: @room.id
        }
      }, as: :json
    end
    errors = assert_json_response(422)
    assert errors.key?("student") || errors.key?("student_id")
  end

  test "POST /reservations validates module_selected is an integer between one and nine" do # [medium] 0.1 puntos
    [0, 2.5, 10].each_with_index do |invalid_module_selected, index|
      post "/reservations", params: {
        reservation: {
          purpose: "Módulo inválido #{index}", reservation_date: "2030-08-22", module_selected: invalid_module_selected,
          room_id: @room.id, student_id: @student.id
        }
      }, as: :json

      errors = assert_json_response(422)
      assert errors.key?("module_selected")
    end
  end

  test "POST /reservations returns JSON 404 for missing associations" do # [medium] 0.1 puntos
    post "/reservations", params: {
      reservation: {
        purpose: "Sala inexistente", reservation_date: "2030-08-23", module_selected: 2,
        room_id: 999999, student_id: @student.id
      }
    }, as: :json

    body = assert_json_response(404)
    assert body.key?("error")

    post "/reservations", params: {
      reservation: {
        purpose: "Estudiante inexistente", reservation_date: "2030-08-23", module_selected: 2,
        room_id: @room.id, student_id: 999999
      }
    }, as: :json

    body = assert_json_response(404)
    assert body.key?("error")
  end

  test "POST /reservations prevents duplicate room date and module_selected reservations" do # [medium] 0.1 puntos
    assert_no_difference("Reservation.count") do
      post "/reservations", params: {
        reservation: {
          purpose: "Reserva duplicada", reservation_date: "2030-08-20", module_selected: 3,
          room_id: @room.id, student_id: @other_student.id
        }
      }, as: :json
    end

    errors = assert_json_response(422)
    assert errors.key?("room_id")
  end

  test "POST /reservations allows a different module_selected or a different room" do # [medium] 0.05 puntos
    post "/reservations", params: {
      reservation: {
        purpose: "Mismo día, otro módulo", reservation_date: "2030-08-20", module_selected: 4,
        room_id: @room.id, student_id: @other_student.id
      }
    }, as: :json
    assert_json_response(201)

    post "/reservations", params: {
      reservation: {
        purpose: "Mismo día, otra sala", reservation_date: "2030-08-20", module_selected: 3,
        room_id: @other_room.id, student_id: @other_student.id
      }
    }, as: :json
    assert_json_response(201)
  end

  test "GET /reservations and /reservations/:id return reservations and JSON 404 for a missing reservation" do # [medium] 0.4 puntos
    other_reservation = create_reservation(
      purpose: "Preparación I2", reservation_date: Date.new(2030, 8, 20), module_selected: 4,
      room: @room, student: @other_student
    )

    get "/reservations", as: :json

    body = assert_json_response(200)
    assert_equal [@reservation.id, other_reservation.id].sort,
                 body.map { |reservation| reservation.fetch("id") }.sort

    get "/reservations/#{@reservation.id}", as: :json

    body = assert_json_response(200)
    assert_equal @reservation.id, body.fetch("id")
    assert_equal @reservation.purpose, body.fetch("purpose")
    assert_equal "2030-08-20", body.fetch("reservation_date")
    assert_equal 3, body.fetch("module_selected")
    assert_equal @room.id, body.fetch("room_id")
    assert_equal @student.id, body.fetch("student_id")

    get "/reservations/999999", as: :json

    body = assert_json_response(404)
    assert body.key?("error")
  end

  test "PATCH /reservations/:id updates sent associations and returns JSON 404 for missing associations" do # [medium] 0.1 puntos
    patch "/reservations/#{@reservation.id}", params: {
      reservation: { student_id: @other_student.id }
    }, as: :json

    body = assert_json_response(200)
    assert_equal @other_student.id, body.fetch("student_id")

    patch "/reservations/#{@reservation.id}", params: {
      reservation: { student_id: 999999 }
    }, as: :json

    body = assert_json_response(404)
    assert body.key?("error")

    patch "/reservations/#{@reservation.id}", params: {
      reservation: { room_id: 999999 }
    }, as: :json

    body = assert_json_response(404)
    assert body.key?("error")
  end

  test "PATCH /reservations/:id validates module_selected and preserves the reservation" do # [medium] 0.1 puntos
    patch "/reservations/#{@reservation.id}", params: {
      reservation: { purpose: "Preparación Examen" }
    }, as: :json

    body = assert_json_response(200)
    assert_equal "Preparación Examen", body.fetch("purpose")
    assert_equal "2030-08-20", body.fetch("reservation_date")
    assert_equal 3, body.fetch("module_selected")
    assert_equal @room.id, body.fetch("room_id")
    assert_equal @student.id, body.fetch("student_id")

    patch "/reservations/#{@reservation.id}", params: {
      reservation: { module_selected: 0 }
    }, as: :json

    errors = assert_json_response(422)
    assert errors.key?("module_selected")
    assert_equal 3, Reservation.find(@reservation.id).read_attribute(:module_selected)
  end

  test "PATCH /reservations/:id prevents conflicts and ignores itself" do # [medium] 0.2 puntos
    occupied_reservation = create_reservation(
      purpose: "Reserva ocupada", reservation_date: Date.new(2030, 8, 24), module_selected: 2,
      room: @room, student: @student
    )
    reservation = create_reservation(
      purpose: "Reserva movible", reservation_date: Date.new(2030, 8, 24), module_selected: 3,
      room: @room, student: @other_student
    )

    patch "/reservations/#{reservation.id}", params: {
      reservation: { module_selected: 3 }
    }, as: :json

    body = assert_json_response(200)
    assert_equal 3, body.fetch("module_selected")

    patch "/reservations/#{reservation.id}", params: {
      reservation: { module_selected: occupied_reservation.read_attribute(:module_selected) }
    }, as: :json

    errors = assert_json_response(422)
    assert errors.key?("room_id")
    assert_equal 3, Reservation.find(reservation.id).read_attribute(:module_selected)
  end

  test "DELETE /reservations/:id deletes a reservation and returns JSON 404 for a missing reservation" do # [medium] 0.2 puntos
    delete "/reservations/#{@reservation.id}", as: :json

    assert_no_content_response
    assert_not Reservation.exists?(@reservation.id)
    assert Room.exists?(@room.id)
    assert Student.exists?(@student.id)

    delete "/reservations/#{@reservation.id}", as: :json

    body = assert_json_response(404)
    assert body.key?("error")
  end
end
