module ApplicationHelper

  def flash_message
    return if flash.empty?
    output = ''
    # :error, :warning, :notice
    flash.each do |type, errors| #key, value
      if errors.respond_to? :each
        errors.each do |key, message| #key, value
          output += content_tag(:div, [message].flatten.join, :class => type)
        end
      else
        output += content_tag(:div, errors, :class => type)
      end
    end
    output.html_safe
  end

  def title(page_title)
    set_title(page_title)
  end

  def set_title(page_title)
    @page_title = page_title
  end

  def get_title
    #"#{@page_title || t('common.default_page_title')} - #{t('support.name')}"
    @page_title.present? ? "#{@page_title} - #{t('support.name')}" : t('support.name')
  end

  def get_title_raw
    @page_title
  end

  def project_status_color status
    case status
      when Project.status_added
        'yellow'
      when Project.status_disabled
        'red'
      when Project.status_published
        'green'
      when Project.status_selected
        'green'
      when Project.status_short_listed
        'green'
      when Project.status_rejected
        'red'
      when Project.status_resubmitted
        'yellow'
      else
        ''
    end
  end

  def user_status_color status
    case status
      when User.status_invited
        'yellow'
      when User.status_disabled
        'red'
      when User.status_active
        'green'
      else
        ''
    end
  end
  
  def social_icons(user)
    __out = []
    __out << link_to(image_tag('icons/twitter.png', :title => "@#{user.twitter}"), "#{t('support.twitter_baseurl')+user.twitter}", :rel => 'nofollow') if user.twitter and user.twitter.strip.present?
    __out << link_to(image_tag('icons/linkedin.png', :title => "LinkedIn"), user.linkedin, :rel => 'nofollow') if user.linkedin and user.linkedin.strip.present?
    __out << link_to(image_tag('icons/blog.png', :title => User.human_attribute_name(:blog)), user.blog, :rel => 'nofollow') if user.blog and user.blog.strip.present?
    __out << link_to(image_tag("icons/#{user.authentication.provider}.png", :title => t('user.third_party_login_providers.' + user.authentication.provider)), user.authentication.profile_url, :rel => 'nofollow') if user.authentication.present?
    __out.join(' ').html_safe
  end
	
	def document_icon(ct)	  
	  icon = ''
	  case 
      when ct =~ /pdf/
        icon = 'icons/document-pdf.png'
      when ct =~ /image/
        icon = 'icons/document-image.png'
      when ct =~ /html/
        icon = 'icons/document-code.png'
      when (ct =~ /plain/ or ct =~ /rtf/ )
        icon = 'icons/document-text.png'
      when (ct =~ /excel/ or ct =~ /spreadsheet/ )
        icon = 'icons/document-excel.png'
      when (ct =~ /powerpoint/ or ct =~ /presentation/ )
        icon = 'icons/document-powerpoint.png'
      when ct =~ /zip/
        icon = 'icons/document-zipper.png'
      when (ct =~ /word/ or ct =~ /opendocument.text/)
        icon = 'icons/document-word.png'
      when ct =~ /postscript/
        icon = 'icons/document-photoshop.png'
      else
        icon = 'icons/document.png'
	  end
	  
    image_tag icon, :size => '16x16'
  end
  
  def embed_video(video_url, width, height)
    extracted_video_url = nil
    begin
      if video_url =~ /youtube.com|youtu.be/i
        extracted_video_url = /(be\/|v=)(.*?)(&|$)/i.match(video_url)[2] 
        #http://www.youtube.com/watch?v=###########&feature=related
        #http://youtu.be/###########
        return "<iframe width='#{width}' height='#{height}' src='https://www.youtube.com/embed/#{extracted_video_url}' frameborder='0' allowfullscreen></iframe>".html_safe 
      elsif video_url =~ /vimeo.com/
        extracted_video_url = /\/([^\/]*?)(\?|$)/i.match(video_url)[1]
        #http://player.vimeo.com/video/###########
        #http://vimeo.com/###########
        return "<iframe width='#{width}' height='#{height}' src='https://player.vimeo.com/video/#{extracted_video_url}' frameborder='0'></iframe>".html_safe  
      else
        return link_to(video_url)
      end
    rescue 
      return false
    end
  end
  
  def format_and_link(text)
    Rinku.auto_link(simple_format(text))
  end


end
