require "test_helper"
require_relative "../support/api_test_helpers"

class StudentsControllerTest < ActionDispatch::IntegrationTest
  include ApiTestHelpers

  def setup
    @student = create_student(name: "Ada Lovelace", email: "ada@example.test")
    @other_student = create_student(name: "Grace Hopper", email: "grace@example.test")
  end

  test "POST /students creates a student and validates required name and email" do # [easy] 0.2 puntos
    post "/students", params: {
      student: { name: "Linus Torvalds", email: "linus@example.test" }
    }, as: :json

    body = assert_json_response(201)
    assert_equal "Linus Torvalds", body.fetch("name")
    assert_equal "linus@example.test", body.fetch("email")
    assert Student.exists?(body.fetch("id"))

    assert_no_difference("Student.count") do
      post "/students", params: {
        student: { name: "", email: "" }
      }, as: :json
    end

    errors = assert_json_response(422)
    assert errors.key?("name")
    assert errors.key?("email")
  end

  test "POST /students validates unique email" do # [easy] 0.2 puntos
    assert_no_difference("Student.count") do
      post "/students", params: {
        student: { name: "Otra Ada", email: @student.email }
      }, as: :json
    end

    errors = assert_json_response(422)
    assert errors.key?("email")
  end

  test "GET /students and /students/:id return students and JSON 404 for a missing student" do # [easy] 0.4 puntos
    get "/students", as: :json

    body = assert_json_response(200)
    assert_equal [@student.id, @other_student.id].sort,
                 body.map { |student| student.fetch("id") }.sort

    get "/students/#{@student.id}", as: :json

    body = assert_json_response(200)
    assert_equal @student.id, body.fetch("id")
    assert_equal @student.name, body.fetch("name")
    assert_equal @student.email, body.fetch("email")

    get "/students/999999", as: :json

    body = assert_json_response(404)
    assert body.key?("error")
  end

  test "GET /students/:student_id/reservations returns only that student's reservations, an empty collection, and JSON 404 for a missing student" do # [medium] 0.6 puntos
    first_room = create_room(name: "Sala Conteo 1", capacity: 20)
    second_room = create_room(name: "Sala Conteo 2", capacity: 20)
    first_reservation = create_reservation(
      purpose: "Control 1", reservation_date: Date.new(2030, 7, 1), module_selected: 1,
      room: first_room, student: @student
    )
    second_reservation = create_reservation(
      purpose: "Control 2", reservation_date: Date.new(2030, 7, 1), module_selected: 1,
      room: second_room, student: @student
    )
    create_reservation(
      purpose: "Otro estudiante", reservation_date: Date.new(2030, 7, 1), module_selected: 2,
      room: first_room, student: @other_student
    )
    empty_student = create_student(name: "Gabriel", email: "gabriel@example.test")

    get "/students/#{@student.id}/reservations", as: :json

    body = assert_json_response(200)
    assert_equal [first_reservation.id, second_reservation.id].sort,
                 body.map { |reservation| reservation.fetch("id") }.sort
    assert body.all? { |reservation| reservation.fetch("student_id") == @student.id }

    get "/students/#{empty_student.id}/reservations", as: :json
    assert_equal [], assert_json_response(200)

    get "/students/999999/reservations", as: :json

    body = assert_json_response(404)
    assert body.key?("error")
  end

  test "GET /students/:student_id/reservations/count returns the count, zero, and JSON 404 for a missing student" do # [hard] 0.5 puntos
    first_room = create_room(name: "Sala Conteo 1", capacity: 20)
    second_room = create_room(name: "Sala Conteo 2", capacity: 20)
    create_reservation(
      purpose: "Control 1", reservation_date: Date.new(2030, 7, 2), module_selected: 1,
      room: first_room, student: @student
    )
    create_reservation(
      purpose: "Control 2", reservation_date: Date.new(2030, 7, 2), module_selected: 1,
      room: second_room, student: @student
    )
    empty_student = create_student(name: "Gabriel", email: "gabriel@example.test")

    get "/students/#{@student.id}/reservations/count", as: :json

    body = assert_json_response(200)
    assert_equal @student.id, body.fetch("student_id")
    assert_equal 2, body.fetch("reservations_count")

    get "/students/#{empty_student.id}/reservations/count", as: :json

    body = assert_json_response(200)
    assert_equal empty_student.id, body.fetch("student_id")
    assert_equal 0, body.fetch("reservations_count")

    get "/students/999999/reservations/count", as: :json

    body = assert_json_response(404)
    assert body.key?("error")
  end

  test "DELETE /students/:id cascades only to that student's reservations" do # [medium] 0.4 puntos
    room_for_deleted_student = create_room(name: "Sala Norte", capacity: 25)
    deleted_reservation = create_reservation(
      purpose: "Tarea", reservation_date: Date.new(2030, 6, 10), module_selected: 4,
      room: room_for_deleted_student, student: @student
    )
    preserved_room = create_room(name: "Sala Sur", capacity: 25)
    preserved_reservation = create_reservation(
      purpose: "Reunión", reservation_date: Date.new(2030, 6, 11), module_selected: 5,
      room: preserved_room, student: @other_student
    )

    delete "/students/#{@student.id}", as: :json

    assert_no_content_response
    assert_not Student.exists?(@student.id)
    assert_not Reservation.exists?(deleted_reservation.id)
    assert Room.exists?(room_for_deleted_student.id)
    assert Student.exists?(@other_student.id)
    assert Reservation.exists?(preserved_reservation.id)
  end
end
