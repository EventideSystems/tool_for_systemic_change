require "prawn"
require "prawn/table"

module Prawn::ScorecardHelpers
  
  include ActionView::Helpers::TextHelper
  
  def focus_area_color(focus_area)
    ['FF0000', 'F7C80B', 'FF6D24', '7993F2', '2E74BA', '009BCC', '008C8C', '00CCAA', '1CB85D'][focus_area.position-1]
  end
  
  def page_header(scorecard)
    img = File.join(Rails.root, 'app/assets/images/logo-long-white-bg.png')
    
    repeat(:all) do
      canvas do 
        bounding_box [bounds.left + 30, bounds.top - 20], width: bounds.width - 60 do
          font_size 22
          pad_top(8) { text "Transition Card: #{truncate(scorecard.name, length: 40)}", :valign => :top }
          image img, :position => :right, :width => 130, :vposition => :top
        end
      end
    end
  end
  
  def header(focus_areas)
    [{ content: '', border_width: 0 }] + focus_areas.map.with_index do |focus_area, index|
      { content: "Focus Area #{index+1}", 
        colspan: focus_area.characteristics.count,
        text_color: focus_area_color(focus_area),
        align: :center,
        border_width: 0 
      }
    end
  end
  
  def spacer(focus_areas)
    [{ content: '', border_width: 0 }] + focus_areas.map.with_index do |focus_area, index|
      { content: "", 
        colspan: focus_area.characteristics.count,
        borders: [:top, :left, :right],
        border_lines: [:dotted],
        border_color: focus_area_color(focus_area),
        border_width: 1 
      }
    end
  end
  
  def legend_keys(focus_areas)
      [{ content: '', border_width: 0 }] + focus_areas.inject([]) do |memo, focus_area|
    
      focus_area.characteristics.inject(memo) do |memo, characteristic|
        memo.push({ 
          content: characteristic.identifier, 
          text_color: focus_area_color(focus_area),
          border_width: 0,
          align: :center,
        })
        memo
      end
    
      memo
    end
  end
  
  def legend(focus_areas)
    move_down 30
    focus_areas.each_with_index do |focus_area, focus_area_index|
      move_down 5
      formatted_text [
        { text: "Focus Area #{focus_area.position}", styles: [:bold], color: focus_area_color(focus_area) },
        { text: " - #{focus_area.name.force_encoding("UTF-8")}", size: 10 }
      ], leading: 6
      focus_area.characteristics.each_with_index do |characteristic, characteristic_index|
        formatted_text [ 
          { text: characteristic.identifier, color: focus_area_color(focus_area) }, 
          { text: " - #{characteristic.name.force_encoding("UTF-8")}" }
        ], indent_paragraphs: 10, size: 8, leading: 4
      end
    end
  end
  
  def data(initiatives, focus_areas)
    initiatives.map do |initiative|
      [{ content: truncate(initiative.name, length: 35), text_color: '3C8DBC', border_width: 0, width: 200 }] + initiative.checklist_items_ordered_by_ordered_focus_area(focus_areas: focus_areas).map do |checklist_item|
        { content: " ", border_width: 2, border_color: 'FFFFFF' }.tap do |cell|
          cell[:background_color] = checklist_item.checked? ? focus_area_color(checklist_item.focus_area) : 'F8F8F8'
        end
      end
    end
  end
  
  def page_numbering
    font_size 12
    string = "Page <page> of <total>"
    options = { 
      :at => [bounds.right - 150, 0],
      :width => 150,
      :align => :right,
      :start_count_at => 1
    }
    number_pages string, options
  end
  
  def formatted_date(date)
    if date.present?
      { text: date.strftime('%B %-d, %Y') }
    else
      { text: 'No data', styles: [:italic] }
    end
  end
  
  def formatted_description(description)
    if description.present?
      { text: description }
    else
      { text: 'No description', styles: [:italic] }
    end
  end
end

::Prawn::Document.extensions << Prawn::ScorecardHelpers

