class CharacteristicsController < ApplicationController
  before_action :set_characteristic, only: [:show, :edit, :update, :destroy, :description]

  def index
    @characteristics = \
      policy_scope(Characteristic)
        .joins(focus_area: { focus_area_group: :account })
        .where(focus_area_groups: { accounts: { id: current_account.id } })
        .order(sort_order)
        .page(params[:page])
  end

  def show
  end

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
    @characteristic.destroy

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

  def characteristic_params
    params.fetch(:characteristic, {}).permit(:name, :description, :focus_area_id, :position, :video_tutorial_id)
  end
end
