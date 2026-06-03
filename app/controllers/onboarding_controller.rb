class OnboardingController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_if_complete, only: [ :profile_info, :avatar ]

  # Шаг 2: имя, дата рождения
  def profile_info
  end

  def save_profile_info
    name     = params[:name].to_s.strip
    birthday = params[:birthday].presence

    if name.blank?
      flash[:alert] = "Пожалуйста, введите ваше имя"
      return redirect_to onboarding_profile_info_path
    end

    # Если отмечен чекбокс «есть код семьи» — присоединиться к существующей
    if params[:has_family_code] == "1"
      code   = params[:family_code].to_s.strip.upcase
      family = Family.find_by(invite_code: code)
      if family.nil?
        flash[:alert] = "Семья с таким кодом не найдена"
        return redirect_to onboarding_profile_info_path
      end
      current_user.update!(family: family)
    end

    profile = current_user.profile || current_user.build_profile
    profile.name     = name
    profile.birthday = birthday

    if profile.save
      redirect_to onboarding_avatar_path
    else
      flash[:alert] = profile.errors.full_messages.to_sentence
      redirect_to onboarding_profile_info_path
    end
  end

  # Шаг 3: фото профиля
  def avatar
  end

  def save_avatar
    profile = current_user.profile
    if params[:avatar].present? && profile
      profile.avatar.attach(params[:avatar])
    end
    redirect_to onboarding_welcome_path
  end

  # Шаг 4: добро пожаловать
  def welcome
  end

  private

  def redirect_if_complete
    if current_user.profile&.name.present? && action_name == "profile_info"
      redirect_to onboarding_avatar_path
    end
  end
end
