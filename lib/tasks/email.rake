namespace :email do
  desc "Call from postfix for email maessage parsing"
  task(:message,:email,:needs => :environment) do |task,args|
    objEmail = EmailController.new
    objEmail.message
  end
end