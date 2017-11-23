require 'rails_helper'

RSpec.describe ScorecardsController, type: :controller do
  
  # describe "GET show" do
  #
  #   @user = FactoryGirl.create(:admin_user)
  #   login_user(@user)
  #
  #   let!(:account) { create(:account) }
  #   let(:scorecard) { create(:scorecard, account: account) }
  #   let!(:initiative_1) { create(:initiative, scorecard: scorecard) }
  #   let!(:initiative_2) { create(:initiative, scorecard: scorecard, started_at: '2017-06-01') }
  #   let!(:initiative_3) { create(:initiative, scorecard: scorecard, started_at: '2017-06-01', finished_at: '2017-06-30') }
  #   let!(:initiative_4) { create(:initiative, scorecard: scorecard,                           finished_at: '2017-06-30') }
  #   let!(:initiative_5) { create(:initiative, scorecard: scorecard, started_at: '2017-07-01', finished_at: '2017-07-30') }
  #   let!(:initiative_6) { create(:initiative, scorecard: scorecard, started_at: '2017-07-01'                           ) }
  #   let!(:initiative_7) { create(:initiative, scorecard: scorecard, started_at: '2017-07-01')                            }
  #   let!(:initiative_8) { create(:initiative, scorecard: scorecard,                           finished_at: '2017-05-30') }
  #
  #   before do
  #     allow(subject).to receive(:current_account).and_return(account)
  #   end
  #
  #   context 'initiatives' do
  #     context 'without params' do
  #       it 'retrieves all initiatives' do
  #         get :show, params: { id: scorecard.id }
  #         expect(assigns(:initiatives))
  #           .to include(
  #             initiative_1, initiative_2, initiative_3, initiative_4,
  #             initiative_5, initiative_6, initiative_7, initiative_8
  #           )
  #       end
  #     end
  #
  #     context 'with :selected_date param' do
  #       before { get :show, params: { id: scorecard.id, selected_date: '2017-06-02' }}
  #
  #       it 'retrieves initiatives with no :started_at or :finished_at' do
  #         expect(assigns(:initiatives)).to include(initiative_1)
  #       end
  #
  #       it 'retrieves initiatives with :started_at before selected date, with no :finished_at' do
  #         expect(assigns(:initiatives)).to include(initiative_2)
  #       end
  #
  #       it 'retrieves initiatives with :started_at before selected date, and :finished_at after selected date' do
  #         expect(assigns(:initiatives)).to include(initiative_3)
  #       end
  #
  #       it 'retrieves initiatives with no :started_at, and :finished_at after selected date' do
  #         expect(assigns(:initiatives)).to include(initiative_4)
  #       end
  #
  #       it 'does not retreive initiatives with :started_at after selected date' do
  #         expect(assigns(:initiatives)).to_not include(initiative_5)
  #         expect(assigns(:initiatives)).to_not include(initiative_6)
  #         expect(assigns(:initiatives)).to_not include(initiative_7)
  #       end
  #
  #       it 'does not retreive initiatives with :finished_at before selected date' do
  #         expect(assigns(:initiatives)).to_not include(initiative_8)
  #       end
  #     end
  #   end
  # end
  
end