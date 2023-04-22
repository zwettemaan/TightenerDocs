import pexpect.replwrap
import pexpect.popen_spawn
import platform
import os

if __name__ == '__main__':

    if "RRT_JUPYTER_TARGET" in os.environ:
        target = os.environ["RRT_JUPYTER_TARGET"]
    else:
        target = "reflector"

    scripts = ""
    if "TIGHTENER_SCRIPTS" in os.environ:
        scripts = os.environ["TIGHTENER_SCRIPTS"]

    if platform.system() == "Windows":
        commandStr = "\"" + scripts + "rrt_Jupyter.bat\" " + target + " \"" + pexpect.replwrap.PEXPECT_PROMPT + "\" \"" +  pexpect.replwrap.PEXPECT_CONTINUATION_PROMPT + "\""
        command = pexpect.popen_spawn.PopenSpawn(commandStr)
    else:
        command = "bash -c \"" + scripts + "rrt_Jupyter " + target + " '" + pexpect.replwrap.PEXPECT_PROMPT + "' '" +  pexpect.replwrap.PEXPECT_CONTINUATION_PROMPT + "'\""

    py: pexpect.replwrap.REPLWrapper = pexpect.replwrap.REPLWrapper(
        command,
        pexpect.replwrap.PEXPECT_PROMPT,
        None,
        pexpect.replwrap.PEXPECT_PROMPT,
        pexpect.replwrap.PEXPECT_CONTINUATION_PROMPT)
    print(py.run_command("4+7"))
    print(py.run_command("sysInfo()"))
