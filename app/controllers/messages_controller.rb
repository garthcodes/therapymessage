class MessagesController < ApplicationController
  before_action :authenticate_user!

  def index
    @messages = Message.inbox(current_user.id).page params[:page]
    # @messages = messages.text_search(params[:query]).page params[:page]
  end

  def show
    @message = Message.show_message(params[:id], current_user.id)
  end

  def sent
    @sent = Message.sent_box(current_user.id).page params[:page]
  end

  def new
    if params[:receiver_id].present?
      @receiver = User.find_receiver(params[:receiver_id])
    end
    @message = Message.new
  end

  def create
    if current_user.type == "Provider"
      receiver_id = User.compose_user(params[:message][:receiver_id])
      @message = Message.create(body: params[:message][:body], subject: params[:message][:subject], sender_id: params[:message][:sender_id], receiver_id: receiver_id)
    else
      @message = Message.create(message_params)
    end
    if @message.save
      # MessageMailer.message_created_notification(current_user, @message).deliver!
      redirect_to messages_path, notice: 'Message was successfully sent!'
    else
      redirect_to messages_path, notice: 'There was an error sending your message!'
    end
  end

  def archive
    @archived_sent = Message.where(sender_id: current_user.id, archived: true).order("created_at DESC").page params[:page]
    @archive = Message.where(receiver_id: current_user.id, archived: true).order("created_at DESC").page params[:page]
  end

  def ajax_archive
    Message.where(id: params[:id]).update_all(archived: true)
  end


  private

  def message_params
    params.require(:message).permit!
  end

end