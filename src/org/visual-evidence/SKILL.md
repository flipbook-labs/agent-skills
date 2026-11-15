---
name: visual-evidence
description: "Capture, verify, and attach screenshots or short videos for user-visible changes. Use when: a reviewer needs visual proof, a PR has something visual to show, an interaction or hover state needs recording, or a real bug supports matched before/after footage. Covers capability discovery across operating systems and architectures, virtual input, live capture, media verification, process cleanup, and honest labeling."
type: process
---

# Visual Evidence

Use this workflow to produce media that lets a reviewer see the claim without recreating the environment. Visual evidence supplements tests and read-back checks. It does not replace them.

## When not to use

Skip media when the change has no user-visible result. Do not manufacture a broken state or imply that illustrative footage is a real before state. Use the repository's validation skill for behavioral proof and its PR guidance for required sections.

## Choose the evidence

- Use a screenshot for layout, styling, copy, or one stable state.
- Use a short video when the claim depends on motion, hover, input, timing, a state transition, or continuity between states.
- Use matched before/after footage when the prior revision has a real, reproducible visual behavior that the change affects.
- Use an after-only demonstration when no honest before state exists. Label illustrative setup or pointer graphics as illustrative.

For before/after footage, read [references/before-after-video.md](references/before-after-video.md) before capture.

## Define the proof

Write down the claim, target surface, scenario, initial state, input sequence, and expected visible result. Keep the story, fixture, controls, viewport, scale, crop, and interaction sequence fixed across clips that will be compared. Record any state that can be read back through an API before capture.

## Discover capabilities at runtime

Build the workflow from available capabilities instead of a platform-specific command sequence:

1. A way to open the target revision and render the surface.
2. A control channel that can select the scenario, set inputs, and read state back.
3. Virtual input that acts inside the target application without moving the user's physical pointer.
4. A recorder that captures a live surface while excluding the physical cursor.
5. A decoder or probe that can validate the completed artifact.
6. A supported way to attach or host the media for review.

Discover the operating system, CPU architecture, display geometry, scale factor, available tools, and application instances before choosing adapters. Do not assume macOS, one monitor, a Retina scale, a window manager, absolute screen coordinates, an application bundle ID, a process name, an installed-plugin path, FFmpeg, or GitHub. Derive paths and capture geometry from the current environment. Treat platform-specific commands as replaceable adapters.

## Capture the live behavior

1. Inventory relevant application instances before opening anything. When capture needs a heavyweight application, open one instance for the task and record its identifier.
2. Open the exact revision and scenario under review. Wait for readiness, set the intended controls, and read them back when a control channel exists.
3. Bring the render surface into a captureable live state. Confirm it updates while the recorder watches it because background or window-targeted capture can freeze some accelerated surfaces.
4. Disable capture of the physical cursor. Drive the interaction through product-level, engine-level, browser-level, or operating-system virtual input that does not take over the user's pointer.
5. If the recorder cannot render the virtual pointer, add a synchronized pointer marker inside the captured surface. Make its illustrative role clear and keep its position tied to the same virtual-input coordinates.
6. Record the shortest sequence that establishes the claim, including enough lead-in and hold time for a reviewer to orient.
7. Restore any moved or mounted surface after capture and confirm its state remains intact when continuity is part of the feature.

Never substitute stitched screenshots for footage of an interaction. Never record a static surface while the user's real cursor moves over it and present that as virtual-input evidence.

## Verify before attachment

Do not upload the first file a recorder produces. Validate it first:

- Confirm the file has the expected dimensions, duration, frame rate, and decodable video stream using an available media probe or decoder.
- Decode the full clip, not only its header. A successful full decode catches truncated output.
- Inspect representative frames from the beginning, interaction, visible result, and ending. Confirm that the target UI changes across frames and that hover-dependent UI actually appears.
- Watch the final encoded artifact at normal speed. Check framing, text readability, cursor behavior, timing, and the absence of private or unrelated content.
- Reject frozen captures, mismatched before/after setup, misleading pointer graphics, and clips whose visible state disagrees with read-back evidence.

FFmpeg and ffprobe are common implementations for encoding, frame sampling, and validation. Use equivalent tools when they are unavailable. Avoid hardware-specific encoders unless the current environment advertises and verifies them.

## Attach and clean up

Use the review platform's supported media path. Label each artifact as Before, After, or Illustrative, and add one sentence naming the behavior it proves. Preserve existing human-authored media and notes when updating a PR.

Close only the application instances created for capture, then compare the live inventory with the baseline. Restore any globally installed build or plugin that was temporarily changed. Keep local source artifacts only when they are useful for reruns or review.

---

## Provenance and Maintenance

**Date stamped:** 2026-09-14. This workflow generalizes visual evidence captured from interactive application surfaces, including virtual-input hover footage and matched before/after demonstrations. It is capability-driven so the same evidence contract can use different operating-system, architecture, recorder, input, and review-platform adapters.

**Re-verify these claims when this skill next loads:** this skill contains cross-platform process doctrine and no repository-specific anchors. Confirm that the current environment provides a live render surface, non-disruptive virtual input, recording, full-decode validation, and an attachment path before promising media.
