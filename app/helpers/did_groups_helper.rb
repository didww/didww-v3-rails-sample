# frozen_string_literal: true
module DidGroupsHelper
  def did_group_full_prefix(did_group)
    [did_group.country&.prefix, did_group.prefix].compact.join('-')
  end

  def did_group_checkout_button(dg)
    link_to 'Order', new_order_path(did_group_id: dg.id)
  end
end
