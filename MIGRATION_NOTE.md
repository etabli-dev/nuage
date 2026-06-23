# Etabli Nuage — migration & scaffolding note

This repo is the **expansion of EtabliProbe** into a full Nextcloud client.

## Migrates from EtabliProbe (already working)
- **Files module** ← the WebDAV client (PROPFIND/GET/PUT/MKCOL).
- **Link Checker module** ← the CSV URL checker + WebDAV log sync.

After migrate.sh runs, old Probe code lands in ios/ and android/. Reorganize it so
those two features become two tabs, not the whole app.

## NEW — must be built (not in old source)
- **Contacts (CardDAV):** vCard 3/4 against /remote.php/dav/addressbooks/users/<user>/
- **Calendar (CalDAV):** iCalendar VEVENT against /remote.php/dav/calendars/<user>/ (RRULE is the hard part)
- **Unified onboarding:** one login (app-password or login-flow v2), shared across modules.

See ARCHITECTURE.md for the endpoint map and build order.

## Status honesty
Keep it "in development" until Contacts + Calendar ship. Don't advertise CalDAV/CardDAV
on the store page until they work — silent sync failures erode trust fast.
