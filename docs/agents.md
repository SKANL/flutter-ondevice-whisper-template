# Very Good Architecture Rules for Code Agents

> Rules for AI code agents working on Flutter projects using Very Good CLI architecture and feature-first structure.

## Project Structure

### Feature-First Organization

```
lib/
├── app/                    # App configuration and bootstrap
│   ├── app.dart
│   └── view/
│       └── app.dart
├── l10n/                   # Localization
│   └── arb/
│       ├── app_en.arb
│       └── app_es.arb
├── <feature_name>/         # Each feature in its own directory
│   ├── <feature_name>.dart # Barrel file (exports all public APIs)
│   ├── cubit/              # State management
│   │   ├── <feature>_cubit.dart
│   │   └── <feature>_state.dart
│   ├── view/               # UI components
│   │   └── <feature>_page.dart
│   ├── widgets/            # Feature-specific widgets
│   └── data/               # Repositories and data sources
│       └── <feature>_repository.dart
└── shared/                 # Shared utilities across features
    ├── widgets/
    └── constants/
```

### Rules

1. **Features are independent** - Each feature should work in isolation. Avoid cross-feature imports.
2. **Use barrel files** - Every feature MUST have a `<feature_name>.dart` barrel file exporting public APIs.
3. **Never import implementation details** - Only import from barrel files, never from internal paths.

---

## State Management with Bloc/Cubit

### When to Use Cubit vs Bloc

| Use Case                                 | Choice  |
| ---------------------------------------- | ------- |
| Simple state changes (increment, toggle) | `Cubit` |
| Complex event sequences                  | `Bloc`  |
| Need event traceability                  | `Bloc`  |
| Rapid prototyping                        | `Cubit` |

### State Classes with Sealed Classes (Dart 3+)

**ALWAYS use sealed classes for type-safe state:**

```dart
sealed class FeatureState {
  const FeatureState();
}

final class FeatureInitial extends FeatureState {
  const FeatureInitial();
}

final class FeatureLoading extends FeatureState {
  const FeatureLoading();
}

final class FeatureLoaded extends FeatureState {
  const FeatureLoaded({required this.data});
  final List<Item> data;
}

final class FeatureError extends FeatureState {
  const FeatureError({required this.message});
  final String message;
}
```

### State Pattern Matching in UI (Dart 3+)

**Use switch expressions for exhaustive state handling:**

```dart
@override
Widget build(BuildContext context) {
  return BlocBuilder<FeatureCubit, FeatureState>(
    builder: (context, state) {
      return switch (state) {
        FeatureInitial() => const SizedBox.shrink(),
        FeatureLoading() => const CircularProgressIndicator(),
        FeatureLoaded(:final data) => ListView.builder(
          itemCount: data.length,
          itemBuilder: (_, i) => ListTile(title: Text(data[i].name)),
        ),
        FeatureError(:final message) => Text('Error: $message'),
      };
    },
  );
}
```

### Cubit Naming Conventions

| Component   | Pattern                | Example                     |
| ----------- | ---------------------- | --------------------------- |
| Cubit class | `<Feature>Cubit`       | `AuthenticationCubit`       |
| State file  | `<feature>_state.dart` | `authentication_state.dart` |
| Cubit file  | `<feature>_cubit.dart` | `authentication_cubit.dart` |

---

## Page/View Pattern

### Structure

Every feature page MUST follow the Page/View pattern:

```dart
// <feature>_page.dart

/// Page: Provides dependencies (Cubit/Bloc)
class FeaturePage extends StatelessWidget {
  const FeaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FeatureCubit(
        repository: context.read<FeatureRepository>(),
      )..initialize(),
      child: const FeatureView(),
    );
  }
}

/// View: Builds the UI, no business logic
class FeatureView extends StatelessWidget {
  const FeatureView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.featureTitle)),
      body: const _FeatureBody(),
    );
  }
}
```

**Rules:**

1. `Page` creates and provides `Cubit/Bloc` via `BlocProvider`
2. `View` builds the UI and reads state via `BlocBuilder`
3. Never mix dependency injection with UI logic

---

