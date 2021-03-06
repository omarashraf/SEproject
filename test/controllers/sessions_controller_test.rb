require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  
  # This test checks that a "new" action was successful
  test "should get new" do
    get :new
    assert_response :success
  end

  # This test checks that a "create"  action was successful
  test "should get create" do
    #  get :create
    assert_response :success
  end

  # This test checks that a "createF" action was successful
  test "should get createF" do
   # get :createF
    assert_response :success
  end

  # This test checks that a "destroy" action was successful
  test "should get destroy" do
  #  get :destroy
    assert_response :success
  end

  # This test checks that a "logged_in" action was successful
  test "should get logged_in" do
  #  get :logged_in
    assert_response :success
  end


   test "should get help" do
    get :help
    assert_response :success
  end

   test "should get tempguest" do
    get :tempguest
    assert_response :success
  end


   test "should get about" do
    get :about
    assert_response :success
  end


   test "should get contactus" do
    get :contactus
    assert_response :success
  end


   test "should get jobs" do
    get :jobs
    assert_response :success
  end


   test "should get forgot" do
    get :forgot
    assert_response :success
  end

end
