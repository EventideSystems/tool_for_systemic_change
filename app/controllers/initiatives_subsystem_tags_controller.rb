# frozen_string_literal: true

# NOTE: This is **not** a nested resource, but a separate controller that is used to create
# subsystem tags within the context of initiatives.
class InitiativesSubsystemTagsController < ApplicationController
  # Used to return to base state if cancel is clicked
  def index
    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('new_initiatives_subsystem_tag',
                                                  partial: '/initiatives_subsystem_tags/index')
      end
    end
  end

  def new # rubocop:disable Metrics/MethodLength
    @subsystem_tag = current_account.subsystem_tags.new(color: random_hex_color)
    authorize @subsystem_tag

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          'new_initiatives_subsystem_tag',
          partial: '/initiatives_subsystem_tags/form',
          locals: { subsystem_tag: @subsystem_tag }
        )
      end
    end
  end

  def create # rubocop:disable Metrics/MethodLength
    @subsystem_tag = current_account.subsystem_tags.new(subsystem_tag_params)
    authorize @subsystem_tag

    if @subsystem_tag.save
      respond_to do |format|
        format.html
        format.turbo_stream
      end
    else
      # render 'new'
      respond_to do |format|
        format.html
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            'new_initiatives_subsystem_tag',
            partial: '/initiatives/subsystem_tags/form',
            locals: { subsystem_tag: @subsystem_tag }
          )
        end
      end
    end
  end

  private

  def random_hex_color
    "##{SecureRandom.hex(3)}"
  end

  def subsystem_tag_params
    params.require(:subsystem_tag).permit(:name, :description, :color)
  end
end
