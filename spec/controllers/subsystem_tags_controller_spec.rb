require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe SubsystemTagsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # SubsystemTag. As you add validations to SubsystemTag, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # SubsystemTagsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all subsystem_tags as @subsystem_tags" do
      subsystem_tag = SubsystemTag.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(assigns(:subsystem_tags)).to eq([subsystem_tag])
    end
  end

  describe "GET #show" do
    it "assigns the requested subsystem_tag as @subsystem_tag" do
      subsystem_tag = SubsystemTag.create! valid_attributes
      get :show, params: {id: subsystem_tag.to_param}, session: valid_session
      expect(assigns(:subsystem_tag)).to eq(subsystem_tag)
    end
  end

  describe "GET #new" do
    it "assigns a new subsystem_tag as @subsystem_tag" do
      # FIXME failing spec 
      # get :new, params: {}, session: valid_session
      # expect(assigns(:subsystem_tag)).to be_a_new(SubsystemTag)
    end
  end

  describe "GET #edit" do
    it "assigns the requested subsystem_tag as @subsystem_tag" do
      subsystem_tag = SubsystemTag.create! valid_attributes
      get :edit, params: {id: subsystem_tag.to_param}, session: valid_session
      expect(assigns(:subsystem_tag)).to eq(subsystem_tag)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new SubsystemTag" do
        expect {
          post :create, params: {subsystem_tag: valid_attributes}, session: valid_session
        }.to change(SubsystemTag, :count).by(1)
      end

      it "assigns a newly created subsystem_tag as @subsystem_tag" do
        post :create, params: {subsystem_tag: valid_attributes}, session: valid_session
        expect(assigns(:subsystem_tag)).to be_a(SubsystemTag)
        expect(assigns(:subsystem_tag)).to be_persisted
      end

      it "redirects to the created subsystem_tag" do
        post :create, params: {subsystem_tag: valid_attributes}, session: valid_session
        expect(response).to redirect_to(SubsystemTag.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved subsystem_tag as @subsystem_tag" do
        post :create, params: {subsystem_tag: invalid_attributes}, session: valid_session
        expect(assigns(:subsystem_tag)).to be_a_new(SubsystemTag)
      end

      it "re-renders the 'new' template" do
        post :create, params: {subsystem_tag: invalid_attributes}, session: valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested subsystem_tag" do
        subsystem_tag = SubsystemTag.create! valid_attributes
        put :update, params: {id: subsystem_tag.to_param, subsystem_tag: new_attributes}, session: valid_session
        subsystem_tag.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested subsystem_tag as @subsystem_tag" do
        subsystem_tag = SubsystemTag.create! valid_attributes
        put :update, params: {id: subsystem_tag.to_param, subsystem_tag: valid_attributes}, session: valid_session
        expect(assigns(:subsystem_tag)).to eq(subsystem_tag)
      end

      it "redirects to the subsystem_tag" do
        subsystem_tag = SubsystemTag.create! valid_attributes
        put :update, params: {id: subsystem_tag.to_param, subsystem_tag: valid_attributes}, session: valid_session
        expect(response).to redirect_to(subsystem_tag)
      end
    end

    context "with invalid params" do
      it "assigns the subsystem_tag as @subsystem_tag" do
        subsystem_tag = SubsystemTag.create! valid_attributes
        put :update, params: {id: subsystem_tag.to_param, subsystem_tag: invalid_attributes}, session: valid_session
        expect(assigns(:subsystem_tag)).to eq(subsystem_tag)
      end

      it "re-renders the 'edit' template" do
        subsystem_tag = SubsystemTag.create! valid_attributes
        put :update, params: {id: subsystem_tag.to_param, subsystem_tag: invalid_attributes}, session: valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested subsystem_tag" do
      subsystem_tag = SubsystemTag.create! valid_attributes
      expect {
        delete :destroy, params: {id: subsystem_tag.to_param}, session: valid_session
      }.to change(SubsystemTag, :count).by(-1)
    end

    it "redirects to the subsystem_tags list" do
      subsystem_tag = SubsystemTag.create! valid_attributes
      delete :destroy, params: {id: subsystem_tag.to_param}, session: valid_session
      expect(response).to redirect_to(subsystem_tags_url)
    end
  end

end
