# GitHub Pages Deployment Plan

Deploy the `web/` directory (Astro/Starlight documentation) to GitHub Pages at `https://rubiconetic.github.io/skill-bridge/`.

## User Review Required

> [!IMPORTANT]
> This plan involves adding a GitHub Action. You will need to ensure that the repository settings allow GitHub Actions to write to the repository (standard for Pages).

## Proposed Changes

### [web]

Astro configuration is already set for subpath deployment in `astro.config.mjs`.

### [CI/CD]

Add deployment automation.

#### [NEW] [deploy.yml](file:///home/michael/projects/skill-bridge/.github/workflows/deploy.yml)

- Triggers on push to `main`
- Setup Node.js and dependencies
- Build Astro site in `web/`
- Deploy to GitHub Pages using `actions/deploy-pages`

## Verification Plan

### Automated Tests

- `npm run build` in `web/` to ensure static artifacts generate correctly.

### Manual Verification

1. Push changes to GitHub.
2. Monitor GitHub Actions "Actions" tab.
3. Verify site loads at `https://rubiconetic.github.io/skill-bridge/`.
