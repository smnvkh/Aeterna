class Api::V1::WelcomeController < ApplicationController
  def index
    render json: { test: "test" }
  end

  def preview
    memories = Memory.all
    render json: memories
  end
end
