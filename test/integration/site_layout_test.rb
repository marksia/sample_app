require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def setup
    @user = users(:test)
  end

  test "layout links" do
  	get root_path
  	assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", signup_path

    get contact_path
    assert_select "title", full_title('Contact')

    get signup_path
    assert_select "title", full_title('Sign Up')

    log_in_as(@user)
    get users_path
    assert_select "title", full_title('All Users')
  end
end
