---
name: project-wsl-spawn-timeout
description: Blank new tabs + stalls on 2026-09-28 were WSL, not WezTerm — RAM exhaustion plus order-7 fragmentation (his ruling: both) make wsl.exe time out with 0x8007274c; drove the move off Cursor
metadata:
  type: project
---

**Symptom (2026-09-28):** ALT+A picker lists agents fine, but the new tab stays
blank; WezTerm "freezes intermittently". He asked if WezTerm can't handle 3-5 agents.

**Measured cause: the WSL VM, not WezTerm.**
- 2 of 10 bare `wsl.exe -d Ubuntu-24.04 --exec /bin/true` from Windows hung 30 s,
  then died with `Wsl/Service/0x8007274c`. Reverse direction (WSL→powershell.exe)
  hit `UtilAcceptVsock: accept4 failed 110` after exactly 10 s.
- Kernel log: `page allocation failure: order:7` in `vmbus_alloc_ring`, 21 times,
  first at 14:03 that day. `/proc/buddyinfo` showed 4 order-7 blocks free.
  compact_fail 1644 vs compact_success 416. Pressure (PSI) was about 0, CPU 97% idle.
- Mechanism: microsoft/WSL PR #41690 (unmerged at the time). The hvsocket listener
  needs contiguous order-7 memory for each new host-initiated connection.
- Corrected by celox, 2026-09-29: microsoft/WSL#40650 has **no** ~167 vsock cap.
  A maintainer says there is no fixed limit. The slow leak there is orphaned Relay processes.
- Load: 13 Claude agents ran in **Cursor**, only about 4 sessions in WezTerm.
  cursor-server used 5.2 GiB RSS across 16 extension hosts. WezTerm GUI was
  193 MB and Responding.

**His ruling, 2026-09-29: it was both.** RAM exhaustion and fragmentation, not
fragmentation alone. Don't re-argue it. His conclusion is that 13 Cursor windows
can't run, so the agent teams move into WezTerm. That migration is the job now.

**How to apply:**
- For a blank or hung new tab, check `journalctl -k | grep 'order:7'` and
  `/proc/buddyinfo` first, then time a `wsl.exe` spawn. Don't touch wezterm.lua for this.
- Levers, all his hand: (1) `sync; echo 3 > drop_caches; echo 1 > compact_memory`
  (sudo), which kills nothing; (2) `wsl --shutdown`, which kills every agent.
  Prevention: less anon memory in the VM, since the Cursor extension hosts are the bulk.

See [[windows-wsl-boundary]], [[project-conpty-flicker]].
