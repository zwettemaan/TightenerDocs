# Shared Jupyter kernel implementation for the Tightener kernels.
#
# One implementation, three flavors (selected via --flavor= in kernel.json,
# or through the legacy jsxreplwrapper/idjsreplwrapper/tqlreplwrapper shims):
#
#   jsx   ExtendScript  rre_Jupyter   RRE_JUPYTER_TARGET  (default InDesign)
#   idjs  UXP Script    rru_Jupyter   RRU_JUPYTER_TARGET  (default InDesign)
#   tql   TQL           rrt_Jupyter   RRT_JUPYTER_TARGET  (default reflector)
#
# To install on a Mac with python3 and jupyter installed
#
# ./installMac.command
#
# To run
#   jupyter notebook
# then pick kernel from dropdown
#
# List:
#   jupyter kernelspec list
#
# Robustness features (v2.0):
# - The Tightener subprocess is started lazily on the first executed cell,
#   so a missing Tightener installation produces a readable error in the
#   notebook instead of a dead kernel.
# - do_shutdown() sends 'quit' to the REPL and terminates the subprocess,
#   so closing the notebook no longer leaves an orphaned Tightener behind.
# - pexpect TIMEOUT/EOF and KeyboardInterrupt are caught; the subprocess is
#   discarded and transparently relaunched on the next cell.

import atexit
import os
import platform

import pexpect
import pexpect.replwrap
from ipykernel.kernelbase import Kernel
from ipykernel.kernelapp import IPKernelApp

IS_WINDOWS = platform.system() == "Windows"

if IS_WINDOWS:
    import pexpect.popen_spawn


FLAVORS = {
    # JupyterInDesign is a config.ini shorthand; the JUPYTER_INDESIGN_CHANNEL
    # placeholder there selects the InDesign connection channel
    # (C++ plug-in, APID ToolAssistant, or ESDLL)
    "jsx": {
        "command": "rre_Jupyter",
        "target_env": "RRE_JUPYTER_TARGET",
        "default_target": "JupyterInDesign",
        "name": "TightenerJSX",
        "file_extension": ".jsx",
    },
    "idjs": {
        "command": "rru_Jupyter",
        "target_env": "RRU_JUPYTER_TARGET",
        "default_target": "JupyterInDesign",
        "name": "TightenerIDJS",
        "file_extension": ".idjs",
    },
    "tql": {
        "command": "rrt_Jupyter",
        "target_env": "RRT_JUPYTER_TARGET",
        "default_target": "reflector",
        "name": "TightenerTQL",
        "file_extension": ".tql",
    },
}

# Tightener itself gives up after TIGHTENER_DEFAULT_REPL_TIMEOUT_MS and
# reports "Timed out" through the normal prompt flow; pexpect only bails
# out if that mechanism also failed, so it waits noticeably longer.
PEXPECT_EXTRA_WAIT_SECONDS = 15.0

# Each cell is wrapped between these marker lines. The r*_REPL.tql
# scripts accumulate the lines in between locally and forward the whole
# cell to the target in one sendData round-trip; without the markers
# every line of a cell would cost its own round-trip.
CELL_BEGIN_MARKER = "%%TIGHTENER_CELL_BEGIN%%"
CELL_END_MARKER = "%%TIGHTENER_CELL_END%%"


def repl_timeout_seconds():
    try:
        timeout_ms = int(os.environ.get("TIGHTENER_DEFAULT_REPL_TIMEOUT_MS", "20000"))
    except ValueError:
        timeout_ms = 20000
    return timeout_ms / 1000.0 + PEXPECT_EXTRA_WAIT_SECONDS


class TightenerStartupError(Exception):
    pass


