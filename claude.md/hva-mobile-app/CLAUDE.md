# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Environment Setup
- `yarn install` - Install dependencies
- `yarn start` - Start development server with Tailwind CSS watching (concurrently runs Tailwind CSS compilation and Expo dev server)

### Development and Testing
- `yarn android` - Run on Android emulator/device
- `yarn ios` - Run on iOS simulator/device  
- `yarn web` - Run in web browser
- `yarn check-lint` - Run ESLint checks
- `yarn check-format` - Check Prettier formatting
- `yarn check-types` - Run TypeScript type checking
- `yarn format` - Format code with Prettier

### Build Commands
- `fastlane android firebase` - Build Android APK for staging and upload to Firebase
- `fastlane ios firebase` - Build iOS IPA for staging and upload to Firebase
- `fastlane android release` - Build production Android bundle (.aab)
- `fastlane ios release` - Build production iOS bundle (.ipa)

### Pre-build Commands
- `yarn prebuild-android` - Clean prebuild for Android platform
- `yarn prebuild-ios` - Clean prebuild for iOS platform

## Architecture Overview

### Technology Stack
- **Framework**: React Native with Expo SDK 53
- **Router**: Expo Router v5 with typed routes
- **State Management**: React Query (@tanstack/react-query) for server state, React Context for global state
- **Styling**: Tailwind CSS with custom React Native CSS package
- **Form Management**: React Hook Form with Zod validation
- **UI Components**: Custom UI kit in `src/uikit/` with reusable components
- **Internationalization**: i18next with react-i18next

### Project Structure
```
app/                    # Expo Router file-based routing
├── (app)/             # Main app routes (authenticated)
│   ├── (tabs)/        # Tab navigation structure
│   └── auth/          # Authentication flows
src/
├── components/        # Feature-specific components organized by domain
├── uikit/            # Reusable UI components and design system
├── infra/            # Infrastructure (API, i18n, logging, tracking)
├── utils/            # Utility functions and helpers
└── assets/           # Images, fonts, icons, locales
```

### Key Architectural Patterns

#### Component Organization
- Components are organized by feature domain (e.g., `auth/`, `home/`, `payments/`)
- Each feature folder contains:
  - `index.tsx` - Main component
  - `fetcher.ts` - Data fetching logic
  - `interface.ts` - TypeScript interfaces
  - `variables.ts` - Data related to the component (e.g., initial state, text mappings)
  - Subcomponents in nested folders

#### Data Fetching
- Uses React Query with custom `useFetcher` hook in `src/infra/fetch/`
- API requests go through interceptors for authentication and error handling
- Follows consistent patterns with `FetcherType` namespace for type safety

#### UI Kit Structure
- `src/uikit/core/` - Core UI components (Button, Input, Text, etc.)
- `src/uikit/components/` - Composite components
- `src/uikit/chart/` - Chart components
- All components follow consistent styling with Tailwind CSS

#### Authentication & Security
- JWT-based authentication with secure storage
- Biometric authentication (Face ID/Touch ID) support
- PIN code system for additional security
- OneSignal integration for push notifications

#### Environment Management
- Environment-specific configurations in `app.config.js`
- Staging and production build variants
- Environment variables for API endpoints and feature flags

### Multi-platform Considerations
- iOS and Android native build configurations
- Platform-specific permissions and entitlements
- Firebase integration for both platforms
- Fastlane configuration for automated builds

### Development Workflow
1. Use `yarn start` for development with hot reloading
2. Always run linting and type checking before commits
3. Use Fastlane commands for building platform-specific releases
4. Environment switching handled automatically by build scripts

## Important Notes
- This is a financial application with stringent security requirements
- Always follow security best practices when handling user data
- The app uses custom environment switching between dev/staging/production
- Tailwind CSS is compiled during development - ensure the start script is used
- The project uses yarn as the package manager (specified in package.json)
