# Legacy entry point. The implementation lives in the shared
# 'tightenerkernel' package; this shim keeps kernelspecs from older
# releases (argv: python3 -m tqlreplwrapper) working.

from tightenerkernel import launch

launch("tql")
