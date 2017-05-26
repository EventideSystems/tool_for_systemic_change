require 'rails_helper'

RSpec.describe VideoTutorial, type: :model do
  
  it 'allows a user to be recreated after a delete' do
    user = User.create!(email: 'foo@bar.com', password: 'q2341234213', password_confirmation: 'q2341234213')
    user.delete
    
    expect{ User.create!(email: 'foo@bar.com', password: 'q2341234213', password_confirmation: 'q2341234213') }
      .to_not raise_exception
  end
end  