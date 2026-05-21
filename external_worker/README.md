# Aurora External Worker

This folder contains the first standalone worker skeleton for Aurora Core.

Current worker mode:

```text
validator_skeleton
```

It reads the MT5-exported snapshot from:

```text
Workbench/External Worker/Inbox/snapshot_latest.txt
Workbench/External Worker/Inbox/snapshot_latest.manifest
```

It writes:

```text
Workbench/External Worker/Status/worker_heartbeat.txt
Workbench/External Worker/Outbox/result_latest.txt
Workbench/External Worker/Outbox/result_latest.manifest
```

Run once:

```bash
python external_worker/aurora_worker.py --root "<Aurora account root>"
```

Example root shape from generated MT5 files:

```text
Aurora Core/<SERVER>/<ACCOUNT>
```

Current checks:

- control file exists
- snapshot file exists
- manifest file exists
- server/account match the control file
- authority is `calculation_support_only`
- permission flag remains `false`
- row counts match
- payload checksum matches

Packaging target later:

```text
AuroraWorker.exe
```

The EA launch bridge is not wired yet. MT5 should currently show:

```text
launch_implementation=not_implemented_yet
```
