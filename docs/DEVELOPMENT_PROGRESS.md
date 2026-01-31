# やること帳 (Yarukoto-cho) 開発進捗ドキュメント

## 概要

社内チーム向けタスク管理アプリケーション「やること帳」の開発記録

## 技術スタック

| カテゴリ | 技術 | バージョン |
|----------|------|------------|
| Ruby | rbenv | 3.3.10 |
| Rails | - | 7.2.3 |
| PostgreSQL | Homebrew | 16.11 |
| Node.js | Homebrew | 25.5.0 |
| パッケージマネージャー | yarn | 1.22.22 |

---

## 完了したタスク

### Phase 1: 環境構築 ✅

#### 1. Ruby環境のセットアップ
```bash
# rbenvのインストール
brew install rbenv ruby-build

# Ruby 3.3.10のインストール
/opt/homebrew/bin/rbenv install 3.3.10
/opt/homebrew/bin/rbenv global 3.3.10

# 確認
export PATH="$HOME/.rbenv/versions/3.3.10/bin:$PATH"
ruby --version  # ruby 3.3.10
```

#### 2. PostgreSQLのセットアップ
```bash
brew install postgresql@16
brew services start postgresql@16

# データベース作成
/opt/homebrew/opt/postgresql@16/bin/createdb yarukoto_cho_development
/opt/homebrew/opt/postgresql@16/bin/createdb yarukoto_cho_test
```

#### 3. Railsアプリケーションの作成
```bash
export PATH="$HOME/.rbenv/versions/3.3.10/bin:/opt/homebrew/opt/postgresql@16/bin:$PATH"
rails new yarukoto_cho --database=postgresql --css=tailwind --javascript=esbuild --skip-test
```

#### 4. Node.js/Yarnパッケージのセットアップ
```bash
# Node.jsの再インストール（icu4c互換性問題の解決）
brew reinstall node

# Yarnの場所
~/.npm-global/bin/yarn

# パッケージインストール
export PATH="$HOME/.npm-global/bin:$PATH"
cd /path/to/yarukoto_cho
yarn install
```

#### 5. Gemfile に追加した依存関係

```ruby
# Authentication
gem "devise", "~> 4.9"
gem "omniauth", "~> 2.1"
gem "omniauth-google-oauth2"
gem "omniauth-github"
gem "omniauth-rails_csrf_protection"

# Authorization
gem "pundit", "~> 2.3"

# Background jobs
gem "sidekiq", "~> 7.2"
gem "redis", "~> 5.0"

# Search
gem "ransack", "~> 4.1"

# Pagination
gem "pagy", "~> 8.0"

# Admin
gem "activeadmin", "~> 3.2"

# Slug generation
gem "friendly_id", "~> 5.5"

# Markdown rendering
gem "redcarpet", "~> 3.6"

# Image processing
gem "image_processing", "~> 1.2"

# Testing (development, test group)
gem "rspec-rails", "~> 6.1"
gem "factory_bot_rails", "~> 6.4"
gem "faker", "~> 3.2"
gem "capybara", "~> 3.39"
gem "selenium-webdriver"
gem "shoulda-matchers", "~> 6.0"

# Development tools
gem "bullet"
gem "better_errors"
gem "binding_of_caller"
```

---

### Phase 1: Devise認証 (進行中)

#### 完了した作業

1. **Deviseのインストール**
   ```bash
   rails generate devise:install
   rails generate devise User
   ```

2. **Userマイグレーションの更新** (`db/migrate/20260130141614_devise_create_users.rb`)
   - Trackable有効化（サインイン追跡）
   - Confirmable有効化（メール確認）
   - プロフィールフィールド追加（name, avatar）
   - OAuthフィールド追加（provider, uid）

3. **Userモデルの更新** (`app/models/user.rb`)
   ```ruby
   class User < ApplicationRecord
     devise :database_authenticatable, :registerable,
            :recoverable, :rememberable, :validatable,
            :confirmable, :trackable,
            :omniauthable, omniauth_providers: [:google_oauth2, :github]

     has_many :organization_memberships, dependent: :destroy
     has_many :organizations, through: :organization_memberships
     has_many :project_members, dependent: :destroy
     has_many :projects, through: :project_members
     has_many :assigned_tasks, class_name: "TaskAssignment", dependent: :destroy
     has_many :tasks, through: :assigned_tasks
     has_many :comments, dependent: :destroy
     has_many :activities, dependent: :destroy
     has_many :notifications, dependent: :destroy

     has_one_attached :avatar_image

     validates :name, presence: true, length: { maximum: 100 }

     def self.from_omniauth(auth)
       # OAuth認証処理
     end

     def admin_of?(organization)
       organization_memberships.exists?(organization: organization, role: :admin)
     end

     def member_of?(organization)
       organizations.exists?(id: organization.id)
     end
   end
   ```

