class Ability
  include CanCan::Ability

    def initialize(user)
    return unless user.present?

    # Разрешаем пользователю управлять своими постами
    can :manage, Memory, user: user

    # Разрешаем членам одной семьи читать и редактировать посты друг друга
    can :manage, Memory, user: { family_id: user.family_id }

    # Разрешаем читать только посты членов его семьи
    can :read, Memory, user: { family_id: user.family_id }

    # Разрешаем управлять комментариями, если они принадлежат текущему пользователю
    can :manage, Comment, user: user
    can :read, Comment, memory: { user_id: user.id }

    # Пользователь может редактировать информацию о членах своей семьи
    can :manage, FamilyMember, family_id: user.family_id
    can :manage, Family, id: user.family_id

    return unless user.admin?
    can :manage, :all
    end
end
