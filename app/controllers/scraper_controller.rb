require "aws-sdk-lambda"
require "json"

class ScraperController < ApplicationController
  def index
    @articles = Article.where(session_id: session.id.to_s).order(created_at: :desc) # .where()でユーザーセッションに紐づく記事のみ取得
  end

  def scrape
    url = params[:article_url]
    lambda_function_name = "kobeNewsScraperFunction"
    aws_region = "ap-northeast-3" # 大阪リージョン

    # AWS Lambdaクライアントを作成
    lambda_client = Aws::Lambda::Client.new(region: aws_region)
    payload = { url: url }.to_json

    response = lambda_client.invoke({
      function_name: lambda_function_name,
      invocation_type: "RequestResponse", # 同期呼び出し（結果が返るまで待つ）
      log_type: "None",
      payload: payload
    })

    result = JSON.parse(response.payload.string)
    scraped_data = JSON.parse(result["body"])

      # 取得したデータでArticleを作成して保存
      @article = Article.new(
        url: url,
        title: scraped_data["title"],
        published_at: scraped_data["datetime"] != "N/A" ? Time.parse(scraped_data["datetime"]) : nil,
        body: scraped_data["body"],
        session_id: session.id.to_s,
        risk_score: scraped_data["risk_score"],
        summary: scraped_data["summary"]
      )

    respond_to do |format|
      format.turbo_stream
    end
  end
end
