from __future__ import annotations

# Explicit import adapter for the historical aurora_worker_l8_movement module name.
# The large legacy scorer file is intentionally left intact for rollback, but this
# package wrapper redirects its OHLC root to the active Runtime 1 priority-window
# route. It does not create a second model and does not fetch broker history.

from pathlib import Path
import importlib.util
import sys

_LEGACY_MODULE_NAME = "aurora_worker_l8_movement_legacy"
_LEGACY_FILE = Path(__file__).resolve().parent.parent / "aurora_worker_l8_movement.py"

_spec = importlib.util.spec_from_file_location(_LEGACY_MODULE_NAME, _LEGACY_FILE)
if _spec is None or _spec.loader is None:
    raise ImportError(f"Unable to load legacy L8 movement scorer from {_LEGACY_FILE}")
_legacy = importlib.util.module_from_spec(_spec)
sys.modules[_LEGACY_MODULE_NAME] = _legacy
_spec.loader.exec_module(_legacy)

class _PriorityWindowRoot:
    def __init__(self, symbols_root: Path):
        self.symbols_root = symbols_root

    def __truediv__(self, symbol: str) -> Path:
        return self.symbols_root / str(symbol) / "Priority Windows"

    def __str__(self) -> str:
        return str(self.symbols_root / "<symbol>" / "Priority Windows")


def _shared_ohlc_priority_window_root(outbox: Path) -> _PriorityWindowRoot:
    account_root = outbox.parents[2]
    server_root = account_root.parent
    symbols_root = server_root / "Shared Market Data" / "OHLC Store" / "Symbols"
    return _PriorityWindowRoot(symbols_root)

_legacy.L8_SOURCE_OWNER = "Runtime_1_Shared_OHLC_Priority_Windows"
_legacy._shared_ohlc_fast_window_root = _shared_ohlc_priority_window_root

publish_l8_movement_range_rankings = _legacy.publish_l8_movement_range_rankings

__all__ = ["publish_l8_movement_range_rankings"]
