# Domain Knowledge — LearnFlutter

## Project Purpose

**LearnFlutter** is a comprehensive learning application that demonstrates 68+ Flutter patterns, UI components, and platform integrations. It serves as:

1. **Educational resource** — Examples of Flutter best practices
2. **Feature exploration** — Testing new libraries and patterns
3. **Production reference** — Shows how to build scalable, maintainable Flutter apps
4. **Sandbox environment** — Safe space to experiment with new technologies

The app is not intended for production use but as a learning tool and architectural reference.

## Target Users

- **Flutter developers** learning advanced patterns and libraries
- **Teams** setting up architecture standards
- **Developers** exploring specific Flutter features

## Core Features by Category

### State Management
- **BLoC/Cubit pattern:** LoginCubit, SettingCubit, HomeAnimationCubit
- **Riverpod:** Functional reactive state management
- **Global state:** Theme, keyboard, loading overlay

### Networking
- **API Integration:** ApiClient (Dio), UserRepository
- **Offline support:** NetworkQueueService for offline request buffering
- **Error handling:** Domain-specific exception hierarchy

### Local Storage
- **SharedPreferences:** User preferences, tokens (in demo; use secure storage in prod)
- **Hive:** NoSQL local database examples
- **SQLite:** Relational database examples

### UI/UX
- **Animations:** flutter_animate, custom animations
- **Loading states:** Skeleton loaders, progress indicators
- **Custom widgets:** Reusable components (buttons, inputs, containers)
- **Responsive design:** flutter_screenutil for different screen sizes

### Media & Sensors
- **Camera:** Camera access, QR scanning
- **Photo/video:** image_picker, video_player
- **Sensors:** Accelerometer, gyroscope data
- **Maps:** Google Maps + Leaflet (open-source alternative)
- **3D:** Flutter 3D controller, Flame game engine

### Background & Notifications
- **Task scheduling:** Workmanager for background tasks
- **Local notifications:** flutter_local_notifications
- **Event system:** notification_center for app-wide events

### Localization
- **Multi-language:** Vietnamese, English
- **Dynamic locale switching:** Runtime language change

### OTA Updates
- **Shorebird integration:** Over-the-air code push
- **Auto-update checks:** ShorebirdService singleton
- **Graceful restart:** Automatic app restart prompt

## Architecture Decisions

### Why Feature-Module Architecture?
- **Scalability:** Features grow independently
- **Testability:** Isolated feature testing
- **Team collaboration:** Multiple teams can work on different features
- **Reusability:** Core code shared across features

### Why Cubit over BLoC?
- **Simpler API:** Less boilerplate than BLoC
- **State as first-class citizen:** Easier to reason about state
- **Consistent patterns:** All features follow same structure
- **Easier testing:** BlocTest makes unit testing straightforward

### Why Repository Pattern?
- **Data abstraction:** Decouples UI from data source
- **Testing:** Easy to mock repositories
- **Flexibility:** Can swap implementations (API ↔ local cache)
- **Separation of concerns:** Business logic separate from data access

### Why Riverpod Coexists with Cubit?
- **Different paradigms:** BLoC for feature state, Riverpod for functional/provider-based
- **Flexibility:** Choose right tool for each use case
- **Learning:** Demonstrates both modern patterns
- **Gradual migration:** Can adopt Riverpod incrementally

## Known Limitations & Trade-offs

### Code Generation
- **No Freezed:** Uses `equatable` instead for value equality
- **No code_gen:** Hive adapters generated manually (`fvm flutter pub run build_runner build`)
- **Trade-off:** Less boilerplate but more manual model updates

### Localization
- **flutter_localization:** Simpler than intl + ARB
- **Manual translation files:** No automatic key extraction
- **Trade-off:** Easier setup but requires discipline for consistency

### Storage
- **SharedPreferences for tokens (demo only):** Use flutter_secure_storage in production
- **No encryption by default:** Hive encryption requires manual setup
- **Trade-off:** Quick setup for learning, but security considerations for production

### Testing
- **Mockito for mocking:** Works well for DI and abstraction-based design
- **No FakeRestClient in main app:** Only in test utilities
- **Trade-off:** Simple setup but requires well-designed interfaces

## Lessons Learned

### ✅ What Works Well
1. **Feature modules with Cubit:** Clear separation, easy to test
2. **ApiClient singleton:** Consistent HTTP handling across app
3. **Repository abstraction:** Enables offline-first caching
4. **Global Cubits:** Keyboard, theme, loading state
5. **Keyboard height tracking:** GlobalNoKeyboardRebuild prevents rebuilds
6. **Workmanager:** Reliable background task scheduling
7. **Shorebird OTA:** Seamless code updates without app store

### ⚠️ Common Pitfalls
1. **Mixed state management:** Cubit + StatefulWidget in same widget
2. **Too many global Cubits:** Can lead to prop drilling issues
3. **Tight coupling to ApiClient:** Always use repository abstraction
4. **Storing sensitive data in SharedPreferences:** Use secure storage
5. **Ignoring error states:** Always emit error states, don't fail silently
6. **Testing implementation instead of behavior:** Mock interfaces, not classes

## Performance Considerations

### Build Time
- **Multiple entry points:** Different main_*.dart files (slower to compile)
- **Mitigation:** Use default main.dart for development, specific targets for testing

### Runtime Performance
- **68 features:** Can slow down initial app load if all initialized eagerly
- **Mitigation:** Lazy-load features, use GetIt for deferred singletons

### Memory
- **Many packages:** Large app size (50MB+ debug APK)
- **Mitigation:** Use code splitting, remove unused features before production build

## Security Considerations

### Current State
- **No encryption:** Tokens stored in SharedPreferences (demo only)
- **No certificate pinning:** API calls unprotected against MITM
- **Limited input validation:** Basic validation in UI layer

### Production Recommendations
- **Use flutter_secure_storage** for tokens and secrets
- **Implement certificate pinning** for API calls
- **Add server-side rate limiting** for auth endpoints
- **Use HTTPS only** (already configured)
- **Validate all user input** at system boundaries

## Scalability Path

### For Enterprise
1. **Replace SharedPreferences:** Use flutter_secure_storage
2. **Add encryption:** Hive with encryption cipher
3. **Implement caching layer:** Redis/Memcached backend
4. **API versioning:** Support multiple API versions
5. **Feature flags:** Control feature rollout
6. **Analytics:** Track user behavior and performance

### For Performance
1. **Code splitting:** Separate heavy features into dynamic imports
2. **Lazy loading:** Load features on-demand
3. **Offline-first:** More aggressive caching
4. **Background sync:** Sync data when connectivity returns
5. **Image optimization:** WebP format, adaptive sizing

## Common Questions

**Q: Can I use this code in production?**
A: Yes, but audit security (encryption, cert pinning, input validation) and remove unused features.

**Q: Should I use all 68 features?**
A: No. Pick features relevant to your domain. Others are educational examples only.

**Q: How do I add a new feature?**
A: Create `lib/features/[feature_name]/` directory with `cubit/`, `state/`, `screens/` structure.

**Q: Why are there multiple main_*.dart files?**
A: Each demonstrates a different feature or pattern. Default is `main.dart`.

**Q: When should I use Cubit vs Riverpod?**
A: Cubit for feature state, Riverpod for functional/provider patterns or global state.

**Q: How do I test API calls?**
A: Mock ApiClient in repositories, use FakeRestClient for offline testing.
