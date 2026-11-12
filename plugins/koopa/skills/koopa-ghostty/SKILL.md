---
name: koopa-ghostty
description: >-
  Troubleshoot Ghostty directory-access failures caused by macOS privacy
  permissions. Use when Ghostty reports Permission denied, code 13, or cannot
  list a Documents or cloud-synced directory that other apps can access.
---

# Ghostty on macOS

## Directory access and privacy permissions

macOS app privacy permissions are distinct from Unix ownership and mode bits.
A shell can enter a directory while a listing command cannot enumerate it.
An error such as the following is a reason to check app privacy permissions,
not proof that the directory needs `chmod`:

```text
Permission denied: . - code: 13

Skipped 1 directories due to permission denied:
  .
```

### Least-privilege troubleshooting

1. Open **System Settings > Privacy & Security > Files & Folders** and expand
   **Ghostty**.
2. Check the permission matching the storage provider or protected folder.
   For a cloud-backed location, enable the relevant provider under Ghostty.
   Do not assume a path under Documents needs a separate Documents toggle;
   enable that toggle only if it is the relevant entry shown.
3. Retest. If the change has not taken effect, quit Ghostty completely with
   **Command-Q**, reopen it, and retest. Opening another tab is not a full quit.
4. In Ghostty, enter the affected directory and run:

   ```sh
   /bin/ls . >/dev/null && printf 'Directory access works\n'
   l
   ```

   The first command tests directory enumeration without printing filenames.
   If it succeeds but `l` fails, run `type l` to identify the alias, function,
   or executable, then investigate that command rather than broadening access.
5. If access still fails, inspect ownership, ACLs, and flags without modifying
   them, using `/bin/ls -ldeO .` in Ghostty. If narrow privacy permissions are
   unavailable or insufficient, discuss **Full Disk Access** as a broader
   fallback, not the default fix. After enabling it for Ghostty, fully quit
   and reopen the app before testing.

## Gotchas

- Enabling the cloud provider under Ghostty's Files & Folders entry can restore
  directory listing for a provider-backed folder reached through Documents.
  Full Disk Access and Unix permission changes are not necessarily needed.
- Confirm the permission under Ghostty's own Files & Folders entry. Permission
  granted to another app does not establish Ghostty's access.
- Desktop or Downloads access does not establish access to another protected
  folder or file provider. Inspect the actual entries shown.
- A direnv loading message alone does not establish that direnv caused the
  failure.
- Do not recommend `sudo`, recursive `chmod`, or recursive `chown` to bypass
  macOS privacy controls. They can alter valid permissions without fixing the
  app's privacy authorization.
- Do not reset privacy permissions with `tccutil` as an initial fix. It changes
  authorization state and requires an explicit, separately justified decision.
- Test in Ghostty itself. Success in another terminal or an editor's agent
  process does not verify Ghostty's app-specific access.
- Do not read or print directory contents merely to diagnose permissions.
