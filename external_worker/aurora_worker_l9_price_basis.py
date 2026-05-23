from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Iterable, Optional
import math


@dataclass(frozen=True)
class L9PriceBasis:
    price_basis: str
    price_basis_quality: str
    price_used: float
    bid: float
    ask: float
    mid: float
    tick_age_seconds: float
    quote_stale_location: bool
    reason: str


def _safe_float(value: object, default: float = 0.0) -> float:
    try:
        text = "" if value is None else str(value).strip()
        if text == "" or text.lower() in {"nan", "inf", "-inf", "not_available", "pending", "partial"}:
            return default
        number = float(text)
        return default if math.isnan(number) or math.isinf(number) else number
    except (TypeError, ValueError):
        return default


def _first_present(row: Dict[str, str], keys: Iterable[str]) -> Optional[str]:
    for key in keys:
        value = row.get(key)
        if value is not None and str(value).strip() != "":
            return str(value).strip()
    return None


def _join_reason(parts: Iterable[str]) -> str:
    seen = set()
    clean = []
    for raw in parts:
        part = str(raw or "").replace("\r", " ").replace("\n", " ").strip()
        if not part or part in seen:
            continue
        seen.add(part)
        clean.append(part)
    return ";".join(clean) if clean else "not_available"


def resolve_l9_price_basis(row: Dict[str, str], latest_ohlc_close: float | None = None, stale_after_seconds: float = 20.0, severe_stale_after_seconds: float = 60.0) -> L9PriceBasis:
    """Resolve the price used by L9 structure geometry.

    L9 is a watchlist-location layer. It needs a current price, but it must not
    pretend stale or missing quotes are clean. Use fresh bid/ask mid when safe;
    degrade to stale mid when still numerically usable; finally use the caller's
    latest OHLC close fallback if supplied. This module does not call MT5, does
    not read OHLC files, and does not grant entry/selection/trade permission.
    """
    bid = _safe_float(_first_present(row, ("bid", "Bid", "BID")), 0.0)
    ask = _safe_float(_first_present(row, ("ask", "Ask", "ASK")), 0.0)
    mid_raw = _safe_float(_first_present(row, ("mid", "Mid", "price_mid", "current_mid")), 0.0)
    tick_age = _safe_float(_first_present(row, ("tick_age_seconds", "tick_age", "quote_age_seconds")), 999999.0)
    quote_quality = str(_first_present(row, ("quote_quality", "Quote Quality")) or "not_available").lower()
    surface_quality = str(_first_present(row, ("surface_quality", "Surface Quality")) or "not_available").lower()

    reasons = []
    quote_bad = any(token in f"{quote_quality} {surface_quality}" for token in ("missing", "invalid", "not_available"))
    quote_warning = any(token in f"{quote_quality} {surface_quality}" for token in ("stale", "aging", "warning", "partial"))

    has_bid_ask = bid > 0.0 and ask > 0.0 and ask >= bid
    mid = ((bid + ask) / 2.0) if has_bid_ask else mid_raw
    has_mid = mid > 0.0

    if has_bid_ask:
        reasons.append("bid_ask_mid_available")
    elif has_mid:
        reasons.append("mid_field_available_without_clean_bid_ask")
    else:
        reasons.append("quote_mid_unavailable")

    if tick_age <= stale_after_seconds and has_mid and not quote_bad and not quote_warning:
        return L9PriceBasis(
            price_basis="fresh_mid",
            price_basis_quality="fresh_quote_mid",
            price_used=mid,
            bid=bid,
            ask=ask,
            mid=mid,
            tick_age_seconds=tick_age,
            quote_stale_location=False,
            reason=_join_reason(reasons + [f"tick_age_lte_{int(stale_after_seconds)}s", "quote_quality_clean"]),
        )

    if has_mid and tick_age <= severe_stale_after_seconds and not quote_bad:
        stale_reason = "quote_quality_warning" if quote_warning else f"tick_age_gt_{int(stale_after_seconds)}s"
        return L9PriceBasis(
            price_basis="stale_mid",
            price_basis_quality="stale_or_warning_quote_mid",
            price_used=mid,
            bid=bid,
            ask=ask,
            mid=mid,
            tick_age_seconds=tick_age,
            quote_stale_location=True,
            reason=_join_reason(reasons + [stale_reason, "location_allowed_degraded_not_clean"]),
        )

    fallback = 0.0 if latest_ohlc_close is None else _safe_float(latest_ohlc_close, 0.0)
    if fallback > 0.0:
        return L9PriceBasis(
            price_basis="ohlc_close_fallback",
            price_basis_quality="degraded_ohlc_close_fallback",
            price_used=fallback,
            bid=bid,
            ask=ask,
            mid=mid,
            tick_age_seconds=tick_age,
            quote_stale_location=True,
            reason=_join_reason(reasons + ["quote_not_clean_for_current_location", "latest_ohlc_close_fallback_used"]),
        )

    return L9PriceBasis(
        price_basis="unavailable",
        price_basis_quality="price_basis_unavailable",
        price_used=0.0,
        bid=bid,
        ask=ask,
        mid=mid,
        tick_age_seconds=tick_age,
        quote_stale_location=True,
        reason=_join_reason(reasons + ["no_fresh_mid_no_usable_stale_mid_no_ohlc_fallback"]),
    )
