# Kobe News Scraper

神戸新聞の記事URLを入力すると、記事のタイトル・日時・本文をスクレイピングし、AI（OpenAI API）で **リスクスコア** と **要約** を付けて一覧表示する Web アプリです。
スクレイピングと AI 分析は AWS Lambda で行い、結果は Turbo Streams でページをリロードせずに一覧へ追加されます。記事はセッションごとに保存されるため、利用者ごとに自分の結果だけが表示されます。

## 使用技術

- **バックエンド**: Ruby 3.2.2 / Rails 8.0
- **フロントエンド**: Hotwire（Turbo Streams / Stimulus）、importmap
- **スクレイピング・AI**: Nokogiri、OpenAI API（ruby-openai）
- **データベース**: PostgreSQL
- **インフラ / デプロイ**: Docker、Kamal、GitHub Actions（CI）

## AWS 構成

```
ブラウザ ──▶ EC2（Rails / Docker） ──invoke──▶ Lambda（スクレイピング + AI 分析）
                    │
                    └──▶ RDS（PostgreSQL）
```

- **EC2**: Rails アプリケーションをホスト
- **RDS (PostgreSQL)**: 記事データを保存
- **Lambda**（`kobeNewsScraperFunction`, ap-northeast-3）: 記事の取得と OpenAI によるスコアリング・要約
- **CodeBuild**: ビルドの自動化

## ローカルでの起動

```sh
bundle install
bin/rails db:prepare
bin/dev
```

本番の接続情報（RDS・OpenAI API キーなど）は `config/credentials.yml.enc` に暗号化して保存しています。復号に必要な `config/master.key` はリポジトリに含めていません。
