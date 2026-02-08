# Synchronization Skills – TX15 ↔ Git Repo

Radio path: D:\
Git repo path: C:\Users\thier\OneDrive\Workspaces\ExpressLRS\RadioMaster_TX15\myTX15\EdgeTX

Use the provided PowerShell script `sync-tx15.ps1` with one of the four modes:

- SyncToRadio     → copy newer files from git to radio, no deletions
- SyncFromRadio   → copy newer files from radio to git, no deletions
- MirrorToRadio   → full mirror git → radio (deletes extras on radio)
- MirrorFromRadio → full mirror radio → git (deletes extras in git)

Example usage in terminal:
```powershell
.\sync-tx15.ps1 -Mode SyncToRadio
