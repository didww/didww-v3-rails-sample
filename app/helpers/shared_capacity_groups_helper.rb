# frozen_string_literal: true
module SharedCapacityGroupsHelper
  def capacity_pool_link(shared_capacity_group = resource)
    if (cp = shared_capacity_group.capacity_pool)
      link_to(cp.name, capacity_pool_path(cp))
    end
  end
end
