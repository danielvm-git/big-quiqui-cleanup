# Releasing

## Version ladder

The release tag is the only source of the version. `game/project.godot` keeps `0.0.0` and so does the export preset;
`scripts/export_ios.sh` writes the tag's version into a temporary copy of the preset (`scripts/version.sh`).

| Version | When |
|---|---|
| `v0.N.0` | each finished slice or epic (a `feat:` commit merged to `main`) |
| `v0.N.M` | fixes between slices (a `fix:` commit) |
| `v1.0.0` | the first store build, tagged on purpose by the owner (`feat!:` or a `Release-As` footer) |

big-release creates the tag and the GitHub Release from the commit types on every merge to `main` (`.big-release.yml`).

## iOS build

```bash
git fetch --tags
bash scripts/export_ios.sh        # unsigned Xcode project in build/ios
```

Needs the Godot 4.7 export templates. The result opens in Xcode, where the owner chooses the team, signs, archives and
uploads. Signing material never enters the repository: `scripts/check_export.sh` (part of preflight) fails on a real team id,
a provisioning profile, a signing identity or a tracked certificate. To bake your team id into an export without
committing it, set `QQ_APPLE_TEAM_ID` in the environment.

The CI export job runs in parallel with the release job, so its artifact carries the previous tag as the version. The real
store build is exported by the owner from a fetched tag. `application/version` (the build number) is `<tag>.<commit count>`,
which rises with every commit, as App Store Connect requires. Do not submit while the bundle id below is still the placeholder.

The bundle id `com.danielvm.quiqui.cleanup` is a placeholder; change it in `game/export_presets.cfg`.

## What the owner still has to do

- Apple Developer account, App ID, signing and provisioning.
- App Store Connect record, store listing, screenshots, privacy answers (the game collects nothing).
- Real app icon and launch art (the icon is a generated placeholder, see `scripts/make_icon.py`).
- Recorded voice and final art (slice S4 leftovers).
