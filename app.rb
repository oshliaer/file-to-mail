require 'bundler/setup'
require 'sinatra'
require 'mail'
require 'dotenv'

# Загрузка переменных окружения из файла .env
Dotenv.load

set :bind, ENV['APP_ADDRESS'] || '0.0.0.0'
set :port, ENV['APP_PORT'] ? ENV['APP_PORT'].to_i : 8080

SMTP_OPTIONS = {
  address: ENV['SMTP_ADDRESS'],
  port: ENV['SMTP_PORT'].to_i,
  user_name: ENV['SMTP_USER_NAME'],
  password: ENV['SMTP_PASSWORD'],
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
    #{'  '}
      <!-- Форма, которая будет отправлять данные методом POST на адрес /send -->
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