class TightenerKernelBase(Kernel):

    flavor = None  # overridden per subclass

    implementation_version = "2.1"

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self._flavor_config = FLAVORS[self.flavor]
        self._wrapper = None
        atexit.register(self._kill_subprocess)

    # -- ipykernel compatibility stubs --------------------------------

    def do_apply(self, content, bufs, msg_id, reply_metadata):
        pass

    def do_clear(self):
        pass

    async def do_debug_request(self, msg):
        pass

    # -- Tightener subprocess management -------------------------------

    def _resolve_command(self):
        # Returns the launcher path/name, raising TightenerStartupError
        # with a user-actionable message when it cannot work.
        scripts = os.environ.get("TIGHTENER_SCRIPTS", "")
        command = self._flavor_config["command"]
        if IS_WINDOWS:
            command += ".bat"

        if scripts:
            path = scripts + command
            if not os.path.exists(path):
                raise TightenerStartupError(
                    "TIGHTENER_SCRIPTS points to '" + scripts + "' but '" +
                    command + "' was not found there. Re-run the Tightener "
                    "install script, or fix the TIGHTENER_SCRIPTS "
                    "environment variable.")
            return path

        import shutil
        if shutil.which(command) is None:
            raise TightenerStartupError(
                "'" + command + "' was not found: TIGHTENER_SCRIPTS is not "
                "set and the command is not on the PATH. Install Tightener "
                "(install.command / install.bat) and start Jupyter from a "
                "new terminal so it inherits the Tightener environment.")
        return command

    def _ensure_wrapper(self):
        if self._wrapper is not None:
            return self._wrapper

        command_path = self._resolve_command()
        target = os.environ.get(
            self._flavor_config["target_env"],
            self._flavor_config["default_target"])

        prompt = pexpect.replwrap.PEXPECT_PROMPT
        continuation = pexpect.replwrap.PEXPECT_CONTINUATION_PROMPT

        try:
            if IS_WINDOWS:
                command_str = ('"' + command_path + '" ' + target +
                               ' "' + prompt + '" "' + continuation + '"')
                child = pexpect.popen_spawn.PopenSpawn(
                    command_str, encoding="utf-8")
                child.echo = False
                command = child
            else:
                command = ("bash -c \"'" + command_path + "' " + target +
                           " '" + prompt + "' '" + continuation + "'\"")

            self._wrapper = pexpect.replwrap.REPLWrapper(
                command,
                prompt,
                None,
                prompt,
                continuation)
        except Exception as exc:
            self._kill_subprocess()
            raise TightenerStartupError(
                "Could not start the Tightener REPL for target '" + target +
                "': " + repr(exc) + ". Check that Tightener is installed "
                "and that the target application is running.")

        return self._wrapper

    def _kill_subprocess(self):
        wrapper = self._wrapper
        self._wrapper = None
        if wrapper is None:
            return
        child = wrapper.child
        try:
            if IS_WINDOWS:
                child.proc.kill()
            else:
                child.close(force=True)
        except Exception:
            pass

    # -- kernel protocol ------------------------------------------------

    def _error_reply(self, ename, evalue, silent):
        if not silent:
            self.send_response(self.iopub_socket, "error", {
                "ename": ename,
                "evalue": evalue,
                "traceback": [evalue],
            })
        return {
            "status": "error",
            "ename": ename,
            "evalue": evalue,
            "traceback": [evalue],
            "execution_count": self.execution_count,
        }

    def do_execute(self, code, silent, store_history=True,
                   user_expressions=None, allow_stdin=False, **kwargs):

        ok_reply = {
            "status": "ok",
            # The base class increments the execution count
            "execution_count": self.execution_count,
            "payload": [],
            "user_expressions": {},
        }

        if not code.strip():
            return ok_reply

        try:
            wrapper = self._ensure_wrapper()
        except TightenerStartupError as exc:
            return self._error_reply("TightenerStartupError", str(exc), silent)

        batched_code = (CELL_BEGIN_MARKER + "\n" + code + "\n" +
                        CELL_END_MARKER)

        try:
            output = wrapper.run_command(
                batched_code, timeout=repl_timeout_seconds())
        except KeyboardInterrupt:
            self._kill_subprocess()
            return self._error_reply(
                "Interrupted",
                "Interrupted while waiting for Tightener. The remote script "
                "may still be running in the target application. The kernel "
                "reconnects on the next cell.",
                silent)
        except pexpect.EOF:
            self._kill_subprocess()
            return self._error_reply(
                "TightenerExited",
                "The Tightener process exited unexpectedly. The kernel "
                "reconnects on the next cell.",
                silent)
        except pexpect.TIMEOUT:
            self._kill_subprocess()
            return self._error_reply(
                "TightenerTimeout",
                "No response from Tightener within " +
                str(int(repl_timeout_seconds())) + "s (the REPL prompt never "
                "returned). Check that the target application is running and "
                "responsive; raise TIGHTENER_DEFAULT_REPL_TIMEOUT_MS for "
                "long-running scripts. The kernel reconnects on the next "
                "cell.",
                silent)

        if not silent:
            self.send_response(self.iopub_socket, "stream", {
                "name": "stdout",
                "text": output,
            })

        return ok_reply

    def do_shutdown(self, restart):
        wrapper = self._wrapper
        if wrapper is not None:
            try:
                wrapper.child.sendline("quit")
                wrapper.child.expect(
                    [pexpect.EOF, pexpect.TIMEOUT], timeout=5)
            except Exception:
                pass
        self._kill_subprocess()
        return {"status": "ok", "restart": restart}


class JSXTightenerKernel(TightenerKernelBase):
    flavor = "jsx"
    implementation = "TightenerJSX"
    language = "TightenerJSX"
    language_info = {
        "name": "TightenerJSX",
        "mimetype": "text/plain",
        "file_extension": ".jsx",
    }
    banner = "TightenerJSX Kernel (ExtendScript via Tightener)"


class IDJSTightenerKernel(TightenerKernelBase):
    flavor = "idjs"
    implementation = "TightenerIDJS"
    language = "TightenerIDJS"
    language_info = {
        "name": "TightenerIDJS",
        "mimetype": "text/plain",
        "file_extension": ".idjs",
    }
    banner = "TightenerIDJS Kernel (UXP Script via Tightener)"


class TQLTightenerKernel(TightenerKernelBase):
    flavor = "tql"
    implementation = "TightenerTQL"
    language = "TightenerTQL"
    language_info = {
        "name": "TightenerTQL",
        "mimetype": "text/plain",
        "file_extension": ".tql",
    }
    banner = "TightenerTQL Kernel (TQL via Tightener)"


KERNEL_CLASSES = {
    "jsx": JSXTightenerKernel,
    "idjs": IDJSTightenerKernel,
    "tql": TQLTightenerKernel,
}


def launch(flavor):
    IPKernelApp.launch_instance(kernel_class=KERNEL_CLASSES[flavor])
