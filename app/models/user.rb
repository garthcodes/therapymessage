class User < ActiveRecord::Base
  
  TYPES = %w(Client Provider)

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  def self.find_receiver(id)
    User.where(id: id).pluck(:email).first
  end

  def selfcompose_user(id)
    binding.pry
    where(email: id).first.id
  end
end
