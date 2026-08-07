require "json"

module ApiTestHelpers
  def assert_json_response(expected_status)
    assert_equal expected_status, response.status
    assert_equal "application/json", response.media_type

    JSON.parse(response.body)
  end

  def assert_no_content_response
    assert_equal 204, response.status
    assert_empty response.body
  end

  def create_room(name:, building: "San Joaquín", capacity: 20)
    Room.create!(name: name, building: building, capacity: capacity)
  end

  def create_student(name:, email:)
    Student.create!(name: name, email: email)
  end
  
  def create_reservation(purpose:, reservation_date:, room:, student:, module_selected:)
    Reservation.create!(
      purpose: purpose,
      reservation_date: reservation_date,
      module_selected: module_selected,
      room: room,
      student: student
    )
  end
end
