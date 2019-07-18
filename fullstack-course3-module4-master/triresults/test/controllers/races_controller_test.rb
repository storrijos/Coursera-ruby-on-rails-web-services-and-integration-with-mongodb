require 'test_helper'

class RacesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @race = races(:one)
  end

  test "should get index" do
    get races_url
    assert_response :success
  end

  test "should get new" do
    get new_race_url
    assert_response :success
  end

  test "should create race" do
    assert_difference('Race.count') do
      post races_url, params: { race: { bike_distance: @race.bike_distance, bike_units: @race.bike_units, city: @race.city, date: @race.date, name: @race.name, run_distance: @race.run_distance, run_units: @race.run_units, state: @race.state, swim_distance: @race.swim_distance, swim_units: @race.swim_units } }
    end

    assert_redirected_to race_url(Race.last)
  end

  test "should show race" do
    get race_url(@race)
    assert_response :success
  end

  test "should get edit" do
    get edit_race_url(@race)
    assert_response :success
  end

  test "should update race" do
    patch race_url(@race), params: { race: { bike_distance: @race.bike_distance, bike_units: @race.bike_units, city: @race.city, date: @race.date, name: @race.name, run_distance: @race.run_distance, run_units: @race.run_units, state: @race.state, swim_distance: @race.swim_distance, swim_units: @race.swim_units } }
    assert_redirected_to race_url(@race)
  end

  test "should destroy race" do
    assert_difference('Race.count', -1) do
      delete race_url(@race)
    end

    assert_redirected_to races_url
  end
end
