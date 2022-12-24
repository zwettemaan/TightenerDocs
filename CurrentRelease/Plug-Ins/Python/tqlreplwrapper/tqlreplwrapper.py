# To install:
#
# jupyter kernelspec install "${TIGHTENER_RELEASE_ROOT}Plug-Ins/Python/tqlreplwrapper/"
#
# jupyter kernelspec install "%TIGHTENER_RELEASE_ROOT%Plug-Ins\Python\tqlreplwrapper\"
#
# To run
#   jupyter notebook
# then pick kernel from dropdown
#
# To remove
#   jupyter kernelspec uninstall TightenerTQL
#
# List:
#   jupyter kernelspec list
#
# Problems after closing notebook web page: Kernel does not respond any more. 
# Probably because Tightener remains running but is expected to quit

import pexpect.replwrap
import sys
from ipykernel.kernelbase import Kernel
from ipykernel.kernelapp import IPKernelApp


class TightenerKernel(Kernel):

    tightenerTQLWrapper = pexpect.replwrap.REPLWrapper(
        "Tightener -N console -I -p "
        + pexpect.replwrap.PEXPECT_PROMPT
        + " -P "
        + pexpect.replwrap.PEXPECT_CONTINUATION_PROMPT,
        pexpect.replwrap.PEXPECT_PROMPT,
        None,
        pexpect.replwrap.PEXPECT_PROMPT,
        pexpect.replwrap.PEXPECT_CONTINUATION_PROMPT)

    implementation = 'TightenerTQL'
    implementation_version = '1.0'
    language = 'TightenerTQL'
    language_version = '0.0.7'
    language_info = {
        'name': 'TightenerTQL',
        'mimetype': 'text/plain',
        'file_extension': '.tql'
    }
    banner = "TightenerTQL Kernel"

    def do_execute(self, code, silent, store_history=True, user_expressions=None,
                   allow_stdin=False):


        if not silent:
            stream_content = {'name': 'stdout', 
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
    IPKernelApp.launch_instance(kernel_class=TightenerKernel)
