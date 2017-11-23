require 'rails_helper'

RSpec.describe Initiatives::ImportsController, type: :controller do
  
  # let(:account) { create(:account) }
  # let(:user) { create(:user) }
  # let(:accounts_user) { create(:accounts_user, user: user, account: account ) }
  #
  # let(:valid_session) { { account_id: account.id } }
  #
  # before do
  #   allow(controller).to receive(:current_account) { account }
  #   sign_in user
  # end
  #
  # # This should return the minimal set of attributes required to create a valid
  # # Initiatives::Import. As you add validations to Initiatives::Import, be sure to
  # # adjust the attributes here as well.
  # let(:valid_attributes) { {} }
  #
  # let(:invalid_attributes) {
  #   skip("Add a hash of attributes invalid for your model")
  # }
  #
  # describe "GET #new" do
  #   it "assigns a new initiatives_import as @initiatives_import" do
  #     get :new#, session: valid_session
  #     expect(assigns(:initiatives_import)).to be_a_new(Initiatives::Import)
  #   end
  # end
  #
  # describe "GET #edit" do
  #   it "assigns the requested initiatives_import as @initiatives_import" do
  #     import = Initiatives::Import.create! valid_attributes
  #     get :edit, params: {id: import.to_param}#, session: valid_session
  #     expect(assigns(:initiatives_import)).to eq(import)
  #   end
  # end
  #
  # describe "POST #create" do
  #   context "with valid params" do
  #     it "creates a new Initiatives::Import" do
  #       expect {
  #         post :create, params: {initiatives_import: valid_attributes}#, session: valid_session
  #       }.to change(Initiatives::Import, :count).by(1)
  #     end
  #
  #     it "assigns a newly created initiatives_import as @initiatives_import" do
  #       post :create, params: {initiatives_import: valid_attributes}, session: valid_session
  #       expect(assigns(:initiatives_import)).to be_a(Initiatives::Import)
  #       expect(assigns(:initiatives_import)).to be_persisted
  #     end
  #
  #     it "redirects to the created initiatives_import" do
  #       post :create, params: {initiatives_import: valid_attributes}, session: valid_session
  #       expect(response).to redirect_to(Initiatives::Import.last)
  #     end
  #   end
  #
  #   context "with invalid params" do
  #     it "assigns a newly created but unsaved initiatives_import as @initiatives_import" do
  #       post :create, params: {initiatives_import: invalid_attributes}, session: valid_session
  #       expect(assigns(:initiatives_import)).to be_a_new(Initiatives::Import)
  #     end
  #
  #     it "re-renders the 'new' template" do
  #       post :create, params: {initiatives_import: invalid_attributes}, session: valid_session
  #       expect(response).to render_template("new")
  #     end
  #   end
  # end
  #
  # describe "PUT #update" do
  #   context "with valid params" do
  #     let(:new_attributes) {
  #       skip("Add a hash of attributes valid for your model")
  #     }
  #
  #     it "updates the requested initiatives_import" do
  #       import = Initiatives::Import.create! valid_attributes
  #       put :update, params: {id: import.to_param, initiatives_import: new_attributes}, session: valid_session
  #       import.reload
  #       skip("Add assertions for updated state")
  #     end
  #
  #     it "assigns the requested initiatives_import as @initiatives_import" do
  #       import = Initiatives::Import.create! valid_attributes
  #       put :update, params: {id: import.to_param, initiatives_import: valid_attributes}, session: valid_session
  #       expect(assigns(:initiatives_import)).to eq(import)
  #     end
  #
  #     it "redirects to the initiatives_import" do
  #       import = Initiatives::Import.create! valid_attributes
  #       put :update, params: {id: import.to_param, initiatives_import: valid_attributes}, session: valid_session
  #       expect(response).to redirect_to(import)
  #     end
  #   end
  #
  #   context "with invalid params" do
  #     it "assigns the initiatives_import as @initiatives_import" do
  #       import = Initiatives::Import.create! valid_attributes
  #       put :update, params: {id: import.to_param, initiatives_import: invalid_attributes}, session: valid_session
  #       expect(assigns(:initiatives_import)).to eq(import)
  #     end
  #
  #     it "re-renders the 'edit' template" do
  #       import = Initiatives::Import.create! valid_attributes
  #       put :update, params: {id: import.to_param, initiatives_import: invalid_attributes}, session: valid_session
  #       expect(response).to render_template("edit")
  #     end
  #   end
  # end

end
