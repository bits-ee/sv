require 'csv'

class ContestsController < ApplicationController

  class CSVExportException < RuntimeError;  end

  before_filter :secure_current_user, :only => :show
  force_ssl_with_params_fix :except => :show

  def show
    begin
      @contest = Contest.find(params[:id])
      if I18n.locale.to_s == 'en'
        @contest_name = @contest.name_en
      elsif I18n.locale.to_s == 'es'
        @contest_name = @contest.name_es
      else
        @contest_name = @contest.name
      end
    rescue
      redirect_to root_path and return
    end

    if params[:format] == 'csv'
      try_login_and_redirect_back and return unless current_user and current_user.is_priority? and request_with_ssl?
      csv = export_csv()
    elsif params[:format] == 'xls'
      try_login_and_redirect_back and return unless current_user and current_user.is_priority? and request_with_ssl?
      __filename = get_filename()
      xls = export_xls(__filename)
    else
      @projects = @contest.projects.public_scope.order(:created_at).all
      while ((@projects.length % 4 != 0) or @projects.length == 0) do
        @projects << Project.new(:name => t('project.your_project_name'), :synopsys => t('project.your_project_synopsys'))
      end
    end
    respond_to do |format|
      format.csv { send_data csv, :type=> 'text/csv', :disposition => 'attachment', :filename => (get_filename() + '.csv') }
      format.xls { send_data xls, :type=> :xls, :disposition => 'attachment', :filename => (__filename + '.xls') }
      format.html
    end
  rescue CSVExportException => e
    redirect_to :back, :flash => {:error => e.message}
  end

  private

  def export_xls(filename)
    data_header = Spreadsheet::Format.new(:weight => :bold, :border_color => :black, :bottom => true)
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => filename
    sheet1.row(0).default_format = data_header
    export(true).each_with_index do |value, index|
      sheet1.row(index).concat value
    end

    io = StringIO.new ''
    book.write io
    io.string

  end

  def export_csv()
    csv = CSV.generate('', {}) do |csv|
      export().each{|row| csv << row}
    end
    csv

  end

  def export(xls = false)
    result = []
    url_fields = [:url, :blog, :linkedin, :video_url]
    result << get_columns(xls)
    rooturl = root_url(:locale => nil)
    rooturl = rooturl[0, rooturl.length-1] if rooturl.last == '/'
    user_id = nil
    project_id = nil
    Project.where(:contest_id => @contest.id).order(:created_at).includes(:user).includes(:project_docs).each do |project|
      project_id = project.id
      row = []
      @project_columns.keys.each do |column|
        row << case column
          when :avatar
            avatar = project.avatar(:medium).to_s
            avatar == Project.default_avatar_filename ? nil : (xls ? Spreadsheet::Link.new(rooturl + avatar) : (rooturl + avatar))
          when :status
            t("project.status.#{project.status.downcase}")
          when :created_at
            l(project.created_at, :format => :short).gsub(',', '')
          else
            value_or_link(project, column, xls, url_fields.include?(column))
        end
      end
      user = project.user
      user_id = user.id
      @user_columns.keys.each do |column|
        row << case column
          when :avatar
            avatar = user.avatar(:medium).to_s
            avatar == user.default_url_by_user_type ? nil : (xls ? Spreadsheet::Link.new(rooturl + avatar) : (rooturl + avatar))
          when :status
            t("user.status.#{user.status.downcase}")
          when :last_login_date
            l(user.last_login_date, :format => :short).gsub(',', '')
          else
            value_or_link(user, column, xls, url_fields.include?(column))
        end
      end
      user_id = nil
      project.project_docs.each do |doc|
        doc_url = rooturl + doc.doc.url
        row << (xls ? Spreadsheet::Link.new(doc_url, doc.description.blank? ? doc.doc_file_name : doc.description) : doc_url)
        row << doc.description unless xls
      end
      result << row
      project_id = nil
    end
    result
  rescue
    unless user_id.blank?
      user = User.find(user_id)
      raise CSVExportException.new((t('contest.export_error.user') + "<a href='#{user_path(user.id)}'>#{user.fullname}</a>").html_safe)
    end
    unless project_id.blank?
      project = Project.find(project_id)
      raise CSVExportException.new((t('contest.export_error.project') + "<a href='#{project_path(project.id)}'>#{project.name}</a>").html_safe)
    end
    raise
  end

  def value_or_link(obj, column, xls, is_url)
    if xls
      if is_url
        obj.send(column).blank? ? '' : Spreadsheet::Link.new(obj.send(column))
      else
        obj.send(column)
      end
    else
      value = obj.send(column)
      value.is_a?(String) ? value.gsub( /\n|\r/, ' ') : value
    end
  end

  def get_filename
    "#{@contest.name} #{l(Time.now, :format => :short).gsub(',', '')}"
  end

  def get_columns(xls = false)
    @project_columns = t('activerecord.attributes.project').delete_if{ |k, v| [:remove_avatar, :avatar_file_size].include? k }
    @user_columns = t('activerecord.attributes.user').delete_if{ |k, v| k.match /^(.*password.*|.+avatar|avatar.+|full.*name|user_type|role|group|receive_notifications|is_admin|group_order_number)$/}
    columns_human_names = @project_columns.values + @user_columns.values
    3.times do |doc_index|
      columns_human_names << Project.human_attribute_name('project_docs.doc') + (doc_index + 1).to_s
      (columns_human_names << Project.human_attribute_name('project_docs.description') + (doc_index + 1).to_s) unless xls
    end
    columns_human_names
  end

end