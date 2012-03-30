desc "Update reviews likes"
task :likes_up => :environment do
  Review.update_all({:count_likes => 0})
  Review.all.each do |r|
    r.count_likes = r.likes.count
    r.save
    p "#{r.id} #{r.count_likes}"
  end
end

desc "Create preferences for users"
task :cr_user_refs => :environment do
  User.all.each do |u|
    p u.id if UserPreference.create(:user_id => u.id)
  end
end