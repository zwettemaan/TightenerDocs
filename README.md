# TightenerDocs

Documentation for the Tightener project

[Wiki](https://github.com/zwettemaan/TightenerDocs/wiki)

Cmaps are drawn using:

https://cmap.ihmc.us/

# Installing Tightener

* For the absolutely latest, possibly broken 'work-in-progress':

Download the .zip file for this repo

https://github.com/zwettemaan/TightenerDocs/archive/refs/heads/main.zip

Decompress, and navigate into the 'CurrentRelease' folder

Run the script install.command (Mac/Linux) or install.bat (Windows)

* For a stable alpha version, find your download here:

https://github.com/zwettemaan/TightenerDocs/tree/main/Releases/Alpha

Decompress, and navigate into the 'CurrentRelease' folder

Run the script install.command (Mac/Linux) or install.bat (Windows)

# Installing Tightener with Jupyter Notebooks

## Mac

Start a Terminal window:

### Command Line Tools

Optional - Homebrew will automatically do this if need be.

Install the Mac OS X Command line tools from Apple (if not already installed):
```
xcode-select --install
```

### Homebrew

Install Homebrew (https://brew.sh/). 

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

You could also use MacPorts instead of Homebrew - I'm not covering that here, but the approach is similar to Homebrew (https://www.macports.org/)

### Python 3

Check what version of python (if any) is installed:
```
python --version
python2 --version
python3 --version
```

If both commands return an error, there is a chance you don't yet have any Python installed.

If you have a version installed, but it is version 2.x.x, you'll need to upgrade to Python 3.

The following procedure should cover both cases.

Install python3
```
brew install python3
```
Verify installation:
```
python3 --version
pip3 --version
```
Upgrade as needed:
```
pip3 install --upgrade pip
```

If you need multiple versions of Python installed, and you want to manage multiple versions of python side-by-side, make sure to look at things like:

```
brew link python@x.x
brew unlink python@x.x
```

Might need to verify `/usr/local/bin` is on the `PATH` before `/usr/bin` in order to override the default `python` from Apple.

And managers like:

pyenv    
pip    
virtualenv    
anaconda    

which all provide somewhat similar, more or less overlapping functionality.

https://www.anaconda.com/blog/understanding-conda-and-pip
https://codesolid.com/conda-vs-pip/
https://stackoverflow.com/questions/38217545/what-is-the-difference-between-pyenv-virtualenv-anaconda
https://stackoverflow.com/questions/64362772/switching-python-version-installed-by-homebrew

### Install needed python modules

```
pip3 install pexpect
```

### Install Jupyter

Beforehand, I avoid error messages by adding the python binary dir to the path: add to .zshenv en .profile, something like

```
python3 --version
```
-> e.g. Python 3.9.6
```
export PYTHON_MAIN_VERSION=3.9
export PATH=$PATH:/Users/kris/Library/Python/${PYTHON_MAIN_VERSION}/bin
export SITE_PACKAGES=~/Library/Python/${PYTHON_MAIN_VERSION}/lib/python/site-packages
```

On my main Mac, I have 
```
export PYTHON_MAIN_VERSION=3.10
export PATH=$PATH:/usr/local/bin
export SITE_PACKAGES=/usr/local/lib/python${PYTHON_MAIN_VERSION}/site-packages
```

Install Jupyter:
```
pip3 install jupyter
```
Verify installation:
```
jupyter notebook
```

Install the kernels (using Python 3.9 in the example below):

```
killApps
ln -s "${TIGHTENER_RELEASE_ROOT}Plug-Ins/Python/tqlreplwrapper" /usr/local/share/jupyter/kernels/tqlreplwrapper
ln -s "${TIGHTENER_RELEASE_ROOT}Plug-Ins/Python/tqlreplwrapper" ${SITE_PACKAGES}/tqlreplwrapper
ln -s "${TIGHTENER_RELEASE_ROOT}Plug-Ins/Python/jsxreplwrapper" /usr/local/share/jupyter/kernels/jsxreplwrapper
ln -s "${TIGHTENER_RELEASE_ROOT}Plug-Ins/Python/jsxreplwrapper" ${SITE_PACKAGES}/jsxreplwrapper
ln -s "${TIGHTENER_RELEASE_ROOT}Plug-Ins/Python/idjsreplwrapper" /usr/local/share/jupyter/kernels/idjsreplwrapper
ln -s "${TIGHTENER_RELEASE_ROOT}Plug-Ins/Python/idjsreplwrapper" ${SITE_PACKAGES}/idjsreplwrapper
```

## UXPScript functions

```
function alert(msg) {

	theDialog = app.dialogs.add();

	col = theDialog.dialogColumns.add();
	colText = col.staticTexts.add();
	colText.staticLabel = '' + msg;
	theDialog.canCancel = false;

	theDialog.show();

	theDialog.destroy()
}

function evalJS(expr) { 

	try {
		eval("expr = (" + expr + ")");
	}
	catch (err) {
		expr = undefined;
	}

	return expr;
}
```

## Windows

Install Python 3

https://www.python.org/downloads/windows/

