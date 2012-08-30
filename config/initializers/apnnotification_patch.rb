APN::Notification.class_eval do
  def apple_hash
  
    user = User.find_by_id(self.user_id_from)   
    result = {}
    result['aps'] = {}
    result['aps']['alert'] = "#{user.name.split.first} #{user.name.split.second[0] if user.name.split.second} #{self.alert}" if self.alert
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
  
  # Creates the binary message needed to send to Apple.
  # def message_for_sending
  #   json = self.to_apple_json.gsub(/\\u([0-9a-z]{4})/) {|s| [$1.to_i(16)].pack("U")} # This will create non encoded string. Otherwise the string is encoded from utf8 to ascii with unicode representation (i.e. \\u05d2)
  #   message = "\0\0 #{self.device.to_hexa}\0#{json.length.chr}#{json}"
  #   raise APN::Errors::ExceededMessageSizeError.new(message) if message.size.to_i > 256
  #   message
  # end
  
  
  def self.send_notifications(notifications = APN::Notification.where("sent_at IS NULL AND device_id != 0"))
    unless notifications.nil? || notifications.empty?

      notifications.each do |noty|
        begin
          APN::Connection.open_for_delivery do |conn, sock|  
            if Session.find_by_user_id(noty.user_id_to)
              conn.write(noty.message_for_sending)
              noty.sent_at = Time.now
              noty.save
            end
          end
        rescue Exception => e
          noty.sent_at = Time.now
          noty.save
          APN::Notification.send_notifications
        end
      end

    end
  end
  
end