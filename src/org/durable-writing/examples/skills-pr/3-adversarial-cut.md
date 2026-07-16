Two org-scope skills for react-lua UI: `org/write-react-code` for component structure and `org/use-foundation` for Foundation styling.

The one call worth a reviewer's attention: every example in both skills comes from Flipbook, the org's largest react-lua codebase, yet both are filed at `org/`, not `flipbook/`. The claim is that these are library-level react-lua and Foundation patterns rather than Flipbook's house style, so they should hold for any flipbook-labs repo that grows a UI. If that scope is wrong, the fix is to move them to `flipbook/`, not to rewrite them.
