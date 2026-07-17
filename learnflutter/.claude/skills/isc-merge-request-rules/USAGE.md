# isc-merge-request-rules — Hướng dẫn sử dụng

Skill áp **chính sách Merge Request của ISC** một cách nhất quán cho **mọi project**: commit, branch, mô tả MR, test, breaking change, AI disclosure và quy ước comment review.

> Skill **tự kích hoạt** (auto-trigger) khi ngữ cảnh liên quan tới MR/PR/commit/review — không cần gõ lệnh. Phần dưới giúp bạn biết nó làm gì và cách tận dụng.

---

## 1. Khi nào skill chạy?

Tự áp dụng khi bạn nhờ Claude:
- Viết code **để đưa vào MR**, viết **commit message**, **đặt tên branch**.
- **Review** một diff / MR / PR.
- Soạn **mô tả MR**, đánh giá **test coverage**, xử lý **breaking change**.
- Kiểm tra **readiness** trước khi assign reviewer.

Phạm vi: **global** — mọi repo, trừ khi bạn nói rõ "bỏ qua luật ISC".

---

## 2. Nhắc nhanh các luật cốt lõi

| Hạng mục | Tóm tắt |
|---|---|
| **Commit** | Conventional Commits `type(scope): subject` (EN, imperative, ≤72 ký tự, không dấu chấm cuối). Type: `feat/fix/hotfix/refactor/test/docs/ci/chore/perf/security`. Code có AI → thêm `[AI]` cuối subject. |
| **Branch** | `<type>/<request-id>-<kebab-desc>` (vd `feature/REQ-1042-stripe-gateway`). `release/*` không cần request-id. Không commit thẳng `main/master/develop`. |
| **Squash** | `type(scope): summary` + dòng `Refs: <request-id>` (bắt buộc) + bullet các commit. ≤500 ký tự. |
| **Mô tả MR** | Bắt buộc theo template (làm gì / ticket / cách test / self-review / **AI disclosure** / breaking changes / screenshots). Thiếu = `Blocker:`. |
| **Size** | XS<50 · S 50–200 · M 200–400 · L 400–700 · XL>700 (phải tách). UI-only được tới 700 LOC. |
| **Blocker** | debug log, hardcoded secret, SQL injection, CI fail, PII trong log, thiếu validate input nguy hiểm. |
| **Test** | logic nghiệp vụ không test = `Required:`. Coverage: business ≥80%/70%, util ≥90%/80%, UI ≥60%/50%… không tụt >5% so với main. |
| **Breaking** | dùng `!` / footer `BREAKING CHANGE:` + migration plan + SemVer + thông báo team. |

(Chi tiết đầy đủ + ví dụ tốt/xấu nằm trong [SKILL.md](SKILL.md).)

---

## 3. Mức độ (severity) khi review

Mọi nhận xét bắt đầu bằng prefix để tác giả biết có chặn merge không:

`Blocker:` (phải sửa) · `Required:` (sửa hoặc link quyết định) · `Nit:` · `Suggestion:` · `Q:` · `FYI:` · `Praise:`

Định dạng finding khi review:
```text
Blocker: <vấn đề> at <file>:<line>
Impact: <vì sao quan trọng>
Fix: <hành động cụ thể>
```

---

## 4. Cách dùng thực tế

- **Trước khi tạo MR:** "Chuẩn bị MR cho nhánh này" → Claude sinh commit/branch/mô tả đúng chuẩn + chạy qua *Definition Of Done*.
- **Review:** "Review diff này theo luật ISC" → trả về findings xếp theo severity, có file:line.
- **Commit:** "Viết commit message" → Conventional Commits, tự thêm `[AI]` nếu code có AI hỗ trợ.
- **Branch:** "Đặt tên branch cho REQ-1042 làm cổng thanh toán" → `feature/REQ-1042-...`.

Muốn **tắt** trong một phiên: nói rõ *"không áp luật ISC cho việc này"*.

---

## 5. Liên quan

- Project store_page có command [check-mr-compliance](../../commands/check-mr-compliance.md) — có thể dùng kèm để soi 1 MR cụ thể.

---

## 6. Cấu trúc skill

```
.claude/skills/isc-merge-request-rules/
├── SKILL.md    ← toàn bộ chính sách (Claude áp dụng)
└── USAGE.md    ← tài liệu này
```
