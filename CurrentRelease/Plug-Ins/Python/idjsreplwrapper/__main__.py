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
# Problems after closing notebook web page: Kernel does not respond any more. 
# Probably because Tightener remains running but is expected to quit
#

import pexpect.replwrap
import pexpect.popen_spawn
import sys
import os
import platform

from ipykernel.kernelbase import Kernel
from ipykernel.kernelapp import IPKernelApp

# from debugpy.common import log

# log.to_file("/Users/kris/Desktop/idsreplwrapper.log")

class IDJSTightenerKernel(Kernel):

    # log.info("Creating IDJSTightenerKernel")

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
        command.echo = False
    else:
        command = "bash -c \"" + scripts + "rru_Jupyter " + target + " '" + pexpect.replwrap.PEXPECT_PROMPT + "' '" +  pexpect.replwrap.PEXPECT_CONTINUATION_PROMPT + "'\""

    tightenerIDJSWrapper = pexpect.replwrap.REPLWrapper(
        command,
        pexpect.replwrap.PEXPECT_PROMPT,
        None,
        pexpect.replwrap.PEXPECT_PROMPT,
        pexpect.replwrap.PEXPECT_CONTINUATION_PROMPT)

    implementation = 'TightenerIDJS'
    implementation_version = '1.0'
    language = 'TightenerIDJS'
    language_info = {
        'name': 'TightenerIDJS',
        'mimetype': 'text/plain',
        'file_extension': '.idjs'
    }
    banner = "TightenerIDJS Kernel"

    def do_execute(self, code, silent, store_history=True, user_expressions=None,
                   allow_stdin=False):

        if not silent:
            # log.info("running '" + code + "'")
            stream_content = {'name': 'stdout', 
                'text': self.tightenerIDJSWrapper.run_command(code) 
                }
            self.send_response(self.iopub_socket, 'stream', stream_content) 

        return {'status': 'ok',
                # The base class increments the execution count
                'execution_count': self.execution_count,
                'payload': [],
                'user_expressions': {},
                }


if __name__ == '__main__':
    IPKernelApp.launch_instance(kernel_class=IDJSTightenerKernel)
