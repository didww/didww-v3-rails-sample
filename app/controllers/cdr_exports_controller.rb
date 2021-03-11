class CdrExportsController < DashboardController
  before_action :assign_params, only: [:create]

  def create
    if resource.save
      flash[:success] = 'CDR Export was successfully created.'
      redirect_to cdr_export_path(resource)
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
              resource.did_number,
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
      resource_type: :cdr_exports
    })
  end

  def default_sorting_column
    :created_at
  end

  def default_sorting_direction
    :desc
  end

  def assign_params
    resource.attributes = cdr_export_params
    resource.year, resource.month = resource_params[:period].to_s.split('/')
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def resource_params
    params.require(:cdr_export).permit(
      :period,
      :did_number,
      :callback_method,
      :callback_url
    )
  end

  def cdr_export_params
    attributes_for_save.except(:period, :callback_method, :callback_url)
  end
end
