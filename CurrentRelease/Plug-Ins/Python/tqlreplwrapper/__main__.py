# To install on a Mac with python3 and jupyter installed
#
# ./installMac.command
#
# To run
#   jupyter notebook
# then pick kernel from dropdown
#
# To remove
#   jupyter kernelspec uninstall jsxreplwrapper
#
# List:
#   jupyter kernelspec list
#
# Problems after closing notebook web page: Kernel does not respond anymore.
# Probably because Tightener remains running but is expected to quit
#

import pexpect.replwrap
import pexpect.popen_spawn
import os
import platform

from ipykernel.kernelbase import Kernel
from ipykernel.kernelapp import IPKernelApp

# from debugpy.common import log

# log.to_file("/Users/USERNAME/Desktop/tqlreplwrapper.log")


class TQLTightenerKernel(Kernel):

    def do_apply(self, content, bufs, msg_id, reply_metadata):
        pass

    def do_clear(self):
        pass

    async def do_debug_request(self, msg):
        pass

    # log.info("Creating TQLTightenerKernel")

    if "RRT_JUPYTER_TARGET" in os.environ:
        target = os.environ["RRT_JUPYTER_TARGET"]
    else:
        target = "reflector"

    scripts = ""
    if "TIGHTENER_SCRIPTS" in os.environ:
        scripts = os.environ["TIGHTENER_SCRIPTS"]

    if platform.system() == "Windows":
        commandStr = "\"" + scripts + "rrt_Jupyter.bat\" " + target + \
                     " \"" + pexpect.replwrap.PEXPECT_PROMPT + "\" \"" + \
                     pexpect.replwrap.PEXPECT_CONTINUATION_PROMPT + "\""
        command = pexpect.popen_spawn.PopenSpawn(commandStr)
        command.echo = False
    else:
        command = "bash -c \"" + scripts + "rrt_Jupyter " + target + \
                  " '" + pexpect.replwrap.PEXPECT_PROMPT + "' '" + \
                  pexpect.replwrap.PEXPECT_CONTINUATION_PROMPT + "'\""

    tightenerTQLWrapper = pexpect.replwrap.REPLWrapper(
        command,
        pexpect.replwrap.PEXPECT_PROMPT,
        None,
        pexpect.replwrap.PEXPECT_PROMPT,
        pexpect.replwrap.PEXPECT_CONTINUATION_PROMPT)

    implementation = 'TightenerTQL'
    implementation_version = '1.0'
    language = 'TightenerTQL'
    language_info = {
        'name': 'TightenerTQL',
        'mimetype': 'text/plain',
        'file_extension': '.tql'
    }
    banner = "TightenerTQL Kernel"

    def do_execute(self, code, silent, store_history=True, user_expressions=None, allow_stdin=False, **kwargs):

        if not silent:
            # log.info("running '" + code + "'")
            stream_content = \
                {
                    'name': 'stdout',
                    'text': self.tightenerTQLWrapper.run_command(code)
                }
            self.send_response(self.iopub_socket, 'stream', stream_content) 

        return {'status': 'ok',
                # The base class increments the execution count
                'execution_count': self.execution_count,
                'payload': [],
                'user_expressions': {},
                }


if __name__ == '__main__':
    IPKernelApp.launch_instance(kernel_class=TQLTightenerKernel)
