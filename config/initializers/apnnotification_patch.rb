APN::Notification.class_eval do
  def apple_hash

    user = User.find_by_id(self.user_id_from)   
    result = {}
    result['aps'] = {}
    result['aps']['alert'] = "#{user.name.split.first} #{user.name.split.second[0]} #{self.alert}" if self.alert
    result['aps']['alert'] = "#{result['aps']['alert'].slice 0 .. 40}..." if result['aps']['alert'].length > 40

    result['aps']['badge'] = self.badge.to_i if self.badge
    if self.sound
      result['aps']['sound'] = self.sound if self.sound.is_a? String
      result['aps']['sound'] = "1.aiff" if self.sound.is_a?(TrueClass)
    end
    if self.custom_properties
      self.custom_properties.each do |key,value|
        result["#{key}"] = "#{value}"
      end
    end
    result
  end
  
  def self.send_notifications(notifications = APN::Notification.all.where("sent_at IS NULL AND device_id IS NOT NULL"))
    unless notifications.nil? || notifications.empty?

      APN::Connection.open_for_delivery do |conn, sock|
        notifications.each do |noty|
          conn.write(noty.message_for_sending)
          noty.sent_at = Time.now
          noty.save
        end
      end

    end
  end
  
end