---
name: create-uikit-component
description: Create a new reusable UI kit component following the project's uikit conventions. Use when the user wants to add a new shared component to the design system.
---

# Create UIKit Component

## Workflow

### Step 1: Choose location

- `src/uikit/core/<name>/` -- core primitives (buttons, inputs, text, layout)
- `src/uikit/components/<name>/` -- specialized components (camera, OTP, charts)

### Step 2: Create the component

Create `src/uikit/core/<name>/index.tsx` (or `components/`):

```tsx
import cx from "clsx";
import React from "react";
import { View, type ViewProps } from "@/uikit/core/view";
import { Text } from "@/uikit/core/text";

interface CardProps {
  className?: string;
  title?: string;
  children: React.ReactNode;
}

export default function Card({ className, title, children }: CardProps) {
  return (
    <View className={cx("rounded-md bg-gray-25 p-4", className)}>
      {title && <Text className="mb-2 text-sm font-semibold">{title}</Text>}
      {children}
    </View>
  );
}
```

### Step 3: Add barrel export

Add the export to `src/uikit/core/index.ts`:

```tsx
export { default as Card } from "./card";
```

## Rules

- Use `export default function ComponentName` (default export)
- Define a TypeScript `interface` for all props
- Always accept a `className` prop and merge with `cx` from `clsx`
- Use `__combinedStyles` prop when applying `className` to raw React Native primitives (Pressable, etc.)
- Import sibling uikit components via relative paths (`@/uikit/core/view`), not the barrel
- Keep components focused -- one component per directory
