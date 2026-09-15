# Before and After Video

Use matched footage when a real prior revision reproduces the visual behavior. The comparison is evidence only when the revision is the meaningful variable.

## Establish the pair

Identify the last known affected revision and the candidate fixed revision. Keep them in separate worktrees, build directories, browser profiles, or equivalent isolated environments when shared state could leak between them. Record the exact revision and build identity for each clip.

If reproduction depends on a globally installed plugin, extension, application bundle, or cached build, capture one revision at a time. Verify the installed artifact's identity before recording, then restore the active development artifact when the pair is complete. A source checkout does not prove which artifact the application loaded.

If no authentic affected revision exists, make one after-only clip. You may use an illustrative scenario to show the feature, but label it Illustrative and do not call it Before.

## Freeze the comparison protocol

Define one protocol and apply it to both revisions:

- Same fixture, story, route, document, or data set.
- Same control values and initial application state.
- Same viewport dimensions, content scale, crop, and visual theme.
- Same virtual-input coordinates or target-relative input path.
- Same interaction order, delays, recording lead-in, and ending hold.

Prefer target-relative coordinates derived from current element or viewport geometry. Absolute desktop coordinates break across displays, scale factors, window positions, and operating systems.

## Record with virtual input

Use the narrowest input capability the product exposes. Prefer application or engine input APIs, then browser or accessibility automation that can target the surface without taking over the user's physical pointer. Do not move the user's real mouse unless the user explicitly authorizes it for that capture.

Hover footage must place the virtual pointer over the actual scrollable or interactive content and hold it long enough for delayed affordances to appear. Ensure the fixture contains enough content to trigger the behavior. If virtual input is invisible in the recording, render a synchronized in-surface marker whose coordinates come from the same input sequence. The marker shows where the agent is acting; it is not a claim that the application rendered a native cursor.

Capture a live foreground surface when accelerated or plugin-hosted UI stops repainting under background capture. Before recording the full pair, make a short probe and inspect multiple frames to confirm the UI changes over time.

## Verify the comparison

For each output:

1. Probe dimensions, duration, frame rate, and streams.
2. Decode the entire file successfully.
3. Inspect frames before, during, and after the interaction.
4. Confirm the expected visible behavior for that revision.
5. Confirm that framing and timing match the other clip closely enough for direct comparison.

Review the final encodes side by side. A cursor moving over unchanged pixels is evidence of pointer motion, not application behavior. A contact sheet or sampled-frame comparison can reveal a frozen capture before upload.

## Present the result

Attach two short clips labeled Before and After. State the revision or build identity and the single visible difference the reviewer should watch. If the platform supports one comparison video and that presentation is clearer, join the verified clips with explicit labels while retaining the individual source files until review is complete.

Keep codecs and containers compatible with the review platform. Software and hardware encoders are both valid when the resulting files pass full decode and visual inspection.

## Restore shared state

Close only the processes created for capture. Restore any shared installation, active revision, selected surface, and control state changed by the workflow. Compare the final process inventory with the baseline so repeated evidence runs do not accumulate application instances or memory use.
