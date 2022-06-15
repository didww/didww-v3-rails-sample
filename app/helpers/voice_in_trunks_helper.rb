# frozen_string_literal: true
module VoiceInTrunksHelper
  def trunk_group_link(trunk = resource)
    if (tg = trunk.voice_in_trunk_group)
      link_to(tg.name, voice_in_trunk_group_path(tg))
    end
  end
end