4. **Devise初期化ファイルの設定** (`config/initializers/devise.rb`)
   - OmniAuth Google OAuth2 設定
   - OmniAuth GitHub 設定
   - mailer_sender を環境変数から取得

---

## 未完了タスク

### Phase 1 残り

- [ ] OmniAuthコールバックコントローラーの作成
- [ ] Deviseビューのカスタマイズ
- [ ] マイグレーション実行
- [ ] RSpecのセットアップ

### Phase 1: 組織・ユーザーモデル設計

- [ ] Organizationモデル作成
- [ ] OrganizationMembershipモデル作成（role: admin/member/guest）
- [ ] 招待システムの実装

### Phase 1: プロジェクト・タスクの基本CRUD

- [ ] Projectモデル作成
- [ ] ProjectMemberモデル作成
- [ ] Taskモデル作成
- [ ] Subtaskモデル作成
- [ ] Labelモデル作成
- [ ] TaskAssignmentモデル作成
- [ ] Commentモデル作成
- [ ] Activityモデル作成
- [ ] 基本的なコントローラーとビュー

### Phase 2: コア機能

- [ ] Punditで認可
- [ ] 招待システム（メール送信）
- [ ] タスク詳細機能（担当者、期限、優先度）
- [ ] ラベル・タグ機能
- [ ] コメント機能

### Phase 3: 応用

- [ ] カンバンボード（Stimulus）
- [ ] サブタスク
- [ ] ファイル添付（Active Storage）
- [ ] アクティビティログ
- [ ] 検索・フィルター（Ransack）

### Phase 4: リアルタイム

- [ ] Action Cableで通知
- [ ] カンバンリアルタイム同期
- [ ] ダッシュボード
- [ ] メール通知（Sidekiq）

### Phase 5: 仕上げ

- [ ] OAuthログイン完成
- [ ] ActiveAdmin管理画面
- [ ] RSpecテスト
- [ ] パフォーマンス最適化
- [ ] Renderへデプロイ

---

## データモデル設計（計画）

```
Organization (組織)
├── id
├── name
├── slug (friendly_id)
├── logo (Active Storage)
└── timestamps

OrganizationMembership (組織メンバーシップ)
├── id
├── user_id
├── organization_id
├── role (enum: admin, member, guest)
└── timestamps

Project (プロジェクト)
├── id
├── organization_id
├── name
├── description
├── archived (boolean)
└── timestamps

ProjectMember (プロジェクトメンバー)
├── id
├── project_id
├── user_id
└── timestamps

Task (タスク)
├── id
├── project_id
├── title
├── description (Markdown)
├── status (enum: todo, in_progress, done)
├── priority (enum: high, medium, low)
├── due_date
├── position (カンバン並び順)
└── timestamps

Subtask (サブタスク)
├── id
├── task_id
├── title
├── completed (boolean)
├── position
└── timestamps

TaskAssignment (タスク担当者)
├── id
├── task_id
├── user_id
└── timestamps

Label (ラベル)
├── id
├── project_id
├── name
├── color
└── timestamps

TaskLabel (タスク-ラベル中間テーブル)
├── id
├── task_id
├── label_id
└── timestamps

Comment (コメント)
├── id
├── task_id
├── user_id
├── body
└── timestamps

Attachment (添付ファイル - Active Storage)

Activity (アクティビティログ)
├── id
├── user_id
├── trackable_type
├── trackable_id
├── action
├── metadata (jsonb)
└── timestamps

Notification (通知)
├── id
├── user_id
├── notifiable_type
├── notifiable_id
├── read_at
└── timestamps
```

---

## 環境変数（必要）

```bash
# .env.example
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GITHUB_CLIENT_ID=
GITHUB_CLIENT_SECRET=
MAILER_SENDER=noreply@yarukoto-cho.example.com
REDIS_URL=redis://localhost:6379/0
```

---

## 開発コマンド

```bash
# 環境変数の設定
export PATH="$HOME/.rbenv/versions/3.3.10/bin:/opt/homebrew/opt/postgresql@16/bin:$HOME/.npm-global/bin:$PATH"

# サーバー起動
bin/dev

# マイグレーション
rails db:migrate

# コンソール
rails console

# テスト
bundle exec rspec

# Sidekiq（バックグラウンドジョブ）
bundle exec sidekiq
```

---

## 注意事項

1. **rbenvのPATH**: `$HOME/.rbenv/versions/3.3.10/bin` を使用
2. **PostgreSQLのPATH**: `/opt/homebrew/opt/postgresql@16/bin` を使用
3. **YarnのPATH**: `$HOME/.npm-global/bin` を使用
4. **Dangerous command guard**: `rehash` を含むコマンドがhookでブロックされる場合あり

---

## 参照

- 要件定義書: ユーザーからの最初のメッセージを参照
- Rails Guides: https://guides.rubyonrails.org/
- Devise Wiki: https://github.com/heartcombo/devise/wiki
- Hotwire: https://hotwired.dev/

---

*最終更新: 2026-01-30*
