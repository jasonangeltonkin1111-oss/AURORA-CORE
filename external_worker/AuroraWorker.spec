# -*- mode: python ; coding: utf-8 -*-

a = Analysis(
    ['aurora_worker_entrypoint.py'],
    pathex=[],
    binaries=[
        (r'C:\Users\Jason\AppData\Local\Programs\Python\Python312\DLLs\_ctypes.pyd', '.'),
        (r'C:\Users\Jason\AppData\Local\Programs\Python\Python312\DLLs\libffi-8.dll', '.'),
    ],
    datas=[],
    hiddenimports=[
        '_ctypes',
        'ctypes',
        'ctypes.util',
        'aurora_worker_l11',
        'aurora_worker_l11_cleanup',
        'aurora_worker_l11_dispatch',
        'aurora_worker_l11_tree',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='AuroraWorker',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
coll = COLLECT(
    exe,
    a.binaries,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='AuroraWorker',
)