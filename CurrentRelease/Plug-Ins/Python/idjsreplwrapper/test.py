import pexpect.replwrap
import os
from pexpect.replwrap import REPLWrapper

if __name__ == '__main__':   

    if "RRU_JUPYTER_TARGET" in os.environ:
        target = os.environ["RRU_JUPYTER_TARGET"]
    else:
        target = "InDesign"

    scripts = ""
    if "TIGHTENER_SCRIPTS" in os.environ:
        scripts = os.environ["TIGHTENER_SCRIPTS"]

    if platform.system() == "Windows":
        commandStr = "\"" + scripts + "rru_Jupyter.bat\" " + target + " \"" + pexpect.replwrap.PEXPECT_PROMPT + "\" \"" +  pexpect.replwrap.PEXPECT_CONTINUATION_PROMPT + "\""
        command = pexpect.popen_spawn.PopenSpawn(commandStr)
    else:
        command = "bash -c \"" + scripts + "rru_Jupyter " + target + " '" + pexpect.replwrap.PEXPECT_PROMPT + "' '" +  pexpect.replwrap.PEXPECT_CONTINUATION_PROMPT + "'\""

    py: REPLWrapper = REPLWrapper(
        command,
        pexpect.replwrap.PEXPECT_PROMPT,
        None,
        pexpect.replwrap.PEXPECT_PROMPT,
        pexpect.replwrap.PEXPECT_CONTINUATION_PROMPT)
    print(py.run_command("4+7"))
    print(py.run_command("app.name"))
