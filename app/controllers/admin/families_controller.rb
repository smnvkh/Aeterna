module Admin
  class FamiliesController < ApplicationController
    load_and_authorize_resource

    def index
      @families = Family.all
    end
  end
end
