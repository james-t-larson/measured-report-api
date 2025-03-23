require "application_system_test_case"

class Admin::V1::CategoriesTest < ApplicationSystemTestCase
  setup do
    @admin_v1_category = admin_v1_categories(:one)
  end

  test "visiting the index" do
    visit admin_v1_categories_url
    assert_selector "h1", text: "Categories"
  end

  test "should create category" do
    visit admin_v1_categories_url
    click_on "New category"

    fill_in "Name", with: @admin_v1_category.name
    fill_in "Position", with: @admin_v1_category.position
    fill_in "Slug", with: @admin_v1_category.slug
    click_on "Create Category"

    assert_text "Category was successfully created"
    click_on "Back"
  end

  test "should update Category" do
    visit admin_v1_category_url(@admin_v1_category)
    click_on "Edit this category", match: :first

    fill_in "Name", with: @admin_v1_category.name
    fill_in "Position", with: @admin_v1_category.position
    fill_in "Slug", with: @admin_v1_category.slug
    click_on "Update Category"

    assert_text "Category was successfully updated"
    click_on "Back"
  end

  test "should destroy Category" do
    visit admin_v1_category_url(@admin_v1_category)
    click_on "Destroy this category", match: :first

    assert_text "Category was successfully destroyed"
  end
end
