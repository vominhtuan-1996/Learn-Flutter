---
name: isc-merge-request-rules
description: Use when creating, reviewing, preparing, or validating GitLab Merge Requests, commits, branch names, tests, AI-assisted code, breaking changes, MR descriptions, or reviewer comments under ISC rules. Applies globally to every project unless the user explicitly says otherwise.
license: MIT
version: 1.0.0
---

<!-- 📖 Hướng dẫn sử dụng: xem USAGE.md -->


# ISC Merge Request Rules

Use this skill for every project when the user asks to create code intended for a Merge Request, review a diff/MR/PR, write commits, name branches, prepare MR descriptions, assess tests, handle AI-assisted code, or check release/breaking-change readiness.

The goal is to enforce the ISC Merge Request policy consistently across all repositories.

## Severity Model

Classify findings and required work with these levels:

- `Blocker:` Severe violation. Must be fixed before merge. No exception.
- `Required:` Mandatory issue. Must be fixed in the MR, or explicitly tracked with a linked ticket before merge if deferral is accepted.
- `Nit:` Small non-blocking improvement.
- `Suggestion:` Optional improvement.
- `Q:` Question, not an action by itself.
- `FYI:` Information only.
- `Praise:` Positive feedback.

When reviewing, findings must start with one of these prefixes so the author knows whether the comment blocks merge.

## Commit Message Rules

All commits must use Conventional Commits:

```text
<type>(<scope>): <subject>
```

Allowed `type` values:

- `feat`
- `fix`
- `hotfix`
- `refactor`
- `test`
- `docs`
- `ci`
- `chore`
- `perf`
- `security`

Rules:

- `scope` is optional and should name the affected module/component.
- `subject` must be English, lowercase where practical, imperative mood, and without a trailing period.
- Best practice: subject length <= 72 characters.
- Full regular commit message must be <= 500 characters.
- Merge commit and squash commit templates must be <= 500 characters.
- Merge suggestions must be <= 255 characters.
- If code was assisted by AI, append `[AI]` to the end of the subject.

Examples:

```text
feat(auth): add OAuth2 PKCE flow
fix(api): resolve pagination off-by-one
security: patch SQL injection in search
test(user): add edge case for null email
feat(payment): generate Stripe hook [AI]
refactor(service): extract handler [AI]
```

Bad examples:

```text
Fixed bug
WIP
update code
Add feature.
fix(Auth): Fixed.
Sua loi dang nhap
```

## Squash Commit Message

When merging multiple commits with squash, use:

```text
<type>(<scope>): <summary of entire MR - max 72 chars>

Refs: <request-id>

* <commit 1 summary>
* <commit 2 summary>
* <commit 3 summary>
```

Rules:

- `Refs:` is mandatory and must contain the request ID from the PM tool.
- Keep the whole squash message <= 500 characters.
- Add `[AI]` to AI-assisted commit summaries when applicable.

## Branch Naming Rules

Required format:

```text
<type>/<request-id>-<short-description>
```

Allowed branch `type` values:

- `feature`
- `bugfix`
- `hotfix`
- `refactor`
- `test`
- `chore`
- `perf`
- `security`
- `release`

Rules:

- `request-id` is mandatory for every type except `release/*`.
- `short-description` must be kebab-case, lowercase, and <= 50 characters.
- Do not use underscores, camelCase, spaces, or Vietnamese accents in branch names.
- `release/*` does not need a request ID, for example `release/v2.4.0`.
- Do not create separate `docs/*` or `ci/*` branches. Use a related `feature/*`, `bugfix/*`, or `chore/*` branch and use `docs`/`ci` commit types inside it.
- Branch type represents the main purpose of the MR, not every commit inside it.
- Do not commit directly to `main`, `master`, or `develop`. Use branch plus MR.
- Delete branches after merge, preferably with GitLab auto-delete enabled.

Examples:

```text
feature/REQ-1042-stripe-payment-gateway
bugfix/BUG-234-cart-null-pointer-error
hotfix/INC-89-payment-service-down
refactor/TECH-56-extract-auth-service
chore/DEVOPS-12-upgrade-node-version
test/QA-78-add-e2e-checkout-flow
perf/TECH-91-optimize-db-query-index
security/SEC-07-patch-sql-injection-search
release/v2.4.0
```

## MR Description Template

An MR without a complete description is a `Blocker:` and should be rejected before code review.

Use this template:

