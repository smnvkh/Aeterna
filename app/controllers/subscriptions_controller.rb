class SubscriptionsController < ApplicationController
  def create
    @subscription = Subscription.new(subscription_params)

    respond_to do |format|
      if @subscription.save
        # format.html { redirect_to root_url, notice: "Subscription was successfully created." }
        format.turbo_stream { render :show }
      else
        format.html { redirect_to root_url, alert: "Some error" }
      end
    end
  end

  private
    # Only allow a list of trusted parameters through.
    def subscription_params
      params.expect(subscription: [ :email ])
    end
end
