import pexpect.replwrap
from pexpect.replwrap import REPLWrapper

if __name__ == '__main__':
    py: REPLWrapper = REPLWrapper(
        "Tightener -N console -e 0 -p "
        + pexpect.replwrap.PEXPECT_PROMPT
        + " -P "
        + pexpect.replwrap.PEXPECT_CONTINUATION_PROMPT,
        pexpect.replwrap.PEXPECT_PROMPT,
        None,
        pexpect.replwrap.PEXPECT_PROMPT,
        pexpect.replwrap.PEXPECT_CONTINUATION_PROMPT)
    print(py.run_command("4+7"))
    print(py.run_command("sysInfo().coordinatorName"))
