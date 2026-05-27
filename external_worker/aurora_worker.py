from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple
import argparse
import ctypes
import os
import subprocess
import time
import traceback

from aurora_worker_io import (
    GATEWAY_FOLDER_NAME,
    WorkerPaths,
    atomic_write_text,
    payload_checksum,
    read_kv,
    read_text,
    split_snapshot,
    unix_time,
    utc_stamp,
)
from aurora_worker_l6_friction import publish_l6_cost_friction_rankings
from aurora_worker_l7_session import publish_l7_session_relevance_rankings
from aurora_worker_l8_movement import publish_l8_movement_range_rankings
from aurora_worker_l9_structure import publish_l9_structure_location_rankings
from aurora_worker_l10 import EMPTY_L10_SUMMARY, publish_l10_taxonomy_classification
from aurora_worker_l10_source import l10_build_source_bundle
from aurora_worker_render_index import publish_render_index
from aurora_worker_recorder import gateway_record_event, gateway_record_exception
WORKER_VERSION = "0.6.19_selection_cleanup_changed_only"
EXPECTED_AUTHORITY = "calculation_support_only"
PROCESS_START_UNIX = unix_time()
PROCESS_START_UTC = utc_stamp()

STATUS_MAX_AGE_SECONDS = 90
DAEMON_TASK_NAME = "AuroraCoreGatewayDaemon"
WATCHDOG_TASK_NAME = "AuroraCoreGatewayWatchdog"

# Remainder of this file is unchanged from the previous source revision.
