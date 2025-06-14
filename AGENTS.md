# Nyanble Project Guide  
*初期構築の指針ドキュメント*  

---

## 1. プロダクト使命
「今日“にゃん”と行ける場所」を瞬時に提案し、  
移動前・移動中・移動後をシームレスにつなぐ  
**オンデバイス完結型おでかけパートナー**。

---

## 2. 機能構成

| 領域 | 概要 | 主要 API |
|------|------|----------|
| **AI 提案** | 自然文を解析してお出かけ候補を生成し、説明文を作成 | Foundation Models |
| **Intent 集約** | 検索・履歴・評価・シェアなどの全操作を AppIntent 化し、Siri・Spotlight・Widget から呼び出し可能 | AppIntent |
| **データ管理** | SwiftData を単一ソースとし、`@Model` ⇄ `AppEntity` 変換で UI・Intent・AI を連携 | SwiftData |
| **可視化／UI** | Liquid Glass デザインと SwiftCharts による行動履歴の可視化 | SwiftUI / SwiftCharts |
| **クラウド連携** | 有料サブスクリプションで iCloud ミラーおよび Family Sharing を解放 | StoreKit / CloudKit |

---

## 3. データモデル方針

- **POI（地点）**: UUID, 名称, カテゴリ, タグ, 位置情報, 推奨滞在時間  
- **Preference（好み）**: お気に入りカテゴリ, 最大移動時間, 不得意タグ  
- **Visit（履歴）**: POI 参照, 訪問日時, 評価  

すべて SwiftData の `@Model` で定義し、AppIntent では対応する `@AppEntity` を公開。  
`Model ↔ Entity` 相互変換エクステンションを用意してレイヤー間を疎結合に保つ。

---

## 4. Intent カタログ（抜粋）

| Intent 名 | 主なパラメータ | 役割 |
|-----------|---------------|------|
| SuggestOutingIntent | `query`（自然文） | 希望条件に応じておすすめを 1 件生成 |
| ListPlansIntent | `date`（任意） | 指定日の提案を列挙 |
| LogVisitIntent | `place`, `rating` | 訪問結果を保存 |
| SyncICloudIntent | なし | サブスクユーザー向けに iCloud 同期を実行 |

---

## 5. プロンプト設計要点

1. **入力解析**  
   - 役割: outdoor_planner  
   - 形式: JSON `{ mood, duration, tags[] }`  
   - ガイド付き生成でスキーマ逸脱を防止  
2. **ルート説明**  
   - 役割: travel_guide  
   - 1 件あたり 120 文字以内、親しみやすい日本語  
   - 出力: `{ id, comment }` を配列で返す

---

## 6. UI & デバイス対応

| 画面 | 対応デバイス | 特記事項 |
|------|-------------|----------|
| メインカード | iPhone / iPad (SplitView) | Liquid Glass + FlowGrid レイアウト |
| ウィジェット | ホーム・スタック | 今日のおすすめ・混雑ヒートマップ |
| コンプリケーション | Apple Watch | 「にゃん速提案」で即起動 |
| 履歴ビュー | 全デバイス | SwiftCharts による統計表示 |

---

## 7. サブスクリプション構成

| プラン | 無料版 | プレミアム版 |
|--------|--------|--------------|
| オンデバイス AI 提案 | ✔ | ✔ |
| ローカル履歴保存 | ✔ | ✔ |
| iCloud 同期 & Family Sharing | – | ✔ |
| 高度統計（月次レポート） | – | ✔ |

---

## 8. 開発ロードマップ（6 週間）

| 週 | マイルストーン |
|----|----------------|
| 1 | SwiftData スキーマ定義 & POI インポート |
| 2 | Foundation Models 解析 PoC |
| 3 | 提案ロジック + メイン UI |
| 4 | AppIntent 実装 & Widget 対応 |
| 5 | サブスク連携 & iCloud ミラー |
| 6 | マルチデバイス最適化 & TestFlight 配信 |

---

## 9. プライバシー & 運用メモ

1. **位置情報**: `WhenInUse` のみ要求、履歴は暗号化保存  
2. **通信**: 無料版は完全オフライン、天気情報はキャッシュを 1 時間保持  
3. **商標・ドメイン**: 「Nyanble」.com / .app の取得状況を確認  
4. **スキーマ移行**: `SchemaVersion 1` から開始し、将来拡張に備える  

---

## 10. Coding Style Guidelines

- 1 クラス 1 ファイル（1 public type = 1 ファイル）

---

> **Next Action**  
> - スキーマ定義と Intent 詳細のコード化  
> - プロンプトの実機チューニング  
> - UI モックを Figma または SwiftUI Preview で確認