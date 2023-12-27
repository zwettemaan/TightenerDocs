
//@include "TightenerESDLL/TightenerESDLLLoader.jsx"
var getURL = JSXGetURL();

alert(getURL.isJSXGetURLDemo());

getURL.addRequestHeader("Accept: */*");
var s = getURL.get("https://www.rorohiko.com") + "";

alert(s.substr(0,1000));

var headers = getURL.getResponseHeaders();
alert(headers);

// Some random FTP file for testing

var f = new File("~/Desktop/sha512.sum");
var s = getURL.get("ftp://cygwin.com/pub/gcc/sha512.sum", f.fsName);

// Some zip file to test binary file download

var f = new File("~/Desktop/FrameReporter.1.1.8.zip");
getURL.get("https://www.rorohiko.com/downloads/FrameReporter.1.1.8.zip", f.fsName);
