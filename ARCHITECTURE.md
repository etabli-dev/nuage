# Etabli Nuage — architecture

A single self-hosted **Nextcloud** account drives four modules. They share one
auth session, one secure-store credential entry, and one base URL; each module
owns its protocol and its UI tab.

## Shared core
- **Account/auth:** app-password (recommended) or login-flow v2 token, stored in
  Keychain (iOS) / EncryptedSharedPreferences (Android). One base URL.
- **Networking:** plain URLSession (iOS) / OkHttp (Android). No third-party SDKs.
- **Sync model:** per-module ETag / sync-token; no central server beyond the user's own.

## Modules
| Tab | Protocol | Endpoint | Carried over / new |
|-----|----------|----------|--------------------|
| Files | WebDAV | `/remote.php/dav/files/<user>/` | core of old EtabliProbe WebDAV client |
| Contacts | CardDAV | `/remote.php/dav/addressbooks/users/<user>/` | new — vCard 3/4 parse + write |
| Calendar | CalDAV | `/remote.php/dav/calendars/<user>/` | new — iCalendar VEVENT parse + write |
| Link Checker | HTTP + WebDAV | (any URLs) + log sync to Files | the original EtabliProbe feature, now one tab |

## Why one app, not four
Shared account + shared secure-store entry + shared network stack means the user
authenticates once and gets a coherent "my Nextcloud" surface. The link checker
stays because it already round-trips through WebDAV — it's a natural Files sibling.

## Build order (suggested)
1. Lift Files + Link Checker from EtabliProbe (already working).
2. Add CardDAV (Contacts) — simpler than CalDAV; good next step.
3. Add CalDAV (Calendar) — recurrence handling is the hard part.
4. Unify the four behind one account/onboarding flow.

## Naming / affiliation
"Nuage" (French: cloud) avoids using the Nextcloud trademark in the app name.
The README and store listing must state it is an unofficial client, not affiliated
with Nextcloud GmbH.
