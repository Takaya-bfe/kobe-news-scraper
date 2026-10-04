# Kobe News Scraper

神戸新聞の記事URLを入力すると、記事のタイトル・日時・本文をスクレイピングし、AI（OpenAI API）で **リスクスコア** と **要約** を付けて一覧表示する Web アプリです。
結果は Turbo Streams でページをリロードせずに一覧へ追加されます。記事はセッションごとに保存されるため、利用者ごとに自分の結果だけが表示されます。

## リポジトリ構成

このアプリは 2 つのリポジトリで構成されています。

| リポジトリ | 役割 | 言語 |
|---|---|---|
| **kobe-news-scraper**（このリポジトリ） | Web アプリ本体。URL の入力画面、Lambda の呼び出し、結果の保存と一覧表示 | Ruby / Rails |
| [**kobe-scraper-python**](https://github.com/Takaya-bfe/kobe-scraper-python) | Lambda 関数。記事のスクレイピングと OpenAI によるリスクスコア・要約の生成 | Python |

## 使用技術

- **Web アプリ**: Ruby 3.2.2 / Rails 8.0、Hotwire（Turbo Streams / Stimulus）、importmap
- **スクレイピング・AI**（Lambda 側）: Python 3.12、requests、BeautifulSoup、OpenAI API
- **データベース**: PostgreSQL
- **インフラ / デプロイ**: Docker、Kamal、GitHub Actions（CI）、AWS CodeBuild

## AWS 構成

```
ブラウザ ──▶ EC2（Rails / Docker） ──invoke──▶ Lambda（Python: スクレイピング + AI 分析）
                    │                                   ▲
                    ▼                                   │ デプロイ
              RDS（PostgreSQL）                     CodeBuild
```

- **EC2**: Rails アプリケーションをホスト
- **RDS (PostgreSQL)**: 記事データを保存
- **Lambda**（`kobeNewsScraperFunction`, ap-northeast-3）: 記事の取得と OpenAI によるスコアリング・要約
- **CodeBuild**: kobe-scraper-python のコードを zip にまとめて Lambda へデプロイ

## ローカルでの起動

```sh
bundle install
bin/rails db:prepare
bin/dev
```

本番の接続情報（RDS・Basic 認証など）は `config/credentials.yml.enc` に暗号化して保存しています。復号に必要な `config/master.key` はリポジトリに含めていません。
