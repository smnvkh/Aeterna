class Api::V1::MemoriesController < ApplicationController
  # GET /memories or /memories.json
  def index
    @memories = Memory.all
  end

  # GET /memories/1 or /memories/1.json
  def show
    @memory = Memory.find(params[:id])
  end
end
