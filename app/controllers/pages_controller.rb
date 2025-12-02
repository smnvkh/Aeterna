class PagesController < ApplicationController
  def home
    @subscription = Subscription.new
  end

  def about
    @subscription = Subscription.new
  end
end
