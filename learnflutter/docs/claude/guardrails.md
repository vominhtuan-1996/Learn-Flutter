# Guardrails — LearnFlutter

## Critical Constraints

### ❌ NEVER
1. **Commit secrets** — API keys, tokens, passwords, Firebase config
   - Keep in `.env` (gitignored)
   - Use environment variables or secure storage

2. **Hard-code user-facing strings** — All strings must support localization
   - Use `AppLocalizations.of(context)?.message` or equivalent
   - Add to `lib/l10n/app_localizations_*.dart`

3. **Import between features directly** — Creates circular dependencies
   - Always route through `core/` or `shared/`
   - Use named routes for navigation

4. **Store sensitive data in SharedPreferences** — Use flutter_secure_storage
   - Tokens, passwords, PII go to secure storage
   - SharedPreferences only for non-sensitive preferences

5. **Mock concrete classes** — Mock interfaces/abstractions instead
   - Depends on ApiClient class? Bad. Depends on UserRepository interface? Good.
   - Makes tests brittle and tightly coupled

6. **Ignore error states** — Always emit error states from Cubits
   - Don't fail silently or swallow exceptions
   - Users deserve feedback

7. **Modify Shorebird version** — Must match FVM version
   - FVM: 3.29.3
   - Shorebird: `--flutter-version=3.29.3`
   - Mismatch breaks OTA updates

8. **Use system `flutter` command** — Always use FVM
   - ❌ `flutter run`
   - ✅ `fvm flutter run`

9. **Commit large binary files** — Build artifacts, images, videos
   - Use asset management and compression
   - `.apk`, `.ipa`, images >1MB → check before committing

10. **Break existing APIs** — Always maintain backwards compatibility
    - Deprecate old methods before removing
    - Document breaking changes in PR
    - Consider migration path for users

## Architecture Guardrails

### State Management
- ✅ One feature = one Cubit (minimum)
- ✅ Global state = global Cubit (SettingCubit, BaseLoadingCubit)
- ✅ Immutable state classes with `@immutable` or `equatable`
- ✅ Emit states, never call setState
- ❌ StatefulWidget + Cubit for same state
- ❌ Cubit directly in build() method

### Dependency Injection
- ✅ Singleton services (ApiClient, KeyboardService, AppTalker)
- ✅ Inject via constructor
- ✅ Use GetIt if needed for service locator pattern
- ❌ Global variables (except GetIt instance)
- ❌ Access BuildContext in services

### Networking
- ✅ All API calls through ApiClient
- ✅ Domain models separate from DTOs
- ✅ Repositories abstract API calls
- ✅ Error mapping to domain exceptions
- ❌ Dio imported directly in features
- ❌ Parsing API responses in UI layer
- ❌ Raw exception types exposed to UI

### Testing
- ✅ Mock external dependencies
- ✅ Test public interfaces
- ✅ Use BlocTest for Cubits
- ✅ Separate concerns (unit/widget/integration)
- ❌ Test private methods
- ❌ Real API calls in unit tests
- ❌ Sleep/arbitrary delays in tests

### UI & Widgets
- ✅ Reusable widgets in `shared/`
- ✅ Feature-specific widgets in feature folder
- ✅ const constructors where possible
- ✅ BlocBuilder/BlocListener for state updates
- ❌ Animations blocking build()
- ❌ BuildContext stored in state
- ❌ Heavy computations in build()

## Code Quality Guardrails

### Null Safety
- ✅ Non-nullable by default
- ✅ `?` only for truly optional fields
- ✅ Null checks before use
- ❌ `!` operator (null assertion)
- ❌ Ignore null safety warnings

### Comments
- ✅ Comments explaining WHY
- ✅ Single-line comments for non-obvious logic
- ✅ Issue/PR references in commit messages
- ❌ Docstring clutter
- ❌ Comments restating code
- ❌ Block comments (`/* */`)

### Naming
- ✅ Clear, descriptive names
- ✅ PascalCase for classes, snake_case for files
- ✅ `*Cubit` suffix for state classes
- ✅ `*State` suffix for state definitions
- ✅ `_private` for private members
- ❌ Single-letter variables (except loops)
- ❌ Abbreviations (except well-known: API, URL, HTTP)
- ❌ Magic numbers/strings without constants

### Error Handling
- ✅ Specific exception types
- ✅ Error logging with context
- ✅ User-friendly error messages
- ✅ Retry logic for transient failures
- ❌ Bare `catch (e) {}`
- ❌ Swallowing exceptions
- ❌ Exposing stack traces to users

## Security Guardrails

### Authentication
- ✅ Tokens in secure storage
- ✅ Token refresh logic
- ✅ Auto-logout on 401
- ✅ Session timeout
- ❌ Tokens in SharedPreferences
- ❌ Hardcoded credentials

### Data Validation
- ✅ Validate all user input
- ✅ Validate API responses
- ✅ Whitelist allowed domains/URLs
- ✅ Regex validation for formats (email, phone, etc.)
- ❌ Trust user input
- ❌ Trust API responses blindly
- ❌ Dynamic URL loading without validation

### Network Security
- ✅ HTTPS only (in production)
- ✅ Certificate pinning (recommended)
- ✅ Request timeouts
- ✅ Encrypt sensitive local data
- ❌ HTTP endpoints
- ❌ Hardcoded API keys in code
- ❌ No timeout configuration

### Platform Integration
- ✅ Request permissions before use
- ✅ Handle permission denial gracefully
- ✅ Validate deep links
- ✅ Sanitize WebView content
- ❌ Assume permissions granted
- ❌ Load arbitrary WebView URLs
- ❌ Accept deep links without validation

