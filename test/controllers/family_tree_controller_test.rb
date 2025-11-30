require "test_helper"

class FamilyTreeControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get family_tree_show_url
    assert_response :success
  end
end
