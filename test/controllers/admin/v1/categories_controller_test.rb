require "test_helper"

class Admin::V1::CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_v1_category = admin_v1_categories(:one)
  end

  test "should get index" do
    get admin_v1_categories_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_v1_category_url
    assert_response :success
  end

  test "should create admin_v1_category" do
    assert_difference("Admin::V1::Category.count") do
      post admin_v1_categories_url, params: { admin_v1_category: { name: @admin_v1_category.name, position: @admin_v1_category.position, slug: @admin_v1_category.slug } }
    end

    assert_redirected_to admin_v1_category_url(Admin::V1::Category.last)
  end

  test "should show admin_v1_category" do
    get admin_v1_category_url(@admin_v1_category)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_v1_category_url(@admin_v1_category)
    assert_response :success
  end

  test "should update admin_v1_category" do
    patch admin_v1_category_url(@admin_v1_category), params: { admin_v1_category: { name: @admin_v1_category.name, position: @admin_v1_category.position, slug: @admin_v1_category.slug } }
    assert_redirected_to admin_v1_category_url(@admin_v1_category)
  end

  test "should destroy admin_v1_category" do
    assert_difference("Admin::V1::Category.count", -1) do
      delete admin_v1_category_url(@admin_v1_category)
    end

    assert_redirected_to admin_v1_categories_url
  end
end