## Performance Guardrails

### Build Optimization
- ✅ Lazy load features
- ✅ Use const constructors
- ✅ Profile before optimizing
- ✅ Monitor bundle size
- ❌ Rebuild entire tree on state change
- ❌ Premature optimization
- ❌ Ignore slow frames in Profile mode

### Memory Management
- ✅ Dispose subscriptions/streams
- ✅ Cancel timers/futures
- ✅ Close resources in tearDown()
- ✅ Use weak references for callbacks
- ❌ Memory leaks (listener not removed)
- ❌ Circular references
- ❌ Load entire datasets into memory

### Asset Management
- ✅ Compress images (WebP preferred)
- ✅ Responsive images for different densities
- ✅ Lazy load images
- ✅ Remove unused assets
- ❌ High-resolution PNGs
- ❌ Uncompressed videos
- ❌ Load large assets at startup

## Testing Guardrails

### Coverage
- ✅ Core logic: 80%+ coverage
- ✅ Repositories: 100% coverage
- ✅ Cubits: 100% coverage
- ✅ Utilities: 100% coverage
- ❌ UI-only code: < 40% coverage acceptable (hard to test)
- ❌ Skip testing infrastructure

### Test Quality
- ✅ Each test tests ONE thing
- ✅ Clear, descriptive test names
- ✅ AAA pattern (Arrange, Act, Assert)
- ✅ Independent, isolated tests
- ✅ Deterministic (same result every run)
- ❌ Flaky tests (timing-dependent)
- ❌ Tests that depend on execution order
- ❌ Over-mocking (mock only external deps)

## Git & Collaboration Guardrails

### Commits
- ✅ Atomic, logical commits
- ✅ Conventional commit format
- ✅ Descriptive messages
- ✅ Reference issues/PRs
- ✅ Sign commits (if configured)
- ❌ Merge commits (rebase instead)
- ❌ Commits with multiple unrelated changes
- ❌ Force push to main/shared branches

### Code Review
- ✅ Self-review before pushing
- ✅ Run formatter: `fvm dart format lib/`
- ✅ Run analyzer: `fvm flutter analyze`
- ✅ Run tests: `fvm flutter test`
- ✅ Keep PRs focused
- ❌ Merge failing tests
- ❌ Ignore linter warnings
- ❌ Commit TODOs without issues

## Documentation Guardrails

### Code Documentation
- ✅ Document complex algorithms
- ✅ Document non-obvious decisions
- ✅ Document assumptions
- ✅ Keep docs up-to-date
- ❌ Over-document obvious code
- ❌ Document stack traces
- ❌ Inline comments for every line

### Architecture Documentation
- ✅ Document design decisions
- ✅ Document trade-offs
- ✅ Update CLAUDE.md when architecture changes
- ✅ Link to external resources (pub.dev, docs)
- ❌ Assume implicit knowledge
- ❌ Store docs in code comments
- ❌ Let docs drift from reality

## Escalation Paths

### When in Doubt
1. **Code style:** Check `rules-coding.md`
2. **Architecture:** Check `rules-architecture.md`
3. **API design:** Check `rules-api.md`
4. **Security:** Check `rules-security.md`
5. **Testing:** Check `rules-testing.md`
6. **Database:** Check `rules-database.md`
7. **General:** Check `context-domain.md`

### Red Flags (Need Review)
- 🚩 Feature > 500 lines
- 🚩 Method > 50 lines
- 🚩 Cyclomatic complexity > 5
- 🚩 No tests for critical logic
- 🚩 Secrets in code
- 🚩 Direct feature imports
- 🚩 Mixing state patterns
- 🚩 Silent error handling

## Checklists

### Before Committing Code
- [ ] Ran `fvm dart format lib/`
- [ ] Ran `fvm flutter analyze` (no errors)
- [ ] Ran `fvm flutter test` (all passing)
- [ ] No hardcoded strings (i18n)
- [ ] No secrets in code
- [ ] No TODO/FIXME without issues
- [ ] Comments updated
- [ ] Commit message follows convention

### Before Creating PR
- [ ] Feature branch named descriptively
- [ ] Commit history is clean
- [ ] PR title is clear and concise
- [ ] PR description explains WHY (not just WHAT)
- [ ] References related issues
- [ ] Screenshots/videos if UI changes
- [ ] Tests included
- [ ] CHANGELOG updated (if applicable)

### Before Merging PR
- [ ] Code review completed
- [ ] All CI checks passing
- [ ] No merge conflicts
- [ ] Commit history squashed (if needed)
- [ ] Related documentation updated
- [ ] Breaking changes documented
- [ ] CLAUDE.md updated if architecture changed

## Emergency Procedures

### If You Committed Secrets
1. **Immediately:** Remove from next commit (don't rely on history)
2. **Rotate:** Change the secret (API keys, tokens, passwords)
3. **Scan:** Check git history: `git log -p | grep -i "secret"`
4. **Notify:** Tell team lead and security

### If You Merged Bad Code
1. **Revert immediately:** `git revert -m 1 <commit-hash>`
2. **Investigate:** What caused the merge?
3. **Fix:** Address root cause
4. **Remerge:** After fixes, re-commit

### If You Have Merge Conflicts
1. **Don't force resolve** — Review both changes
2. **Communicate** — Ask other contributor about intent
3. **Test** — Verify merged code still works
4. **Document** — Commit message explains resolution
