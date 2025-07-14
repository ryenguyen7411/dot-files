# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Build and Development
- `yarn dev` - Start development server in standalone mode (port 3000)
- `yarn dev:mf` - Start in federated mode (builds and serves as micro-frontend)
- `yarn build` - Build the project for production
- `yarn preview` - Preview production build

### Code Quality
- `yarn check-types` - Run TypeScript type checking (also compiles types dependencies)
- `yarn check-lint` - Run ESLint to check for linting errors
- `yarn check-format` - Check code formatting with Prettier
- `yarn format` - Format code with Prettier

### Dependencies
- `yarn compile-types-deps` - Fetch and compile micro-frontend types from bizops-common and bizops-worker
- `yarn install` - Install dependencies and apply patches

## Architecture Overview

### Micro-Frontend Structure
This is a **micro-frontend application** using Module Federation that integrates with:
- `@be/bizops-common` - Shared UI components and utilities
- `@be/bizops-worker` - Worker services and APIs
- `@be/bizops-operation` - Business operations module

### Federation Configuration
- **Exposes**: `./index` (bootstrap) and `./information/oau` (OAU information module)
- **Remotes**: Consumes bizops-common, bizops-worker, and bizops-operation
- **Shared**: React, React Router, Redux Toolkit, and other common dependencies

### Key Directories
- `src/components/information/oau/` - OAU (Operational Audit Unit) information components
- `src/pages/information/oau/` - OAU page components
- `src/remoteEntry/` - Exposed remote entry points for other micro-frontends
- `mf-types/` - Auto-generated TypeScript types from federated modules

### Development Modes
1. **Standalone Mode** (`yarn dev`): For isolated development of this micro-app
2. **Federated Mode** (`yarn dev:mf`): For integration with other micro-frontends

### Environment Setup
- Copy `.env.example` to `.env.local`
- Update paths in both files to match your local bizops-common and bizops-worker locations
- Default setup assumes all projects in same parent directory

### Type Compilation
The `compile-types-deps.sh` script automatically:
- Fetches TypeScript definitions from bizops-common and bizops-worker
- Handles authentication via Puppeteer for remote environments
- Installs dependencies for fetched types

### Styling
- Uses Tailwind CSS v4
- CSS modules handled by Module Federation
- Styles injected based on federation mode (federated vs standalone)

### State Management
- Redux Toolkit for state management
- Shared Redux store configuration with other micro-frontends

### Routing
- React Router v6
- Main route: `/new/information/oau` for OAU information features
- Router notifications integrated with micro-frontend communication

## Important Notes

- Always run `yarn compile-types-deps` before type checking in development (it's automatic via `yarn precheck-types` and `yarn predev`)
- Use federated mode when developing alongside other bizops micro-apps
- Pre-commit hooks enforce formatting, linting, and type checking
- Follows conventional commit message format via commitlint
