//
// InDesign on the target computer has to be running before issuing the `rre` (Run Remote ExtendScript) command.
// 
// When targeting a remote computer, you also need to make sure the gateway coordinator on that
// comnputer is running before issuing the `rre` command.
//
// E.g. on the remotemachine, first run `killApps`, and then run the `gwui` or 
// `gwConsole` command, and launch InDesign with `idLaunch`
// 
// Make sure to install the plug-in beforehand with `idPluginInstall`
// or run the Tightener Daemon CEP extension in InDesign
//

var IS_SERVER = ("serverSettings" in app);

function enquote(s) {
    return '"' + s.replace(/\\/g,"\\\\").replace(/"/g,'\\"').replace(/\n/g,"\\n").replace(/\r/g,"\\r") + '"';
}

 function feedBack(message) { 
    if (IS_SERVER) {
        alert(message);
    }
    app.evalTQL("stdOut(" + enquote(message) + ")");
}

function makeDoc() {

    var retVal = "failed";

    try {
        var desktop = Folder.desktop;

        var docNum = 1;
        var outputPDFFile = File(desktop + "/t" + docNum + ".pdf");
        while (outputPDFFile.exists)
        {
            ++docNum;
            outputPDFFile = File(desktop + "/t" + docNum + ".pdf");
        }

        var doc = app.documents.add();
        var spread = doc.spreads[0];
        var textFrame = spread.textFrames.add();
        textFrame.contents = "This is some text";
        textFrame.geometricBounds = [5, 5, 80, 80];    

        doc.exportFile(ExportFormat.PDF_TYPE, outputPDFFile);
        if (! IS_SERVER) {
            app.waitForAllTasks();
        }
        
        doc.close(SaveOptions.NO);

        retVal = "done";

    }
    catch (err) {
        retVal = "failed";
    }

    return retVal;
}

if (! IS_SERVER) {
    app.scriptPreferences.userInteractionLevel = UserInteractionLevels.NEVER_INTERACT;
}

feedBack("idMakePDF.jsx");

var result = makeDoc();

feedBack("result: " + result);