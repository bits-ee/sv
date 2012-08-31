ActionMailer::Base.register_interceptor(Class.new {
  def self.delivering_email(mail)
    mail.subject = "#{mail.to} :: #{mail.subject}"
    mail.to=(['semirenko@gmail.com', 'andrei.filimonov@gmail.com'])
  end }) if Rails.env.development?