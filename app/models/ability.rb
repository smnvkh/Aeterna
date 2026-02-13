class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    # PROFILE

    can :manage, Profile, user: user
    can :read, Profile

    # MEMORY (посты семьи)

    # Пользователь может всё со всеми воспоминаниями своей семьи
    can :manage, Memory, family_id: user.family_id

    # И также читать их
    can :read, Memory, family_id: user.family_id


    # COMMENTS (комментарии)

    # Создание комментариев к memories своей семьи
    can :create, Comment do |comment|
      comment.commentable.is_a?(Memory) &&
        comment.commentable.family_id == user.family_id
    end

    # Обновление и удаление только своих комментариев
    can [ :update, :destroy ], Comment, user_id: user.id

    # Чтение комментариев внутри family memories
    can :read, Comment do |comment|
      comment.commentable.is_a?(Memory) &&
        comment.commentable.family_id == user.family_id
    end


    # FAMILY + FAMILY MEMBERS

    # Управлять членами своей семьи
    can :manage, FamilyMember, family_id: user.family_id

    # Управлять своей семьёй (например название семьи)
    can :manage, Family, id: user.family_id


    # ADMIN

    if user.admin?
      can :manage, :all
    end
  end
end