class ScorecardsController < ApplicationController
  before_action :set_scorecard, only: [:show, :edit, :update, :destroy, :show_shared_link, :copy, :copy_options, :merge, :merge_options] 
  before_action :set_active_tab, only: [:show] 
  before_action :require_account_selected, only: [:new, :create, :edit, :update, :show_shared_link] 

  add_breadcrumb Scorecard.model_name.human.pluralize, :scorecards_path
  
  def index
    @scorecards = policy_scope(Scorecard).order(sort_order).page params[:page]
  end

  def show
    @selected_date = params[:selected_date]
    @parsed_selected_date = @selected_date.blank? ? nil : Date.parse(@selected_date)
    
    @selected_tags = params[:selected_tags].blank? ? [] : SubsystemTag.where(account: current_account, name: params[:selected_tags])
    
    @focus_areas = FocusArea.ordered_by_group_position
    
    @initiatives = if @parsed_selected_date.present? 
      @scorecard.initiatives
        .where('started_at <= ? OR started_at IS NULL', @parsed_selected_date)
        .where('finished_at >= ? OR finished_at IS NULL', @parsed_selected_date)
        .order(name: :asc)
    else  
      @scorecard.initiatives.order(name: :asc)
    end
    
    @initiatives = if @selected_tags.present?
      tag_ids = @selected_tags.map(&:id)
      @initiatives
        .distinct
        .joins(:initiatives_subsystem_tags)
        .where('initiatives_subsystem_tags.subsystem_tag_id' => tag_ids)
        .select('initiatives.*, lower(initiatives.name)')
    else 
      @initiatives
    end
      
    add_breadcrumb @scorecard.name
    
    respond_to do |format|
      format.html 
      format.pdf do
        
        scorecard = @scorecard
        initiatives = @initiatives
        focus_areas = @focus_areas
        
        colors = ['FF0000', 'F7C80B', 'FF6D24', '7993F2', '2E74BA', '009BCC', '008C8C', '00CCAA', '1CB85D']
        
        
        pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape, :top_margin => 60) do

          page_header(scorecard)
          
          # Data
          font_size 10

          initiatives.each_slice(18) do |grouped_initiatives|
            [focus_areas[0..3], focus_areas[4..8]].each do |grouped_focus_areas|   
              table(
                [
                  header(grouped_focus_areas), 
                  spacer(grouped_focus_areas)
                ] +
                  data(grouped_initiatives, grouped_focus_areas) + 
                  [legend_keys(grouped_focus_areas)]
              )
              
              if initiatives.count > 7
                start_new_page
              else
                move_down 50
              end
            end
          end
          
          
          start_new_page if initiatives.count <= 7
          
          # Legend
          
          text "Legend", size: 16

          stroke do
            stroke_color 'F8F8F8'
            stroke_horizontal_rule
            move_down 15
          end

          define_grid(:columns => 2, :rows => 1)

          grid(0, 0).bounding_box do
            legend(focus_areas[0..3])
          end
          
          grid(0, 1).bounding_box do
            legend(focus_areas[4..8])
          end
          
          start_new_page
          
          # Initiatives
          
          text "Initiatives", size: 16
          
          stroke do
            stroke_color 'F8F8F8'
            stroke_horizontal_rule
            move_down 15
          end

          column_box([0, cursor], columns: 2, width: bounds.width, reflow_margins: true) do
            initiatives.each do |initiative|
              
              text "Name: #{initiative.name}", size: 12
              formatted_text [ { text: 'Started At: ' }, formatted_date(initiative.started_at) ]
              formatted_text [ { text: 'Finished At: ' }, formatted_date(initiative.finished_at) ]
              formatted_text [ { text: 'Description: '}, formatted_description(initiative.description) ]
              
            
              if initiative.subsystem_tags.any?
                text "Subsystems:", size: 10
                initiative.subsystem_tags.each do |subsystem|
                  text "\t\u2022 #{subsystem.name}", indent_paragraphs: 10
                end
              end
              move_down 20
            end
          end
            
         
          page_numbering
        end
  
        send_data pdf.render,
          filename: "transition_card",
          type: 'application/pdf',
          disposition: 'inline'
          
        # render pdf: "scorecard",
        #   layout: 'pdf.html.erb',
        #   orientation: 'Landscape',
        #   viewport_size: '1280x1024',
        #   print_media_type: false,
        #   grayscale: false,
        #   background: true,
        #   show_as_html: params.key?('debug'),
        #   footer: { right: 'Page [page] of [topage]' }
      end 
    end
  end

  def new
    @scorecard = current_account.scorecards.build
    authorize @scorecard
    @scorecard.initiatives.build
   # @scorecard.initiatives.first.initiatives_organisations.build
    add_breadcrumb "New"
  end

  def edit
    add_breadcrumb @scorecard.name
  end

  def create
    @scorecard = current_account.scorecards.build(scorecard_params)
    authorize @scorecard

    respond_to do |format|
      if @scorecard.save
        format.html { redirect_to scorecard_path(@scorecard), notice: "#{Scorecard.model_name.human} was successfully created." }
        format.json { render :show, status: :created, location: @scorecard }
      else
        format.html { render :new }
        format.json { render json: @scorecard.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @scorecard.update(scorecard_params)
        format.html { redirect_to @scorecard, notice: "#{Scorecard.model_name.human} was successfully updated." }
        format.json { render :show, status: :ok, location: @scorecard }
      else
        format.html { render :edit }
        format.json { render json: @scorecard.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @scorecard.destroy
    respond_to do |format|
      format.html { redirect_to scorecards_url, notice: "#{Scorecard.model_name.human} was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  
  def shared
  end
  
  def show_shared_link
    render layout: false
  end

  def copy_options
    render layout: false
  end
  
  def copy
    new_name = params.dig(:new_name) 
    deep_copy = params.dig(:copy) == 'deep' 

    @copied_scorecard = ScorecardCopier.new(@scorecard, new_name, deep_copy: deep_copy).perform
    respond_to do |format|
      if @copied_scorecard.present?
        format.html { redirect_to scorecard_path(@copied_scorecard), notice: "#{Scorecard.model_name.human} was successfully copied." }
        format.json { render :show, status: :ok, location: @copied_scorecard }
      else
        format.html { render :edit }
        format.json { render json: @copied_scorecard.errors, status: :unprocessable_entity }
      end
    end 
  end
  
  def merge_options
    @other_scorecards = current_account.scorecards.where.not(id: @scorecard.id).order('lower(name)')
    render layout: false
  end
  
  def merge
    @other_scorecard = current_account.scorecards.find(params[:other_scorecard_id])
    @merged_scorecard = @scorecard.merge(@other_scorecard)
    respond_to do |format|
      if @scorecard.present?
        format.html { redirect_to scorecard_path(@merged_scorecard), notice: "#{Scorecard.model_name.human} were successfully merged." }
        format.json { render :show, status: :ok, location: @merged_scorecard }
      else
        format.html { render :edit }
        format.json { render json: @merged_scorecard.errors, status: :unprocessable_entity }
      end
    end 
  end
  
  def content_title
    Scorecard.model_name.human.pluralize
  end
  
  def content_subtitle
    return @scorecard.name if @scorecard.present?
    super
  end

  private

    def set_scorecard
      @scorecard = current_account.scorecards.find(params[:id])
      authorize @scorecard
    end
    
    def set_active_tab
      @active_tab = params.dig(:active_tab)&.to_sym || :scorecard
    end

    def scorecard_params
      params.require(:scorecard).permit(
        :name, 
        :description, 
        :wicked_problem_id,
        :community_id,
        initiatives_attributes: [
          :_destroy,
          :name,
          :description,
          :scorecard_id,
          :started_at,
          :finished_at,
          :dates_confirmed,
          :contact_name,
          :contact_email,
          :contact_phone,
          :contact_website,
          :contact_position,
          initiatives_organisations_attributes: [
            :_destroy,
            :organisation_id
          ],
          initiatives_subsystem_tags_attributes: [
            :_destroy,
            :subsystem_tag_id
          ]
        ]
      )
    end
end