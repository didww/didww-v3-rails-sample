module DidGroupsHelper
  def did_group_full_prefix(dg)
    [dg.country&.prefix, dg.prefix + dg.local_prefix].compact.join('-')
  end

  def did_group_checkout_button(dg)
    link_to 'Order', new_order_path(did_group_id: dg.id)
  end
end
