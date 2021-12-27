# frozen_string_literal: true
class ExportsController < DashboardController
  before_action :assign_params, only: [:create]

  def new
    resource.export_type = export_type
  end

  def create
    if resource.save
      flash[:success] = 'CDR Export was successfully created.'
      redirect_to export_path(resource)
    else
      render :new
    end
  end

  def show
    respond_to do |format|
      format.html
      format.csv do
        io = resource.csv
        filename = [
              'CDR',
              resource.year,
              resource.month.to_s.rjust(2, '0'),
              resource.filters.did_number,
              resource.url.split('/').last
            ].compact.join('-')
        response.headers['X-Accel-Buffering']   = 'no'
        response.headers['Cache-Control']       = 'no-cache'
        response.headers['Content-Type']        = 'text/csv; charset=utf-8'
        response.headers['Content-Disposition'] = %(attachment; filename="#{filename}")
        response.headers['Content-Length']      = io.size
        self.response_body = io.each_chunk
      end
    end
  end

  private

  def initialize_api_config
    super.merge({
      resource_type: :exports,
      decorator_class: ExportDecorator,
    })
  end

  def default_sorting_column
    :created_at
  end

  def default_sorting_direction
    :desc
  end

  def export_type
    params[:export_type]
  end

  def assign_params
    export_params = attributes_for_save.except(:period, :voice_out_trunk_id, :day, :did_number, :year, :month)
    filters = send("#{export_type}_export_filters")
    resource.attributes = export_params
    resource.export_type = export_type
    resource.filters = DIDWW::ComplexObject::ExportFilters.new(filters)
  end

  def cdr_out_export_filters
    year, month = resource_params[:period].to_s.split('/')
    filters = { year: year, month: month }
    filters[:voice_out_trunk_id] = resource_params[:voice_out_trunk_id] unless resource_params[:voice_out_trunk_id].blank?
    filters[:day] = resource_params[:day] unless resource_params[:day].blank?

    filters
  end

  def cdr_in_export_filters
    year, month = resource_params[:period].to_s.split('/')
    filters = { year: year, month: month }
    filters[:did_number] = resource_params[:did_number] unless resource_params[:did_number].blank?
    filters
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def resource_params
    params.require(:export).permit(
      :period,
      :did_number,
      :callback_method,
      :callback_url,
      :export_type,
      :voice_out_trunk_id,
      :day
    )
  end
end
