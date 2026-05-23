from __future__ import annotations

from pathlib import Path

import aurora_worker_l8_movement as _l8


class _PriorityWindowRoot:
    """Path adapter for the Runtime 1 Shared OHLC priority-window layout.

    The existing L8 scorer expects a root object where ``root / symbol`` returns
    the folder containing M5/M15/H1/H4 ``*.window.csv`` files. Runtime 1 now
    stores those windows at:

        OHLC Store/Symbols/<symbol>/Priority Windows/<TF>.window.csv

    This adapter keeps the L8 scoring code unchanged while binding it to the
    current Runtime 1 source-owner path. It does not create files, fetch bars,
    calculate outside L8, or add a second OHLC owner.
    """

    def __init__(self, symbols_root: Path) -> None:
        self.symbols_root = symbols_root

    def __truediv__(self, symbol: str) -> Path:
        return self.symbols_root / str(symbol) / "Priority Windows"

    def __str__(self) -> str:
        return str(self.symbols_root / "<symbol>" / "Priority Windows")

    def __fspath__(self) -> str:
        return str(self)


def _shared_ohlc_priority_window_root(outbox: Path) -> _PriorityWindowRoot:
    account_root = outbox.parents[2]
    server_root = account_root.parent
    symbols_root = server_root / "Shared Market Data" / "OHLC Store" / "Symbols"
    return _PriorityWindowRoot(symbols_root)


def _patch_l8_path_contract() -> None:
    # Patch the old function name because the existing L8 scorer calls it.
    # The meaning is now priority windows under the single Runtime 1 OHLC Symbols tree.
    _l8.L8_SOURCE_OWNER = "Runtime_1_Shared_OHLC_Priority_Windows"
    _l8._shared_ohlc_fast_window_root = _shared_ohlc_priority_window_root


def publish_l8_movement_range_rankings(outbox: Path):
    _patch_l8_path_contract()
    return _l8.publish_l8_movement_range_rankings(outbox)
