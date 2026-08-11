# Git hooks

Git does not version `.git/hooks`, so the working copy of each hook lives here
and is linked into place once per clone:

```sh
ln -sf ../../tool/hooks/pre-push .git/hooks/pre-push
```

A symlink rather than a copy: editing the versioned file then takes effect
without anyone remembering to re-install it.

## `pre-push`

Three gates before every push, in order:

1. **Bumps the build number** in `pubspec.yaml` when the local one is not ahead
   of `origin/main`, commits it, and **stops the push**. This is not a failure
   — run `git push` again and it goes through. A pre-push hook runs after git
   has already resolved which commits to send, so committing here would leave
   the bump behind, silently one push out of date.
2. **Regenerates** the freezed/json_serializable code.
3. **Runs `flutter analyze`.** CI no longer does, so this is the only gate.

The build number reaches the About screen through `tool/build_web.sh`, and
`web/index.html` polls `version.json` to reload an installed PWA when it
changes — so the bump is what tells a suspended app that a new build exists.
