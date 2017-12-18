class OrdersController < DashboardController
  before_action :ensure_cart_full, :assign_params, only: [:new, :create]
  before_action :preload_order_did_groups, only: [:new, :create, :show]

  def show
    preload_order_dids
    resource.items.sort_by!(&:did_group_id)
  end

  def new
    reload_user_balance
  end

  def create
    resource.items.each { |i| i.attributes.slice!(:sku_id, :qty) }
    if resource.save
      flash[:success] = 'Order was successfully created.'
      cookies[:cart] = {}.to_json
      redirect_to order_path(resource)
    else
      assign_params
      preload_order_did_groups
      render :new
    end
  end

  def destroy
    if resource.destroy
      flash[:success] = 'Order was successfully cancelled.'
      redirect_to orders_path
    else
      flash[:danger] = 'Failed to cancel Order: ' + resource.errors[:base].join('. ')
      redirect_back fallback_location: order_path(resource)
    end
  end

  private

  def initialize_api_config
    super.merge({
      resource_type: :orders,
      allowed_filters: %w(
        reference
        created_at_lteq
        created_at_gteq
      ) << {
        'status':    []
      }
    })
  end

  def default_sorting_column
    :created_at
  end

  def default_sorting_direction
    :desc
  end

  def preload_order_did_groups
    did_group_ids = resource.items.collect(&:did_group_id)
    did_groups = DIDWW::Resource::DidGroup.
                     where(id: did_group_ids.join(',')).
                     includes(:country, :stock_keeping_units, :did_group_type).
                     all
    resource.items.each do |item|
      item.attributes[:did_group] = did_groups.find { |dg| item.did_group_id == dg.id }
    end
  end

  def preload_order_dids
    order_dids = DIDWW::Resource::Did.where('order.id': resource.id).includes(:did_group).all
    resource.items.each do |item|
      item.attributes[:dids] = order_dids.select { |did| did.did_group.id == item.did_group_id }
    end
  end

  def ensure_cart_full
    if params[:order].blank? || items_params.blank?
      flash[:warning] = 'Your cart is empty. Please select some DID numbers below'
      redirect_to :coverage
    end
  end

  def assign_params
    resource.attributes = order_params
    assign_items
  end

  def assign_items
    resource.items = items_params.map do |details|
      DIDWW::ComplexObject::DidOrderItem.new(details)
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def resource_params
    params.require(:order).permit(:allow_back_ordering, items_attributes: [:did_group_id, :sku_id, :qty, :in])
  end

  def order_params
    attributes_for_save.slice(:allow_back_ordering)
  end

  def items_params
    items = attributes_for_save[:items_attributes] || []
    items = items.values if items.is_a? Hash
    items.map { |i| i[:in] ? i.except(:in) : nil }.compact
  end
end
