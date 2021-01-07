module Api
  module V1
    class NotificationsController < ApplicationController
      before_action :authorize_access_request!

      def index
        @notifications = current_user.notifications
        render json: @notifications
      end

      def show
        @notification = current_user.notifications.find_by(id: params[:id])
        @notification.checked

        if @notification.classification === 'entry'

          @entry = Entry.find(@notification.entry_id)
          @post = @entry.post
          @user = @entry.user

          rapping_response = [{
            "notification" => @notification,
            "entry" => @entry,
            "post" => @post,
            "user" => @user }]

          render json: rapping_response

        elsif @notification.classification === 'entryResponse'

          @entry_response = EntryResponse.find(@notification.entry_response_id)
          @post = @entry_response.post
          @user = @entry_response.user

          rapping_response = [{
            "notification" => @notification,
            "entry_response" => @entry_response,
            "post" => @post,
            "user" => @user }]

          render json: rapping_response

        elsif @notification.classification === 'message'

          @message = Message.find_by(id: @notification.message_id)

          rapping_response = [{
            "notification" => @notification,
            "message" => @message
          }]

          render json: rapping_response
        end
      end
    end
  end
end