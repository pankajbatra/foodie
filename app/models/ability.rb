# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)

    if user.has_role? :restaurant
      can :manage, Restaurant, :id => Restaurant.where(:owner, user).pluck(:id)
    end
  end
end
