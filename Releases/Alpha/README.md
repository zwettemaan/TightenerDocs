# Unstable, variable release

# Alpha Releases

## Version 0.1.1

Seventh alpha release, 6-Nov-2023

https://cloud.rorohiko.com/index.php/s/6q4TCOJ7w4fnPst

Much debugging and fixing. The ESDLL and Xojo versions (ExtendScript DLL/Xojo plugin) 
now use a separate C++ thread to run the main Tightener core, so it remains responsive even 
when the host app is not paying attention (e.g. running a script). This makes the Tightener 
communications a fair bit faster, and the host app remains responsive for Tightener nodes 
even when the TightenerDaemon panel is not active. The main effect of having the daemon 
inactive is that you cannot launch ExtendScripts remotely, but you can still run TQL scripts.

## Version 0.1.0

Sixth alpha release, 23-Apr-2023

https://cloud.rorohiko.com/index.php/s/3JnnSYNAMTbO32Q

This version adds support for ARM64 on Windows and Linux.
The reason for that is that I've got a new M2 MacBook Pro, 
and I wanted to be able to build and test Tightener on it.

I've made new build scripts which can cross-compile to ARM64 
on x64 systems and also cross-compile to x64 on ARM64 systems.
This is what I am now using on my M2 Mac - the Mac build is
done on the machine itself, and the Linux and Windows builds are 
done on ARM64 virtual machines (Ubuntu Linux and Windows 11)
which then also compile the x64 components for Tightener 
(including InDesign plug-ins)

## Version 0.0.9

Fifth alpha release, 21-Feb-2023

https://cloud.rorohiko.com/index.php/s/jpRW3RnaZSjDG8R

## Version 0.0.8

Fourth alpha release, 6-Feb-2023

https://cloud.rorohiko.com/index.php/s/VLbxiACYx5WoPSl

## Version 0.0.7

Third alpha release, 3-Feb-2023

https://cloud.rorohiko.com/index.php/s/6JKR2vCivkWIN6u

## Version 0.0.6

Second alpha release, 14-Sep-2022

https://cloud.rorohiko.com/index.php/s/hEPHdmtFvrbxFuU

## Version 0.0.5

First alpha release, 13-Aug-2022

https://cloud.rorohiko.com/index.php/s/26rb16f8X0v1gqA
