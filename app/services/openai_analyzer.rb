require "openai"

class OpenaiAnalyzer
  def initialize(article_title, article_body)
    @article_title = article_title
    @article_body = article_body
    @client = OpenAI::Client.new(access_token: Rails.application.credentials.openai.api_key)
  end

  def analyze
    prompt = create_prompt

    begin
      response = @client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [ { role: "user", content: prompt } ],
          temperature: 0.2,
          response_format: { type: "json_object" }
        }
      )

      # AIからのJSON形式の回答を解析する
      result = JSON.parse(response.dig("choices", 0, "message", "content"))

      {
        risk_score: result["risk_score"],
        summary: result["summary"]
      }
    rescue => e
      # APIエラーなどが発生した場合の処理
      Rails.logger.error "OpenAI API Error: #{e.message}"
      { risk_score: nil, summary: "AIによる分析に失敗しました。" }
    end
  end

  private

  def create_prompt
    <<~PROMPT
    以下のNHKニュース記事を分析し、指定されたJSON形式でリスクスコアと要約を生成してください。

    # 記事
    タイトル: #{@article_title}
    本文: #{@article_body}

    # 指示
    1.  **リスクスコア**: 記事の内容が示す事故や事件の深刻度を評価してください。評価基準は、被害範囲、被害の程度、社会的影響、死傷者の有無や被害金額の大きさです。スコアは1から100の整数で、スコアが高いほど高リスクとしてください。
    2.  **要約**: 記事の内容を200文字から250文字程度の日本語で要約してください。

    # 出力形式
    以下のキーを持つJSONオブジェクトのみで回答してください:
    {
      "risk_score": <整数>,
      "summary": "<200文字から250文字程度の要約>"
    }
    PROMPT
  end
end
