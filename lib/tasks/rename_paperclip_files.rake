namespace :paperclip do
  desc "rename attached files from :style.:extension to :basename.extension pattern"
  task :rename_style_to_basename => :environment do
    @rename = false
    def rename(old, new)
      if @rename
        puts 'ok' if File.rename(old, new) == 0
      else
        puts old
        puts new
        puts ''
      end
    end
    ProjectDoc.all.each do |pd|
      file_name = pd.doc_file_name
      old_file_path = 'public' + pd.doc.url(:original).gsub(/\d*$/, '').gsub('?', '')
      folder_path = old_file_path.gsub(/original(\.?.*)$/, '')
      new_file_path = folder_path + file_name
      rename(old_file_path, new_file_path)
    end

    User.where('avatar_file_name is not null').each do |pd|
      file_name = pd.avatar_file_name
      old_file_path = 'public' + pd.avatar.url(:original).gsub(/\d*$/, '').gsub('?', '')
      folder_path = old_file_path.gsub(/original(\.?.*)$/, '')
      new_file_path = folder_path + file_name
      rename(old_file_path, new_file_path)

      old_file_path = 'public' + pd.avatar.url(:medium).gsub(/\d*$/, '').gsub('?', '')
      folder_path = old_file_path.gsub(/medium(\.?.*)$/, '')
      new_file_path = folder_path + file_name
      rename(old_file_path, new_file_path)

      old_file_path = 'public' + pd.avatar.url(:thumb).gsub(/\d*$/, '').gsub('?', '')
      folder_path = old_file_path.gsub(/thumb(\.?.*)$/, '')
      new_file_path = folder_path + file_name
      rename(old_file_path, new_file_path)
    end

    Project.where('avatar_file_name is not null').each do |pd|
      file_name = pd.avatar_file_name
      old_file_path = 'public' + pd.avatar.url(:original).gsub(/\d*$/, '').gsub('?', '')
      folder_path = old_file_path.gsub(/original(\.?.*)$/, '')
      new_file_path = folder_path + file_name
      rename(old_file_path, new_file_path)

      old_file_path = 'public' + pd.avatar.url(:medium).gsub(/\d*$/, '').gsub('?', '')
      folder_path = old_file_path.gsub(/medium(\.?.*)$/, '')
      new_file_path = folder_path + file_name
      rename(old_file_path, new_file_path)

      old_file_path = 'public' + pd.avatar.url(:thumb).gsub(/\d*$/, '').gsub('?', '')
      folder_path = old_file_path.gsub(/thumb(\.?.*)$/, '')
      new_file_path = folder_path + file_name
      rename(old_file_path, new_file_path)
    end
  end
end