## Dependency Injection

### Use RepositoryProvider at App Level

```dart
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => DataRepository(dio: Dio())),
      ],
      child: const MaterialApp(home: HomePage()),
    );
  }
}
```

### Access Repositories in Features

```dart
// In Page widget
BlocProvider(
  create: (context) => FeatureCubit(
    repository: context.read<FeatureRepository>(),
  ),
  child: const FeatureView(),
);
```

---

## Context Extensions

### ALWAYS Use Context Extensions Over BlocProvider.of

```dart
// ✅ CORRECT
context.read<AuthCubit>().login();
context.watch<AuthCubit>().state;
context.select<AuthCubit, bool>((c) => c.state.isLoading);

// ❌ WRONG
BlocProvider.of<AuthCubit>(context).login();
```

### Optimize Rebuilds with select()

```dart
// ✅ Only rebuilds when isLoading changes
final isLoading = context.select<FeatureCubit, bool>(
  (cubit) => cubit.state is FeatureLoading,
);

// ❌ Rebuilds on ANY state change
final state = context.watch<FeatureCubit>().state;
```

---

## Localization

### Always Use l10n for User-Facing Strings

```dart
// ✅ CORRECT
Text(context.l10n.welcomeMessage)

// ❌ WRONG - hardcoded string
Text('Welcome!')
```

### ARB File Format

```json
// app_en.arb
{
  "@@locale": "en",
  "featureTitle": "My Feature",
  "@featureTitle": {
    "description": "Title for the feature page"
  },
  "itemCount": "{count} items",
  "@itemCount": {
    "placeholders": {
      "count": { "type": "int" }
    }
  }
}
```

---

## Testing Requirements

### Test File Structure

```
test/
├── app/
│   └── view/
│       └── app_test.dart
├── <feature>/
│   ├── cubit/
│   │   └── <feature>_cubit_test.dart
│   └── view/
│       └── <feature>_page_test.dart
└── helpers/
    └── pump_app.dart
```

### Use blocTest for Cubit/Bloc Testing

```dart
blocTest<FeatureCubit, FeatureState>(
  'emits [Loading, Loaded] when fetch succeeds',
  build: () {
    when(() => repository.fetch()).thenAnswer((_) async => data);
    return FeatureCubit(repository: repository);
  },
  act: (cubit) => cubit.fetch(),
  expect: () => [
    const FeatureLoading(),
    FeatureLoaded(data: data),
  ],
);
```

---

## HTTP Requests

### Use Dio for HTTP Clients

```dart
// ✅ CORRECT
final dio = Dio();
final response = await dio.get('/endpoint');

// ❌ WRONG - don't use http package directly
import 'package:http/http.dart' as http;
```

---

## File Naming Conventions

| Type           | Pattern                     | Example                          |
| -------------- | --------------------------- | -------------------------------- |
| Feature barrel | `<feature>.dart`            | `authentication.dart`            |
| Cubit          | `<feature>_cubit.dart`      | `authentication_cubit.dart`      |
| State          | `<feature>_state.dart`      | `authentication_state.dart`      |
| Page           | `<feature>_page.dart`       | `authentication_page.dart`       |
| Repository     | `<feature>_repository.dart` | `authentication_repository.dart` |
| Widget         | `<widget_name>.dart`        | `login_button.dart`              |

---

## Analysis and Formatting

### Run Before Committing

```bash
# Format code
dart format .

# Analyze for issues
flutter analyze

# Apply automatic fixes
dart fix --apply

# Run tests
flutter test
```

### Use very_good_analysis

```yaml
# analysis_options.yaml
include: package:very_good_analysis/analysis_options.yaml
```

---

## Summary Checklist

- [ ] Feature in its own directory with barrel file
- [ ] Sealed classes for states
- [ ] Switch expressions for state handling
- [ ] Page/View pattern for pages
- [ ] RepositoryProvider for DI
- [ ] context.read/watch/select (not BlocProvider.of)
- [ ] All strings via l10n
- [ ] Tests for Cubit and Pages
- [ ] Dio for HTTP (not http package)
- [ ] flutter analyze passes
