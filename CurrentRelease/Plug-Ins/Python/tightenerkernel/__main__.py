# Entry point: python3 -m tightenerkernel --flavor=jsx -f {connection_file}
#
# --flavor is consumed here; every other argument is passed through to
# ipykernel (which does its own traitlets argv parsing).

import sys

from tightenerkernel import KERNEL_CLASSES, launch


def main():
    flavor = "jsx"
    passthrough = [sys.argv[0]]
    for arg in sys.argv[1:]:
        if arg.startswith("--flavor="):
            flavor = arg.split("=", 1)[1]
        else:
            passthrough.append(arg)

    if flavor not in KERNEL_CLASSES:
        sys.stderr.write(
            "tightenerkernel: unknown flavor '" + flavor + "' (expected one "
            "of: " + ", ".join(sorted(KERNEL_CLASSES)) + ")\n")
        sys.exit(1)

    sys.argv = passthrough
    launch(flavor)


main()