```markdown
## Thay doi nay lam gi?
<!-- Mo ta ngan: lam gi va tai sao. Khong mo ta HOW neu code da tu noi. -->

## Ticket
Closes #<issue-number> | Ref: <PROJ-XXX>

## Cach kiem tra
1. ...
2. ...

## Self-review checklist
- [ ] Da chay unit test local pass
- [ ] Khong co debug code (console.log, print, breakpoint)
- [ ] Khong co hardcoded secret (API key, password, token)
- [ ] Commit messages dung Conventional Commits format

## AI Disclosure
- [ ] Khong dung AI trong MR nay
- [ ] Dung AI - da them tag [AI] vao cuoi subject cua cac commit lien quan
- [ ] Viet code moi
- [ ] Refactor code hien co
- [ ] Viet test
- [ ] Debug / investigate
- [ ] % LOC AI-assisted (uoc tinh): ____%
- [ ] Da doc ky va hieu tung dong AI sinh ra

## MR Type (LOC threshold)
- [ ] UI Components MR - toan bo diff la UI layer (component, screen, template)
/label ~"scope:ui"
<!-- CI quality gate ap 700 LOC khi label scope:ui duoc gan. Chi tick neu KHONG co file backend/service trong diff. -->

## Breaking Changes
<!-- Neu khong co, ghi N/A. Neu co, ghi ro thay doi, consumer bi anh huong, migration plan. -->

## Screenshots
<!-- Bat buoc neu co UI thay doi. -->
```

## MR Size Rules

Evaluate changed LOC excluding generated code, minified files, migrations, vendor files, lock files, and binary files.

- XS: `< 50 LOC`. No extra requirement. Expected review time < 15 minutes.
- S: `50-200 LOC`. Complete description required. Expected review time 15-30 minutes.
- M: `200-400 LOC`. Explain reason clearly in description. Expected review time 30-60 minutes.
- L: `400-700 LOC`. Reviewer may request splitting the MR. Expected review time 60-90 minutes.
- XL: `> 700 LOC`. Must split, except generated files, migrations, or UI Components exception.

UI Components exception:

- UI-only MRs may go up to 700 LOC.
- The entire diff must be UI layer only: components, screens, templates, markup, style, and component logic.
- If backend/service files are included, the UI exception does not apply.

## Code Quality Blockers

Flag these as `Blocker:`:

- Debug statements left in code: `console.log`, `print`, `debugger`, `breakpoint`, or equivalent.
- Hardcoded secrets: API keys, passwords, tokens, connection strings.
- SQL injection risk: raw query string concatenation/interpolation with user input.
- CI/CD pipeline failing while requesting review.
- Sensitive data in logs: PII, credentials, payment info, tokens, passwords.
- Missing input validation for external data when it creates security or data-integrity risk.

## Code Quality Required Items

Flag these as `Required:` unless they create immediate security/data-loss risk, in which case use `Blocker:`:

- Error handling must be complete. No silent failures.
- Avoid magic numbers. Use named constants when the value has business meaning.
- Naming must describe intent. Avoid unclear abbreviations like `d`, `tmp`, or vague `data` when domain meaning exists.
- Validate all external input before processing.
- Avoid over-engineering and speculative abstractions. Solve the current problem.
- Do not leave TODO comments unless linked to a ticket.

## Testing Rules

Business logic added or changed without tests is a `Required:` violation.

Coverage expectations by code type:

- Business logic: line coverage >= 80%, branch coverage >= 70%.
- API controllers/route handlers: line coverage >= 70%, branch coverage >= 60%.
- Utility/helper functions: line coverage >= 90%, branch coverage >= 80%.
- UI components: line coverage >= 60%, branch coverage >= 50%.
- Infrastructure/config/migration: line coverage >= 50% where practical; branch coverage not required.

Coverage rules:

- Coverage must not drop by more than 5% versus the main branch.
- Bug fix MRs must include a regression test when feasible.
- Tests must be merged in the same MR as the production code.

Test quality rules:

- Test names should describe behavior, for example `should return 404 when user not found`.
- Avoid vague names like `test_get_user`.
- Every test needs at least one clear assertion about expected behavior.
- Do not only assert that mocks were called unless the behavior is the interaction itself.
- Include edge cases: null/undefined, empty string/array, boundary values, and error paths.
- Tests must be independent and not rely on execution order or external state.
- No hardcoded credentials or PII in test data. Use fixtures/fakers.

## AI-Assisted Code Rules

Apply these rules whenever any code, tests, refactor, debugging, or investigation was assisted by AI.

