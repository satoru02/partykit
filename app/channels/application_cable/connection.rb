module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private
      def find_verified_user
        jwt = cookies[:jwt_access]
        decoded = JWT.decode(jwt, nil, false)
        user_id = decoded[0]["user_id"]

        if verified_user = User.find_by(id: user_id)
          verified_user
        else
          reject_unauthorized_connection
        end
      end
  end
end
