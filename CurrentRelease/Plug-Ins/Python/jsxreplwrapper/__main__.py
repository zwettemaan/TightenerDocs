# To install:
#
# jupyter kernelspec install "${TIGHTENER_RELEASE_ROOT}Plug-Ins/Python/jsxreplwrapper"
#
# jupyter kernelspec install "%TIGHTENER_RELEASE_ROOT%Plug-Ins\Python\jsxreplwrapper"
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
# rm -f /usr/local/share/jupyter/kernels/jsxreplwrapper
# ln -s "${TIGHTENER_RELEASE_ROOT}Plug-Ins/Python/jsxreplwrapper" /usr/local/share/jupyter/kernels/jsxreplwrapper
# rm -f /usr/local/lib/python3.10/site-packages/jsxreplwrapper
# ln -s "${TIGHTENER_RELEASE_ROOT}Plug-Ins/Python/jsxreplwrapper" /usr/local/lib/python3.10/site-packages/jsxreplwrapper
# killApps
# jupyter notebook


import pexpect.replwrap
import sys
import os
from ipykernel.kernelbase import Kernel
from ipykernel.kernelapp import IPKernelApp


class JSXTightenerKernel(Kernel):

    os.environ["RRE_PROMPT"] = pexpect.replwrap.PEXPECT_PROMPT
    os.environ["RRE_PROMPT_CONTINUATION"] = pexpect.replwrap.PEXPECT_CONTINUATION_PROMPT

    tightenerJSXWrapper = pexpect.replwrap.REPLWrapper(
        "bash -c 'rre_Jupyter InDesign'",
        pexpect.replwrap.PEXPECT_PROMPT,
        None,
        pexpect.replwrap.PEXPECT_PROMPT,
        pexpect.replwrap.PEXPECT_CONTINUATION_PROMPT)

    implementation = 'TightenerJSX'
    implementation_version = '1.0'
    language = 'TightenerJSX'
    language_version = '0.0.7'
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
