class Api::V1::SubscriptionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    @subscription = Subscription.new(subscription_params)

    if @subscription.save
      render json: { success_text: "Вы подписаны, мы оповестим вас о запуске" }, status: :created
    else
      render json: @subscription.errors, status: :unprocessable_entity
    end
  end

  private
    # Only allow a list of trusted parameters through.
    def subscription_params
      params.expect(subscription: [ :email ])
    end
end
