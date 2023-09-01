require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test 'when auth token is valid' do
    user = users(:one)
    api_token = user.api_tokens.create!
    get api_v1_home_index_path, headers: { HTTP_AUTHORIZATION: "Bearer #{api_token.token}" }
    assert_response :success
  end

  test 'when auth token is invalid' do
    get api_v1_home_index_path
    assert_response :unauthorized
  end

  test 'when auth token is inactive' do
    user = users(:one)
    api_token = user.api_tokens.create!(active: false)
    get api_v1_home_index_path, headers: { HTTP_AUTHORIZATION: "Bearer #{api_token.token}" }
    assert_response :unauthorized
  end
end
