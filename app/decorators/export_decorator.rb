# frozen_string_literal: true
class ExportDecorator < ResourceDecorator
  def cdr_in?
    model.export_type == model.class::EXPORT_TYPE_CDR_IN
  end

  def cdr_out?
    model.export_type == model.class::EXPORT_TYPE_CDR_OUT
  end

  def voice_out_trunk
    @voice_out_trunk ||= DIDWW::Resource::VoiceOutTrunk.where(id: voice_out_trunk_id).first
  end

  def voice_out_trunk_link
    return if voice_out_trunk.nil?

    h.link_to voice_out_trunk.name, h.voice_out_trunk_path(voice_out_trunk)
  end

  private

  def voice_out_trunk_id
    model.filters[:'voice_out_trunk.id']
  end
end
