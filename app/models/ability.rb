class Ability
  include CanCan::Ability

  def initialize(user)

     user ||= User.new # guest user (not logged in)

     if user.admin?
       can :manage, :all
     else
       can :read, Article
       can :create, Article if user.persisted?
       can :manage, Article, user_id: user.id
       can :read, Message, recipient_id: user.id
       can :create, Message, sender_id: user.id
       can :destroy, Message, recipient_id: user.id
     end

  end
end
