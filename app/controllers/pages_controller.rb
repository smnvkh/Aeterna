class PagesController < ApplicationController
  def home
    @subscription = Subscription.new
  end

  def about
  end
end
