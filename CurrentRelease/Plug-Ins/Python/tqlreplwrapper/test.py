import pexpect.replwrap
from pexpect.replwrap import REPLWrapper
import os

if __name__ == '__main__':

    if "RRT_JUPYTER_TARGET" in os.environ:
        target = os.environ["RRT_JUPYTER_TARGET"]
    else:
        target = "reflector"

    command = "bash -c \"rrt_Jupyter " + target + " '" + pexpect.replwrap.PEXPECT_PROMPT + "' '" +  pexpect.replwrap.PEXPECT_CONTINUATION_PROMPT + "'\""

    py: REPLWrapper = REPLWrapper(
        command,
        pexpect.replwrap.PEXPECT_PROMPT,
        None,
        pexpect.replwrap.PEXPECT_PROMPT,
        pexpect.replwrap.PEXPECT_CONTINUATION_PROMPT)
    print(py.run_command("4+7"))
    print(py.run_command("sysInfo()"))
