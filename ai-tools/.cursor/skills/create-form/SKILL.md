---
name: create-form
description: Create a form with validation using react-hook-form and zod. Use when the user needs to build a form, add validation, or create input screens.
---

# Create Form

## Workflow

### Step 1: Create `schema.ts`

Define the zod schema, inferred type, and resolver:

```tsx
import { z, zodResolver } from "@/uikit/form";

const CreateAccountSchema = z.object({
  name: z.string().trim().min(1, "Tên không được để trống"),
  email: z.string().email("Email không hợp lệ"),
  phone_number: z.string().refine(
    (value) => /^(0[3|5|7|8|9])+\d{8}$/.test(value),
    "Số điện thoại không hợp lệ",
  ),
  birthday: z.string().refine(
    (val) => {
      const [, , year] = val.split("/").map(Number);
      if (!year) return false;
      return new Date().getFullYear() - year >= 18;
    },
    { message: "Phải đủ 18 tuổi trở lên" },
  ),
});

export type CreateAccountForm = z.infer<typeof CreateAccountSchema>;
export const CreateAccountResolver = zodResolver(CreateAccountSchema);
```

### Step 2: Build the form component

```tsx
import { useRouter } from "expo-router";
import { type CreateAccountForm, CreateAccountResolver } from "./schema";
import { useForm, Form, FormInput, FormDateInput, FormSelection } from "@/uikit/form";
import { showToast } from "@/uikit/core";

export const CreateAccountPage = () => {
  const router = useRouter();

  const form = useForm<CreateAccountForm>({
    resolver: CreateAccountResolver,
    defaultValues: {
      name: "",
      email: "",
      phone_number: "",
      birthday: "",
    },
  });

  const onSubmit = async (data: CreateAccountForm) => {
    const { data: result, error } = await createAccount(data);
    if (error) {
      showToast(error.message);
      return;
    }
    router.back();
  };

  return (
    <Form {...form} onSubmit={onSubmit} formClassName="px-4 gap-5" formScrollable>
      <FormInput name="name" label="Họ tên" />
      <FormInput name="email" label="Email" keyboardType="email-address" />
      <FormInput name="phone_number" label="Số điện thoại" keyboardType="phone-pad" />
      <FormDateInput name="birthday" label="Ngày sinh" />
    </Form>
  );
};
```

## Available Form Fields

- `FormInput` -- text input with label and error display
- `FormDateInput` -- date picker
- `FormSelection` -- dropdown/select with options
- `FormCalendar` -- calendar picker

## Rules

- Import `z` and `zodResolver` from `@/uikit/form` (not directly from zod)
- Error messages in Vietnamese by default
- Always provide `defaultValues` in `useForm`
- Use `formScrollable` prop on `<Form>` for scrollable forms
- Handle errors via `showToast` from `@/uikit/core`
