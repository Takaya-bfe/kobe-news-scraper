class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  # 本番のみBasic認証をかける（credentialsに設定がなければ起動時にエラーにする）
  if Rails.env.production?
    http_basic_authenticate_with name: Rails.application.credentials.basic_auth!.fetch(:username), password: Rails.application.credentials.basic_auth!.fetch(:password)
  end
end