- Developer is 100% responsible for AI-generated code.
- AI usage must be disclosed in the MR description and in commit subjects using `[AI]`.
- Review AI-generated code more carefully, not less carefully.
- Do not merge AI-generated code that the author cannot explain.
- Use AI pre-review before human review to check security, logic, edge cases, and test quality.
- Verify there are no hallucinated APIs, nonexistent methods, fake config keys, or invented behavior.

Recommended self-review prompt:

```text
Read this git diff and check:
1. OWASP Top 10 risks, especially injection, auth bypass, hardcoded secrets.
2. Whether the logic matches the ticket requirements.
3. Which edge cases are not handled.
4. Whether tests verify behavior or only verify mocks.
```

## Breaking Changes

A breaking change is any change that forces callers/consumers to change their code to avoid errors after the MR is merged.

Always treat these as breaking changes:

- Delete or rename public API endpoint, public function, public method, or public contract.
- Change parameter type or return-value type.
- Add a required parameter to an existing function/API.
- Remove a required field from API response or event schema.
- Change behavior so the same input produces a different output, even if the signature is unchanged.
- Delete or rename a database column currently used by consumers.
- Change authentication/authorization contract, for example API key to JWT.

Usually not breaking if backward compatible:

- Add a new endpoint while keeping the old endpoint.
- Add an optional response field.
- Add an optional parameter with a default value.
- Add a nullable/defaulted DB column.
- Fix a bug so behavior matches documented spec.
- Refactor internal implementation without changing public API.
- Improve performance without changing the contract.

Gray zone: changed error message, HTTP status code, JSON field order, or stricter validation may be breaking depending on consumers. If unsure, mark as breaking.

Commit message for breaking changes must use `!`, `BREAKING CHANGE:` footer, or both:

```text
feat(api)!: replace userId integer with UUID string

BREAKING CHANGE: userId field in all User endpoints changes from integer to UUID string format. Consumers must update int parsing to string.
Refs: REQ-2001
```

Breaking-change MR requirements:

- Commit message declares the breaking change.
- MR description explains what changed, affected consumers, and migration plan.
- Reviewer confirms documentation and migration plan are sufficient.
- Affected teams/services are notified before merge.
- Versioning follows Semantic Versioning.
- `CHANGELOG.md` is updated when the repo maintains one.
- Migration script exists and is verified on staging when DB/data changes require it.

Semantic versioning:

- `MAJOR`: breaking change.
- `MINOR`: backward-compatible feature.
- `PATCH`: backward-compatible fix/refactor/perf/docs/chore/test.

## Definition Of Done Before Submit

Before assigning a reviewer, verify:

- MR title is short and follows Conventional Commits style.
- MR description uses the required template.
- Ticket/request ID is linked.
- AI Disclosure is filled, including the explicit no-AI case.
- MR size is acceptable, or split/justified.
- Breaking changes are documented with migration plan, or marked `N/A`.
- All commits follow Conventional Commits and `[AI]` is present where required.
- Author has read the entire diff.
- No debug statements, hardcoded secrets, SQL injection risk, or sensitive logging.
- External input is validated.
- CI/CD pipeline passes.
- Unit tests cover new/changed business logic.
- Coverage does not drop more than 5% versus main.
- Tests have behavior-focused names and edge cases.
- Bug fixes include regression tests where feasible.
- AI-generated code has been read, understood, and checked for hallucinated APIs.

## Reviewer Comment Convention

Use these prefixes exactly:

- `Blocker:` Must fix before merge.
- `Required:` Needs fix or linked decision before merge.
- `Nit:` Small non-blocking improvement.
- `Suggestion:` Optional improvement.
- `Q:` Question.
- `FYI:` Information only.
- `Praise:` Positive feedback.

Reviewer SLA:

- Hotfix: respond within 2 working hours.
- Feature/fix: respond within 1 working day.
- If overdue, ping directly or escalate to Tech Lead.

## Output Style When Reviewing

When producing a review, put findings first, ordered by severity. Include file and line references when available.

Use this format:

```text
Blocker: <issue> at <file>:<line>
Impact: <why this matters>
Fix: <specific action>
```

If no issues are found, say that explicitly and mention residual risks or tests not run.

## Quick Checklist

- Conventional commit messages.
- `[AI]` tag for AI-assisted commits.
- Complete MR description.
- AI Disclosure filled.
- MR <= 400 LOC unless justified; > 700 LOC must split except allowed exceptions.
- No debug statements.
- No hardcoded secrets.
- Input validation complete.
- No SQL injection risk.
- No sensitive data in logs.
- CI/CD passes.
- Unit tests exist for business logic.
- Coverage does not drop > 5%.
- Tests describe behavior and cover edge cases.
- Breaking changes declared and migration plan documented.
