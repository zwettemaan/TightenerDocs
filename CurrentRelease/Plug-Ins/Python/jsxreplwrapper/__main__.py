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
import sys
import os
from ipykernel.kernelbase import Kernel
from ipykernel.kernelapp import IPKernelApp


class JSXTightenerKernel(Kernel):

    if "RRE_JUPYTER_TARGET" in os.environ:
        target = os.environ["RRE_JUPYTER_TARGET"]
    else:
        target = "InDesign"

    scripts = ""
    if "TIGHTENER_SCRIPTS" in os.environ:
        scripts = os.environ["TIGHTENER_SCRIPTS"]

    if platform.system() == "Windows":
        command = "\"" + scripts + "rre_Jupyter.bat\" " + target + " \"" + pexpect.replwrap.PEXPECT_PROMPT + "\" \"" +  pexpect.replwrap.PEXPECT_CONTINUATION_PROMPT + "\""
    else:
        command = "bash -c \"" + scripts + "rre_Jupyter " + target + " '" + pexpect.replwrap.PEXPECT_PROMPT + "' '" +  pexpect.replwrap.PEXPECT_CONTINUATION_PROMPT + "'\""

    tightenerJSXWrapper = pexpect.replwrap.REPLWrapper(
        command,
        pexpect.replwrap.PEXPECT_PROMPT,
        None,
        pexpect.replwrap.PEXPECT_PROMPT,
        pexpect.replwrap.PEXPECT_CONTINUATION_PROMPT)

    implementation = 'TightenerJSX'
    implementation_version = '1.0'
    language = 'TightenerJSX'
    language_info = {
        'name': 'TightenerJSX',
        'mimetype': 'text/plain',
        'file_extension': '.jsx'
    }
    banner = "TightenerJSX Kernel"

    def do_execute(self, code, silent, store_history=True, user_expressions=None,
                   allow_stdin=False):

        if not silent:
            stream_content = {'name': 'stdout', 
                'text': self.tightenerJSXWrapper.run_command(code) 
                }
            self.send_response(self.iopub_socket, 'stream', stream_content) 

        return {'status': 'ok',
                # The base class increments the execution count
                'execution_count': self.execution_count,
                'payload': [],
                'user_expressions': {},
                }


if __name__ == '__main__':
    IPKernelApp.launch_instance(kernel_class=JSXTightenerKernel)
