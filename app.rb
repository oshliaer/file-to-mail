require 'bundler/setup'
require 'sinatra'
require 'mail'
require 'dotenv'

# Загрузка переменных окружения из файла .env
Dotenv.load

set :bind, ENV.fetch('APP_ADDRESS', '127.0.0.0')
set :port, Integer(ENV.fetch('APP_PORT', 8080))

SMTP_OPTIONS = {
  address: ENV.fetch('SMTP_ADDRESS'),
  port: Integer(ENV.fetch('SMTP_PORT')),
  user_name: ENV.fetch('SMTP_USER_NAME'),
  password: ENV.fetch('SMTP_PASSWORD'),
  authentication: 'plain',
  enable_ssl: true,
  enable_starttls_auto: true
}

get '/' do
  <<~HTML
    <!DOCTYPE html>
    <html>
    <head>
      <title>Отправка файлов по LAN</title>
    </head>
    <body style="font-family: sans-serif; max-width: 400px; margin: 40px auto;">
      <h2>Отправить файл на почту</h2>
      
      <!-- Форма, которая будет отправлять данные методом POST на адрес /send_email -->
      <form action="/send_email" method="post" enctype="multipart/form-data">
        <p>
          <label>Кому (Email):<br>
            <input type="email" name="to" required style="width: 100%;">
          </label>
        </p>
        <p>
          <label>Выберите файл:<br>
            <input type="file" name="file" required>
          </label>
        </p>
        <button type="submit">Отправить файл</button>
      </form>
    #{'  '}
    </body>
    </html>
  HTML
end

post '/send_email' do
  return 'Missing parameters. Please provide both "to" and "file".' unless params[:to] && params[:file]

  params[:to]
  params[:subject] || 'No Subject'
  params[:file][:tempfile]
  params[:file][:filename]

  Mail.defaults do
    delivery_method :smtp, SMTP_OPTIONS
  end

  'OK'
end
