import pexpect.replwrap
import os
from pexpect.replwrap import REPLWrapper

if __name__ == '__main__':   
    os.environ["RRE_PROMPT"] = pexpect.replwrap.PEXPECT_PROMPT
    os.environ["RRE_PROMPT_CONTINUATION"] = pexpect.replwrap.PEXPECT_CONTINUATION_PROMPT
    py: REPLWrapper = REPLWrapper(
        "bash -c 'rre_REPL InDesign'",
        pexpect.replwrap.PEXPECT_PROMPT,
        None,
        pexpect.replwrap.PEXPECT_PROMPT,
        pexpect.replwrap.PEXPECT_CONTINUATION_PROMPT)
    print(py.run_command("4+7"))
    print(py.run_command("$.engineName"))
