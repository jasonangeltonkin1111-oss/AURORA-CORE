from __future__ import annotations

import re

WINDOWS_FORBIDDEN_PATH_CHARS = {'\\', '/', ':', '*', '?', '"', '<', '>', '|'}
KNOWN_BROKER_SUFFIXES = (
    ".nx",
    ".c",
    ".m",
    ".rw",
    ".o",
    ".pro",
    ".ecn",
    ".raw",
    "_i",
    "_m",
)
KNOWN_FX_CURRENCIES = {
    "USD",
    "EUR",
    "GBP",
    "JPY",
    "AUD",
    "NZD",
    "CAD",
    "CHF",
    "SEK",
    "NOK",
    "DKK",
    "MXN",
    "ZAR",
    "TRY",
    "CZK",
    "PLN",
    "HKD",
    "SGD",
    "CNH",
    "HUF",
    "THB",
}


def normalize_symbol_text(symbol: str | None) -> str:
    """Return an uppercase comparison string while preserving display elsewhere."""
    text = str(symbol or "").strip()
    return text.upper()


def strip_known_broker_suffix(symbol: str | None) -> str:
    """Strip one known broker suffix from the comparison form only."""
    text = normalize_symbol_text(symbol)
    lowered = text.lower()
    for suffix in KNOWN_BROKER_SUFFIXES:
        if lowered.endswith(suffix.lower()) and len(text) > len(suffix):
            return text[: -len(suffix)]
    dot = text.find(".")
    if dot > 0:
        return text[:dot]
    return text


def canonical_symbol_root(symbol: str | None) -> str:
    """Return the normalized root used for matching, not for display replacement."""
    return strip_known_broker_suffix(symbol)


def safe_folder_slug(value: str | None, default: str = "Unknown") -> str:
    """Create a readable folder slug without changing taxonomy meaning."""
    text = str(value or "").strip() or default
    for ch in WINDOWS_FORBIDDEN_PATH_CHARS:
        text = text.replace(ch, " - ")
    text = re.sub(r"\s+", " ", text).strip()
    text = text.replace(" / ", " - ").replace("/", " - ").replace("\\", " - ")
    text = re.sub(r"\s+-\s+", " - ", text).strip(" .")
    return text or default


def safe_file_slug(value: str | None, default: str = "unknown") -> str:
    """Create a conservative file slug for L10 manifests and sidecar filenames."""
    text = str(value or "").strip() or default
    for ch in WINDOWS_FORBIDDEN_PATH_CHARS:
        text = text.replace(ch, "_")
    text = re.sub(r"\s+", "_", text).strip("._ ")
    text = re.sub(r"_+", "_", text)
    return text or default


def is_basic_fx_pair(symbol: str | None) -> bool:
    root = canonical_symbol_root(symbol)
    if len(root) != 6:
        return False
    base = root[:3]
    quote = root[3:]
    return base in KNOWN_FX_CURRENCIES and quote in KNOWN_FX_CURRENCIES and base != quote


def fx_pair_parts(symbol: str | None) -> tuple[str, str] | None:
    if not is_basic_fx_pair(symbol):
        return None
    root = canonical_symbol_root(symbol)
    return root[:3], root[3:]


def future_group_folder_path(ranking_group: str | None) -> str:
    group_slug = safe_folder_slug(ranking_group)
    return f"Selection Desk/Groups/{group_slug}/"


def normalize_match_candidates(symbol: str | None) -> tuple[str, ...]:
    """Return ordered candidate keys for matching without duplicate entries."""
    raw = normalize_symbol_text(symbol)
    root = canonical_symbol_root(symbol)
    candidates: list[str] = []
    for candidate in (raw, root):
        if candidate and candidate not in candidates:
            candidates.append(candidate)
    return tuple(candidates)
