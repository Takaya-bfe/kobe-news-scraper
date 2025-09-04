require "open-uri"
require "nokogiri"


class ScraperController < ApplicationController
  def index
    @articles = Article.all.order(created_at: :desc)
  end

  def scrape
    url = params[:article_url]

    charset = nil
    html = URI.open(url) do |f|
      charset = f.charset
      f.read
    end
    doc = Nokogiri::HTML.parse(html, nil, charset)

    # HTMLから必要な情報を抽出(ページのソースを確認して適宜変更すること)
    title = doc.css("h1.content--title").text
    datetime = doc.at_css("p.content--date time")["datetime"]
    body = doc.css("div.content--detail-body").text.strip

    Article.create(
      url: url,
      title: title,
      published_at: Time.parse(datetime), # 文字列をTimeオブジェクトに変換
      body: body
    )

    redirect_to root_path
  end
end
