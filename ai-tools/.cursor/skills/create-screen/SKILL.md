---
name: create-screen
description: Create a new Expo Router screen with the standard pattern. Use when the user wants to add a new page, screen, or route to the mobile app.
---

# Create Screen

## Workflow

### Step 1: Determine route placement

Ask the user where the screen should live in the route hierarchy:

- `app/auth/` -- authentication screens (sign-in, register, etc.)
- `app/(app)/(tabs)/` -- main tab screens
- `app/(app)/` -- general app screens (most common)
- `app/(app)/<feature>/` -- feature-specific screens

### Step 2: Create the route file

Create the screen file in `app/` as a thin wrapper:

```tsx
import { useLocalSearchParams } from "expo-router";
import { FeatureComponent } from "@/components/feature-name";
import { KeyboardAvoidingView, NavigationBar, SafeAreaView } from "@/uikit/core";

export default function Page() {
  const { id } = useLocalSearchParams<{ id: string }>();

  return (
    <SafeAreaView className="page">
      <NavigationBar title="Screen Title" />
      <KeyboardAvoidingView>
        <FeatureComponent id={Number(id)} />
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}
```

- Use `KeyboardAvoidingView` only if the screen contains inputs
- Dynamic routes use bracket syntax: `[id].tsx`, `[category]/buy.tsx`

### Step 3: Create the feature component

Create the feature directory in `src/components/<feature>/`:

```
src/components/<feature>/
├── index.tsx       # Main component (named export)
├── fetcher.ts      # Data fetching hooks (if API calls needed)
├── schema.ts       # Zod form schema (if form needed)
├── interface.ts    # TypeScript types (if complex types needed)
└── variables.ts    # Constants (if needed)
```

The main component uses a named export:

```tsx
export const FeatureComponent = ({ id }: { id: number }) => {
  const router = useRouter();
  const { data, isLoading } = useFeatureData(id);

  return (
    <ScrollView>
      <View className="gap-4 px-4">
        {/* Component content */}
      </View>
    </ScrollView>
  );
};
```

### Step 4: Add i18n keys (if needed)

Add translation keys to `src/assets/locales/vi.json` and `src/assets/locales/en.json`.

### Step 5: Run quality checks

Run `yarn check-format`, `yarn check-types`, `yarn check-lint` and fix any issues.
