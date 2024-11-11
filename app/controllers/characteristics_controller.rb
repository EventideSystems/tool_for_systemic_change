# frozen_string_literal: true

class CharacteristicsController < ApplicationController
  include VerifyPolicies

  before_action :set_characteristic, only: %i[show edit update destroy description]
  before_action :set_focus_areas, only: %i[new edit]

  def index
    @characteristics = \
      policy_scope(Characteristic)
      .joins(focus_area: { focus_area_group: :account })
      .where(focus_area_groups: { accounts: { id: current_account.id } })
      .order(sort_order)
      .page(params[:page])
  end

  def show; end

  def new
    @characteristic = Characteristic.new(description: DESCRIPTION_TEMPLATE)
    authorize @characteristic
  end

  def edit
    @characteristic.description = DESCRIPTION_TEMPLATE if @characteristic.description.blank?
  end

  def create
    @characteristic = Characteristic.new(characteristic_params)
    authorize @characteristic

    if @characteristic.save
      redirect_to characteristics_path, notice: 'Characteristic was successfully created.'
    else
      render :new
    end
  end

  def update
    if @characteristic.update(characteristic_params)
      redirect_to characteristics_path, notice: 'Characteristic was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @characteristic.delete

    redirect_to characteristics_url, notice: 'Characteristic was successfully deleted.'
  end

  def description
    render layout: false
  end

  def content_subtitle
    @characteristic&.name.presence || super
  end

  private

  DESCRIPTION_TEMPLATE = <<~HTML
    <h1>Initiative Characteristics</h1>
    <br/>
    <em>Details go here...</em>
    <br/>
    <h1>Why it is important</h1>
    <br/>
    <em>Details go here...</em>
    <br/>
    <h1>Examples</h1>
    <br/>
    <em>Details go here...</em>
  HTML

  private_constant :DESCRIPTION_TEMPLATE

  def set_characteristic
    @characteristic = Characteristic.find(params[:id])
    authorize @characteristic
  end

  def set_focus_areas
    @focus_areas = FocusArea.where(focus_area_group: current_account.focus_area_groups).order(:scorecard_type,
                                                                                              :position)
  end

  def characteristic_params
    params.fetch(:characteristic, {}).permit(:name, :description, :focus_area_id, :position, :video_tutorial_id)
  end
end
