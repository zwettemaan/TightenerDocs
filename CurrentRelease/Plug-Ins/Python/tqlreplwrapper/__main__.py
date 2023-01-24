# To install:
#
# jupyter kernelspec install "${TIGHTENER_RELEASE_ROOT}Plug-Ins/Python/tqlreplwrapper"
#
# jupyter kernelspec install "%TIGHTENER_RELEASE_ROOT%Plug-Ins\Python\tqlreplwrapper"
#
# To run
#   jupyter notebook
# then pick kernel from dropdown
#
# To remove
#   jupyter kernelspec uninstall tqlreplwrapper
#
# List:
#   jupyter kernelspec list
#
# Problems after closing notebook web page: Kernel does not respond any more. 
# Probably because Tightener remains running but is expected to quit
#
# On my Mac, for some reason, I need to add symbolic links to the site-packages folder
# 
# ln -s "${TIGHTENER_RELEASE_ROOT}Plug-Ins/Python/tqlreplwrapper" /usr/local/share/jupyter/kernels/tqlreplwrapper
# ln -s "${TIGHTENER_RELEASE_ROOT}Plug-Ins/Python/tqlreplwrapper" /usr/local/lib/python3.10/site-packages/tqlreplwrapper
# killApps
# jupyter notebook

import pexpect.replwrap
import sys
import uuid
from ipykernel.kernelbase import Kernel
from ipykernel.kernelapp import IPKernelApp
# from debugpy.common import log

# log.to_file("/Users/kris/Desktop/tqlreplwrapper.log")

class TQLTightenerKernel(Kernel):

    # log.info("Creating TQLTightenerKernel")

    tightenerTQLWrapper = pexpect.replwrap.REPLWrapper(
        "bash -c 'rrt_Jupyter InDesign'",
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
            # log.info("running '" + code + "'")
            stream_content = {'name': 'stdout', 
                'text': self.tightenerTQLWrapper.run_command(code, None) 
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
