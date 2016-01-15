class TestController < ApplicationController
  respond_to :json
  def index
    render json: {status: 'ok'}
  end
end
