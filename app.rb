require 'bundler/setup'
require 'sinatra'
require 'mail'
require 'dotenv'

# Загрузка переменных окружения из файла .env
Dotenv.load

set :bind, ENV['APP_ADDRESS'] || '0.0.0.0'
set :port, ENV['APP_PORT'] ? ENV['APP_PORT'].to_i : 8080

SMTP_OPTIONS = {
  address: ENV['SMTP_ADDRESS'], # 'smtp.mail.ru'
  port: ENV['SMTP_PORT'].to_i, # 465
  user_name: ENV['SMTP_USER_NAME'],
  password: ENV['SMTP_PASSWORD'],
  authentication: :plain, # В Ruby лучше использовать символ :plain, а не строку 'plain'

  # Вот эта связка лечит таймаут на Mail.ru:
  ssl: true,                    # Включаем жесткий SSL для порта 465
  tls: true,                    # Дублируем для совместимости с net/smtp
  enable_starttls: false, # Намертво КАТЕГОРИЧЕСКИ ОТКЛЮЧАЕМ starttls
  enable_starttls_auto: false # Отключаем авто-попытки включить starttls
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

  Mail.defaults do
    delivery_method :smtp, SMTP_OPTIONS
  end

  to_address = params[:to]
  subject = params[:subject] || 'No Subject'
  body = params[:body] || 'Please find the attached file.'
  file_name = params[:file][:filename]
  file_tmp = params[:file][:tempfile]

  begin
    Mail.deliver do
      from SMTP_OPTIONS[:user_name]
      to to_address
      subject subject
      body body
      add_file filename: file_name, content: file_tmp.read
    end
  rescue StandardError => e
    status 500
    "<h3>Ошибка отправки:</h3><pre style='color:red;'>#{e.message}</pre><a href='/'>Назад</a>"
  end
end
