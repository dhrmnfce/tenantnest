require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  
  def setup
    @user1 = users(:user_one)
    @user2 = users(:user_two)
    @user3 = users(:unactivated)
  end
  
  test "index as admin including pagination (15 per page limit) and delete links" do
    log_in_as(@user1)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination', count: 2
    User.paginate(page: 1, per_page: 15).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @user1
        assert_select 'a[href=?]', user_path(user), text: 'Delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@user2)
    end
  end
  
  test "index as non-admin" do
    log_in_as(@user2)
    get users_path
    assert_select 'a', text: 'Delete', count: 0
  end
  
  test "only index profiles of activated users, redirect to root" do
    log_in_as(@user1)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination', count: 2
    User.paginate(page: 1, per_page: 15).each do |user|
      if user.activated?
        assert_select 'a[href=?]', user_path(user), text: user.name
        unless user == @user1
          assert_select 'a[href=?]', user_path(user), text: 'Delete'
        end
      else
        assert_select 'a[href=?]', user_path(user), text: user.name, count: 0
      end
    end
  end
  
  test "only show profiles of activated users, redirect to root" do
    log_in_as(@user1)
    get user_path(@user3)
    assert_redirected_to root_url
  end
  
end
