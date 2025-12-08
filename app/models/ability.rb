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

    # Пользователь создаёт комментарии к memories своей семьи
    can :create, Comment, memory: { family_id: user.family_id }

    # Пользователь может удалить свой комментарий
    can :destroy, Comment, user_id: user.id

    # Все члены семьи могут читать комментарии внутри своих memories
    can :read, Comment, memory: { family_id: user.family_id }


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
