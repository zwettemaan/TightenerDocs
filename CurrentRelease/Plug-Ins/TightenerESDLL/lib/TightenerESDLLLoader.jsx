// Uncomment some of these for debugging
// var LOAD_DEBUG_TIGHTENER = 1;
// var TIGHTENER_GIT_ROOT="C:\\Users\\USERNAME\\Documents\\Controlled\\Rorohiko\\TightenerComponents\\Tightener\\";
// var TIGHTENER_GIT_ROOT="/Users/USERNAME/Documents/Controlled/Rorohiko/TightenerComponents/Tightener/";

// ------

var LOAD_DEBUG_TIGHTENER;
var TIGHTENER_GIT_ROOT;
var TIGHTENER;
var IS_LOG_OUTPUT_TO_ESTK_CONSOLE = true;

if (LOAD_DEBUG_TIGHTENER || "undefined" == typeof(TIGHTENER)) {

    TIGHTENER = function() {

        var lib = undefined;

        do {

            var scriptFileName = $.global.TIGHTENER_SCRIPT_FILENAME_OVERRIDE;
            if (! scriptFileName) {
                scriptFileName = $.fileName;
            }

            var scriptFolder = File(scriptFileName).parent;
            Folder.current = scriptFolder;

            var isDebug = LOAD_DEBUG_TIGHTENER;
            var configSuffix = (isDebug ? "D" : "R");

            var isWin = (File.fs == "Windows");
            var fileNameExtension = (isWin) ? ".dll" : ".framework";
            var x32Suffix = "_x32";
            var x64Suffix = "_x64";
            var libFileName = "TightenerESDLL";

            var lib32Filename = libFileName + x32Suffix + configSuffix + fileNameExtension;
            var lib64Filename = libFileName + x64Suffix + configSuffix + fileNameExtension;

            var libPath32 = undefined;
            var libPath64 = undefined;
            if (isDebug) {

                if (! TIGHTENER_GIT_ROOT) {
                    TIGHTENER_GIT_ROOT = $.getenv("TIGHTENER_GIT_ROOT");
                }

                if (! TIGHTENER_GIT_ROOT) {
                    break;
                }

                TIGHTENER_GIT_ROOT = Folder(TIGHTENER_GIT_ROOT);
                if (! TIGHTENER_GIT_ROOT.exists) {
                    break;
                }

                var TIGHTENER_DLL_GIT_ROOT = Folder(TIGHTENER_GIT_ROOT.parent + "/TightenerDLL");
                if (! TIGHTENER_DLL_GIT_ROOT.exists) {
                    break;
                }

                if (isWin) {

                    // ESTK still works on Windows, so we still have use for a 32-bit version

                    var TIGHTENER_DLL_VISUALSTUDIO_ROOT = Folder(TIGHTENER_DLL_GIT_ROOT + "/VisualStudio");
                    if (! TIGHTENER_DLL_VISUALSTUDIO_ROOT.exists) {
                        break;
                    }

                    libPath32 = TIGHTENER_DLL_VISUALSTUDIO_ROOT.fsName + "/Compiled/Win32/ESDLLDebug/" + lib32Filename;
                    libPath64 = TIGHTENER_DLL_VISUALSTUDIO_ROOT.fsName + "/Compiled/x64/ESDLLDebug/" + lib64Filename;
                }
                else {

                    // No 32-bit version for Mac

                    var TIGHTENER_DLL_XCODE_ROOT = Folder(TIGHTENER_DLL_GIT_ROOT + "/Xcode");
                    if (! TIGHTENER_DLL_XCODE_ROOT.exists) {
                        break;
                    }

                    libPath64 = TIGHTENER_DLL_XCODE_ROOT.fsName + "/Compiled/Debug/" + lib64Filename;
                }
            }
            else {

                var TIGHTENER_RELEASE_ROOT = $.getenv("TIGHTENER_RELEASE_ROOT");

                var TIGHTENER_RELEASE_ROOT =
                    TIGHTENER_RELEASE_ROOT ?
                        Folder(TIGHTENER_RELEASE_ROOT) :
                        undefined;

                TIGHTENER_RELEASE_ROOT =
                    (TIGHTENER_RELEASE_ROOT && TIGHTENER_RELEASE_ROOT.exists) ?
                        TIGHTENER_RELEASE_ROOT :
                        undefined;

                var TIGHTENER_ESDLL_LIB =
                    TIGHTENER_RELEASE_ROOT ?
                        Folder(TIGHTENER_RELEASE_ROOT + "/Plug-Ins/TightenerESDLL/lib") :
                        undefined;

                TIGHTENER_ESDLL_LIB =
                    (TIGHTENER_ESDLL_LIB && TIGHTENER_ESDLL_LIB.exists) ?
                        TIGHTENER_ESDLL_LIB :
                        undefined;

                if (TIGHTENER_ESDLL_LIB) {
                    if (isWin) {
                        libPath32 = TIGHTENER_ESDLL_LIB.fsName + "/win32/" + lib32Filename;
                        if (! File(libPath32).exists) {
                            libPath32 = undefined;
                        }

                        libPath64 = TIGHTENER_ESDLL_LIB.fsName + "/win64/" + lib64Filename;
                        if (! File(libPath64).exists) {
                            libPath64 = undefined;
                        }
                    }
                    else {
                        libPath64 = TIGHTENER_ESDLL_LIB.fsName + "/mac64/" + lib64Filename;
                        if (! File(libPath64).exists) {
                            libPath64 = undefined;
                        }
                    }
                }

                if (! libPath32) {
                    if (isWin) {
                        libPath32 = Folder.current.fsName + "/win32/" + lib32Filename;
                        if (! File(libPath32).exists) {
                            libPath32 = undefined;
                        }
                    }
                }

                if (! libPath64) {
                    if (isWin) {
                        libPath64 = Folder.current.fsName + "/win64/" + lib64Filename;
                        if (! File(libPath64).exists) {
                            libPath64 = undefined;
                        }
                    }
                    else {
                        libPath64 = Folder.current.fsName + "/mac64/" + lib64Filename;
                        if (! File(libPath64).exists) {
                            libPath64 = undefined;
                        }
                    }
                }
            }

            function tryLib(libPath) {

                var file = new File(libPath);
                var lib = undefined;
                if (file.exists) {
                    try {
                        lib = new ExternalObject("lib:" + file.fsName);
                    }
                    catch (err) {
                    }
                    if (! lib && isWin) {

                        try {

                            var tempFolder = Folder(Folder.temp + "/TIGHTENERTemp");
                            if (! tempFolder.exists) {
                                tempFolder.create();
                            }
                            var tempFile = File(tempFolder + "/" + file.name);
                            if (tempFile.exists) {
                                tempFile.remove();
                            }

                            file.copy(tempFile);

                            if (tempFile.exists) {
                                lib = new ExternalObject("lib:" + tempFile.fsName);
                            }
                        }
                        catch (err) {
                        }

                    }
                }
                return lib;
            }

            // Use previously loaded lib, if any
            lib = TIGHTENER.lib;
            if (! lib) {
                lib = tryLib(libPath64);
                if (! lib && libPath32) {
                    lib = tryLib(libPath32);
                }
                TIGHTENER.lib = lib;
            }
        }
        while (false);

        return lib;
    };


    // dQ: Wrap a string in double quotes
    TIGHTENER.dQ = function(s) {
        return '"' + s.replace(/\\/g,"\\\\").replace(/"/g,'\\"').replace(/\n/g,"\\n").replace(/\r/g,"\\r") + '"';
    }

    // sQ: Wrap a string in single quotes
    TIGHTENER.sQ = function(s) {
        return "'" + s.replace(/\\/g,"\\\\").replace(/'/g,"\\'").replace(/\n/g,"\\n").replace(/\r/g,"\\r") + "'";
    }

    TIGHTENER.evalExtendScript = function(script, callback) {
        TIGHTENER.scriptQueue.push({
            script: script,
            callback: callback
        })
    };

    TIGHTENER.registerLocalHostName = function(hostName) {

        try {
            TIGHTENER.lib.tghRegisterLocalHostName(hostName);
        }
        catch (err) {
            TIGHTENER.lastError = err;
        }

    }

    TIGHTENER.relayHostMessage = function(hostName, message) {

        try {
            TIGHTENER.lib.tghRelayHostMessage(hostName, message);
        }
        catch (err) {
            TIGHTENER.lastError = err;
        }

    }

    TIGHTENER.stringize = function(data) {

        var retVal = undefined;

        do {
            if (data === null) {
                retVal = "null";
                break;
            }

            if (data === true) {
                retVal = "true";
                break;
            }

            if (data === false) {
                retVal = "false";
                break;
            }

            var dataType = typeof data;
            if ("undefined" == dataType) {
                retVal = "undefined";
                break;
            }

            if ("number" == dataType) {
                retVal = "" + data;
                break;
            }

            if ("string" == dataType) {
                retVal = TIGHTENER.dQ(data);
                break;
            }

            if ("object" != dataType) {
                retVal = data.toString();
                break;
            }

            if (data instanceof Array) {

                retVal = "[";

                var separator = "";
                for (var idx = 0; idx < data.length; idx++) {
                    retVal += separator + TIGHTENER.stringize(data[idx]);
                    if (! separator) {
                        separator = ",";
                    }
                }

                retVal += "]";
                break;
            }

            retVal = "{";

            var separator = "";
            for (var attr in data) {
                retVal += separator + TIGHTENER.dQ(attr) + ":" + TIGHTENER.stringize(data[attr]);
                if (! separator) {
                    separator = ",";
                }
            }

            retVal += "}";

        }
        while (false);

        return retVal;
    }

    TIGHTENER.shutdown = function() {

        try {
            TIGHTENER.lib.tghShutdown();
        }
        catch (err) {
            TIGHTENER.lastError = err;
        }

    }

    TIGHTENER.init = function(coordinatorName) {

        if (! TIGHTENER.lib) {
            TIGHTENER();
        }

        if (! TIGHTENER.initialized) {

            try {
                TIGHTENER.lib.tghInit(coordinatorName);
            }
            catch (err) {
                TIGHTENER.lastError = err;
            }

            TIGHTENER.terminate = false;
            TIGHTENER.initialized = true;
        }
    }

    TIGHTENER.run = function() {

        do {

            if (! TIGHTENER.lib) {
                break;
            }

            if (TIGHTENER.inRun) {
                break;
            }

            TIGHTENER.inRun = true;

            try {

                while (getLogMessageQueueSize()) {
                    if (IS_LOG_OUTPUT_TO_ESTK_CONSOLE && app.name == "ExtendScript Toolkit") {
                        var message = getLogMessage();
                        $.writeln(message);
                    }
                    advanceLogMessageQueue();
                }

                while (getHostMessageQueueSize()) {
                    // Throw messages in the bit bucket - we're not writing
                    // a gateway in ExtendScript
                    advanceHostMessageQueue();
                }

                if (getScriptQueueSize()) {

                    var script = getScript();
                    var result = undefined;
                    var error = undefined;
                    if (script) {
                        var error = undefined;
                        try {
                            result = eval(script);
                        }
                        catch (err) {
                            error = err;
                        }
                    }

                    reportScriptCompleted(error, result);

                    advanceScriptQueue();
                }
            }
            catch (err) {
                TIGHTENER.lastError = err;
            }

            TIGHTENER.inRun = false;
        }
        while (false);

        function advanceHostMessageQueue() {

            try {
                TIGHTENER.lib.tghAdvanceHostMessageQueue();
            }
            catch (err) {
                TIGHTENER.lastError = err;
            }

        };

        function advanceLogMessageQueue() {

            try {
                TIGHTENER.lib.tghAdvanceLogMessageQueue();
            }
            catch (err) {
                TIGHTENER.lastError = err;
            }

        };

        function advanceScriptQueue() {

            try {
                TIGHTENER.lib.tghAdvanceScriptQueue();
            }
            catch (err) {
                TIGHTENER.lastError = err;
            }

        };

        function getHostMessage() {

            var retVal = undefined;

            try {
                retVal = TIGHTENER.lib.tghGetHostMessage();
            }
            catch (err) {
                TIGHTENER.lastError = err;
                retVal = undefined;
            }

            return retVal;
        }

        function getHostMessageQueueSize() {

            var retVal = 0;

            try {
                retVal = TIGHTENER.lib.tghGetHostMessageQueueSize();
            }
            catch (err) {
                TIGHTENER.lastError = err;
                retVal = 0;
            }

            return retVal;
        }

        function getHostMessageTargetHost() {

            var retVal = undefined;

            try {
                retVal = TIGHTENER.lib.tghGetHostMessageTargetHost();
            }
            catch (err) {
                TIGHTENER.lastError = err;
                retVal = undefined;
            }

            return retVal;
        }

        function getLogMessage() {

            var retVal = undefined;

            try {
                retVal = TIGHTENER.lib.tghGetLogMessage();
            }
            catch (err) {
                TIGHTENER.lastError = err;
                retVal = undefined;
            }

            return retVal;
        }

        function getLogMessageQueueSize() {

            var retVal = 0;

            try {
                retVal = TIGHTENER.lib.tghGetLogMessageQueueSize();
            }
            catch (err) {
                TIGHTENER.lastError = err;
                retVal = 0;
            }

            return retVal;
        }

        function getScript() {

            var retVal = undefined;

            try {
                retVal = TIGHTENER.lib.tghGetScript();
            }
            catch (err) {
                TIGHTENER.lastError = err;
                retVal = undefined;
            }

            return retVal;
        }

        function getScriptQueueSize() {

            var retVal = 0;

            try {
                retVal = TIGHTENER.lib.tghGetScriptQueueSize();
            }
            catch (err) {
                TIGHTENER.lastError = err;
                retVal = 0;
            }

            return retVal;
        }

        function reportScriptCompleted(error, result) {

            try {

                if (error) {
                    error = error.toString();
                }

                TIGHTENER.lib.tghReportScriptCompleted(
                    TIGHTENER.stringize(error),
                    TIGHTENER.stringize(result));
            }
            catch (err) {
                TIGHTENER.lastError = err;
            }
        }
    }

}

try {
    if (TIGHTENER != $.global.TIGHTENER) {
        $.global.TIGHTENER = TIGHTENER;
    }
}
catch (err) {
    TIGHTENER.lastError = err;
}

TIGHTENER;
