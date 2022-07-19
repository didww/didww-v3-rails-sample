# frozen_string_literal: true
module ApplicationHelper
  def api_mode_humanize(api_mode = session[:api_mode])
    case api_mode&.to_sym
    when :sandbox
      'Sandbox'
    when :production
      'Live'
    end
  end

  def api_mode_css
    case session[:api_mode]&.to_sym
    when :sandbox
      'text-success'
    when :production
      'text-danger'
    end
  end

  def collapsible_panel(name, active: false, &blk)
    render 'shared/collapsible_panel', tab_name: name, active: active, &blk
  end

  def build_callback_url
    opaque = DataEncryptor.encrypt session[:api_key]
    callbacks_url(session_id: session.id, opaque: opaque)
  end

  def build_voice_out_callback_url
    opaque = DataEncryptor.encrypt session[:api_key]
    voice_out_callbacks_url(session_id: session.id, opaque: opaque)
  end

  def v3_api_base_url
    DIDWW::Client.api_base_url.chomp('/')
  end

  def boolean_badge_tag(flag, true_type: :success, false_type: :default)
    title = flag ? 'Yes' : 'No'
    type = flag ? true_type : false_type
    badge_tag(title: title, type: type)
  end

  def badge_tag(title: nil, type:)
    tag.span(class: "badge badge-#{type}") do
      block_given? ? yield : title
    end
  end
end
