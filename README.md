# arkenfox-override-recipes
A personalized `user-overrides.js` recipe that balances usability and privacy - and in some cases, **even hardens settings further than the default arkenfox `user.js`**.

This repository complements the [arkenfox/user.js](https://github.com/arkenfox/user.js) project by maintaining a curated set of overrides tailored to real-world usage scenarios. While the `arkenfox user.js` provides an excellent privacy-focused baseline, some of its hardened defaults may hinder functionality for specific workflows or websites. Conversely, in areas where usability degradation is acceptable, this override set **further tightens** security and privacy protections.

## Purpose
- Restore expected functionality for essential web features, extensions, or UI behavior (e.g., container tabs, keyboard shortcut consistency)
- Refine DNS and WebRTC behavior with vetted third-party services and hardening tweaks
- Enforce stricter anti-fingerprinting settings when they show negligible breakage
- Provide reproducible, modular, and documented overrides for managing Firefox updates cleanly

## Usage
1. Set up your Firefox profile using the latest [arkenfox/user.js](https://github.com/arkenfox/user.js).
2. Copy this repo's [`user-overrides.js`](/user-overrides.js) into your Firefox profile directory (same directory as `prefs.js`).
3. Run the arkenfox updater script - your overrides will be appended automatically.

🔒 **Note**: You are responsible for understanding the privacy implications of each override. Review them carefully and adapt to your own threat model.

## Highlights
- Usability restores:
  - homepage on startup
  - Firefox Home for new windows and tabs
  - enabling UNC(Uniform Naming Convention) paths
  - setting OCSP fetch failures to soft-fail to avoid breakage
- Selective hardening:
  - setting external links to open in site-specific containers (depending on container extension(s) and their settings)
  - stricter WebRTC ICE candidate filtering (forcing exclusion of private IPs from ICE candidates, may results in breakage on video-conferencing platforms)
  - disabling websites overriding Firefox's keyboard shortcuts
  - enabling RFP
  - forced English spoofing under RFP
  - disabling visited link styling
  - disabling rememberSignons - use a password manager like Bitwarden instead
  - forcing any permission changes to be session only
  - disabling location bar history suggestion
- Enhanced control:
  - container tab usability: setting behavior on "+ Tab" button to display container menu on left click
  - enabling third-party DNS-over-HTTPS provider(Control D) with filtering

## Disclaimer
This repository is maintained independently of the official arkenfox project. Use at your own discretion, and always test changes against your own browsing needs and threat model.