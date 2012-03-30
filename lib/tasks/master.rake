desc "Recheck reviews likes"
task :check_likes => :environment do
  Review.update_all({:count_likes => 0})
  Review.all.each do |r|
    r.count_likes = r.likes.count
    r.save
    p "#{r.id} #{r.count_likes}"
  end
end
