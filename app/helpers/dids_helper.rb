module DidsHelper
  def did_status(did)
    status = []
    status << 'Awaiting registration' if did.awaiting_registration
    status << 'Blocked' if did.blocked
    status << 'Terminated' if did.terminated
    status << 'Pending removal' if did.billing_cycles_count == 1
    status.join(', ')
  end

  def area_name(did)
    [did.did_group.country&.name, did.did_group.area_name].compact.join(', ')
  end
end
