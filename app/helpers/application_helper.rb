# frozen_string_literal: true
module ApplicationHelper
  def api_mode_humanize(api_mode = session[:api_mode])
    case api_mode&.to_sym
    when :sandbox
      'Sandox'
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
end
