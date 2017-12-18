module TrunksHelper
  def trunk_group_link(trunk = resource)
    if (tg = trunk.trunk_group)
      link_to(tg.name, trunk_group_path(tg))
    end
  end
end
