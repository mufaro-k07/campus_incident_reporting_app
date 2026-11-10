# Technical decisions and problems

A short log of the technical decisions made while building the app and the problems met along the way.

## Cubit for state management (2026-11-07)

I chose Cubit from `flutter_bloc` because it keeps the logic out of the widgets with fewer concepts than Riverpod or full Bloc. A Cubit has plain methods instead of events, which is easier to explain. If the app grew much larger, event-based Bloc could give better tracing of what happened.

## Cloudinary instead of Firebase Storage (2026-11-07)

Firebase Storage needs the paid Blaze plan, and I cannot link a card. The class representative approved using another cloud service, so photos go to Cloudinary through an unsigned upload preset and only the photo URL is saved in Firestore. Limitation: unsigned uploads cannot be deleted from the app, so deleting a report leaves its photo in Cloudinary.

## Client-side search (2026-11-07)

Firestore has no full-text search, so the app filters the incidents it has already loaded. This is fine for a small campus dataset. A large dataset would need a search service such as Algolia or Typesense.

## Roles in Firestore, enforced by security rules (2026-11-07)

Each user has a `role` field in `users/{uid}`. Everyone signs up as a student and staff are promoted manually in the Firebase Console. The security rules check this role, so hiding buttons in the UI is not the only protection.

## ALU emails and verification (2026-11-07)

Only `@alustudent.com` and `@alueducation.com` addresses can register, and the email must be verified before the app opens. `devAllowAnyEmail` and a separate dev rules file exist only for testing with a personal email. Both must be off for the demo.

## Emulator needed virtualisation (2026-11-07)

The Android emulator would not start until virtualisation was enabled in the BIOS. This cost setup time. Checking the BIOS setting first would have saved it.

## equatable 2 instead of 3 (2026-11-07)

`fake_cloud_firestore` (used in tests) only works with `equatable` below version 3 when used with `cloud_firestore` 7. I pinned `equatable` to `^2.1.0`. The parts of `equatable` the app uses are the same in both versions.

## Build failed because of a space in the Flutter path (2026-11-07)

The first build failed with "Building native assets failed". The Flutter SDK is in `C:\Users\Petros Kunze\flutter`, and the space in the path breaks a build step of the `objective_c` package. That package comes from `path_provider_foundation`, an iOS/macOS plugin pulled in by `google_fonts`. I pinned `path_provider_foundation` to 2.5.1, which does not use `objective_c`. Installing Flutter in a path without spaces (for example `C:\flutter`) would avoid this.

## google_fonts 8 instead of 9 (2026-11-07)

`google_fonts` 9 builds its text themes with the new `material_ui` package, so its `TextTheme` is a different type from the one `ThemeData` in Flutter 3.47 expects. The theme would not compile. I pinned `google_fonts` to `^8.2.1`, which uses Flutter's own `TextTheme`.

## Profile document is created after verification (2026-11-07)

CLAUDE.md says sign-up creates `users/{uid}`, but the security rules only let verified users write. So sign-up only creates the Auth account and sends the email. The profile document (role `student`) is created the first time a verified user opens the app. After "I have verified", the app also asks Firebase for a fresh ID token, because the rules read `email_verified` from the token and the old token still says false.

## Live role changes (2026-11-07)

`AuthCubit` listens to the user's Firestore document, not just the login state. When `role` is changed in the Firebase Console, the app switches between the student and staff screens straight away. This makes it possible to show both roles in the demo with one account.

## Security rules (2026-11-07)

`firestore.rules` is the strict version: only verified `@alustudent.com` and `@alueducation.com` accounts can read or write. Only staff can change `status`, `statusHistory` and `updatedAt`, checked with `diff().affectedKeys().hasOnly()`. A reporter can edit or delete their own report only while it is `submitted`, and nobody can change their own role. `firestore.dev.rules` is the same without the email domain check, and `firebase.dev.json` deploys it. I checked the deployed strict rules with 12 requests through the Firestore REST API (for example, a student changing a status gets 403 and a verified non-ALU account cannot read anything). All 12 gave the expected result.

## devAllowAnyEmail switched off (2026-11-07)

`devAllowAnyEmail` is now `false` and the strict rules are deployed. A non-ALU email now gets "Use your ALU email" on the login and sign-up forms, and the rules refuse it on the server even if the app check were skipped.

## Testing approach (2026-11-07)

Pure Dart code (validators, the filter function and the models) has plain unit tests. Cubits are tested with `bloc_test` and fake repositories from `mocktail`, so no network is needed. `IncidentRepository` is tested against `fake_cloud_firestore`, which also checks the status history update. The report form has a widget test. The security rules were checked against the real deployed database through the REST API, and every screen was tried on the Android emulator with a student account and a staff account.

## New colour palette (2026-11-07)

I replaced the teal and sand palette with royal blue (`#1A0088`), tangerine (`#FF5E32`), lime (`#B6CF4F`) and cream (`#EFE7D4`). Royal blue is the main colour because white text on it is easy to read. White text on tangerine is only about 3:1 and on lime below 2:1, so text on those colours is royal blue or black, and the raised Report button keeps only a white icon. The error colour (`#B3261E`) is kept outside the palette so an error never looks like a tangerine highlight. Because every colour lives in `app_colors.dart`, the change only touched the colour tokens and a few widgets, not every screen.

## Alerts tab and balanced bottom bar (2026-11-07)

The student bottom bar now has four items, two on each side of the Report button: Home and Reports, then Alerts and Profile. Every item has the same fixed width and the Row uses `spaceBetween`, so the Report button sits exactly in the centre. Tabs are an enum (`StudentTab`) instead of plain numbers, so `_selectTab(StudentTab.alerts)` reads better than `_selectTab(2)`. Alerts are built on the phone from the `statusHistory` of my own reports, because push notifications would need Cloud Functions, which need the paid Blaze plan.

## Dashboard showed only my own report (2026-11-10)

After I switched my account from student to staff, the staff Dashboard listed only my one report, while its summary card said 10. The All | Mine filter lives in `IncidentsCubit`, which the Reports tab and the Dashboard share, and "See all" on the student Home turns Mine on. The cubit was kept when only the role changed, because its key in `AuthGate` was just the uid, and the Dashboard has no switch to turn Mine off. Now the key also includes the role, so a role change starts with fresh filters, and the Dashboard uses `allMatchingIncidents`, which ignores Mine. Lesson: when two screens share one filter state, check that each screen can see and undo that filter.
