module System
  class StakeholderTypesController < ApplicationController
    include VerifyPolicies

    before_action :set_stakeholder_type, only: [:show, :edit, :update, :destroy]

    skip_after_action :verify_policy_scoped, only: [:index]

    # add_breadcrumb "System"
    # add_breadcrumb "Stakeholder Types", :stakeholder_types_path

    def index
      @stakeholder_types = \
        System::StakeholderTypePolicy::Scope.new(pundit_user, StakeholderType)
          .resolve
          .order(sort_order)
          .page params[:page]

      render 'stakeholder_types/index'
    end

    def show
      @content_subtitle = @stakeholder_type.name
      # add_breadcrumb @stakeholder_type.name

      render 'stakeholder_types/show'
    end

    def new
      @stakeholder_type = StakeholderType.new
      authorize @stakeholder_type, policy_class: System::StakeholderTypePolicy
      # add_breadcrumb "New"

      render 'stakeholder_types/new'
    end

    def edit
      # add_breadcrumb @stakeholder_type.name

      render 'stakeholder_types/edit'
    end

    def create
      @stakeholder_type = StakeholderType.new(stakeholder_type_params)
      authorize @stakeholder_type, policy_class: System::StakeholderTypePolicy

      if @stakeholder_type.save
        redirect_to system_stakeholder_types_path, notice: 'Stakeholder Type was successfully created.'
      else
        render :new
      end
    end

    def update

      if @stakeholder_type.update(stakeholder_type_params)
        redirect_to system_stakeholder_types_path, notice: 'Stakeholder Type was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @stakeholder_type.destroy
      redirect_to system_stakeholder_types_path, notice: 'StakeholderType was successfully deleted.'
    end

    def content_subtitle
      @stakeholder_type&.name.presence || super
    end

    private

    def set_stakeholder_type
      @stakeholder_type = StakeholderType.system_stakeholder_types.find(params[:id])
      authorize @stakeholder_type, policy_class: System::StakeholderTypePolicy
    end

    def stakeholder_type_params
      params.fetch(:stakeholder_type, {}).permit(:name, :description, :color)
    end
  end
end
