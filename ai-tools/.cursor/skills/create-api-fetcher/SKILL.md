---
name: create-api-fetcher
description: Create data fetching hooks using the project's custom useFetcher pattern. Use when the user needs to add API calls, queries, mutations, or infinite queries.
---

# Create API Fetcher

## Workflow

### Step 1: Define response types

Add types to the feature's `interface.ts`:

```tsx
interface PoolDetailResponse {
  data: {
    poolId: number;
    poolName: string;
    poolNav: number;
  };
}
```

### Step 2: Create `fetcher.ts` in the feature directory

```tsx
import { type FetcherType, fetchFn, useFetcher } from "@/infra/fetch";
import { type PoolDetailResponse } from "./interface";
```

### Step 3: Implement hooks

**Query:**

```tsx
export const usePoolDetail = (poolId: number) => {
  return useFetcher({
    url: "/investpool/pools/#{poolId}/detail",
    params: { poolId },
    gw: "hva_v2",
    dataParser: (body: PoolDetailResponse) => body.data,
    queryOptions: {
      staleTime: 5 * 60 * 1000,
      enabled: poolId > 0,
    },
  });
};
```

**Mutation:**

```tsx
export const useDeposit = ({
  poolId,
  mutationOptions,
}: {
  poolId: number;
  mutationOptions: FetcherType.MutationOptions<DepositResponse>;
}) => {
  return useFetcher({
    type: "mutation",
    method: "POST",
    url: "/investpool/pools/#{poolId}/deposit-cash",
    params: { poolId },
    gw: "hva_v2",
    mutationOptions,
  });
};
```

**Infinite query:**

```tsx
export const useTransactionHistory = (limit: number) => {
  return useFetcher({
    type: "infinite_query",
    url: "/app/payment/history",
    query: { limit },
    initialPageParam: { page: 1 },
    queryOptions: {
      getNextPageParam: (lastPage, __, lastPageParam: { page: number }) => {
        if (lastPage.extra?.total <= lastPageParam.page * limit) return;
        return { page: lastPageParam.page + 1 };
      },
    },
  });
};
```

**Standalone fetch (non-hook, for one-off calls):**

```tsx
export const sendOtp = async () => {
  return await fetchFn({
    method: "POST",
    url: "/contract/otp",
    gw: "hva_v2",
    body: { method: "deposit" },
    dataParser: (body: OtpResponse) => body.data,
  });
};
```

## Key Rules

- URL params use `#{paramName}` syntax
- Always define `dataParser` to extract the payload
- Gateway (`gw`): `"hva"` (default), `"hva_v2"`, `"orionx"`, `"config"`, `"mofi"`
- Mutation options type: `FetcherType.MutationOptions<ResponseType>`
- Use `queryOptions.enabled` to conditionally run queries
- Use `queryOptions.staleTime` for cache duration
- Use `queryOptions.refetchInterval` for polling
