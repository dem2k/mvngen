@rem set JAVA_HOME=%~dps0jdk
@rem set ECLIPSE_HOME=%~dps0eclipse
@rem set PATH=%JAVA_HOME%\bin;%PATH%
@rem set MOPTS=-Xms512M -Xmx1024M
@rem set GOPTS=-XX:+UseParallelGC -XX:+UseParallelOldGC
@rem set XOPTS=-XX:NewRatio=1 -XX:SurvivorRatio=6 -XX:MaxTenuringThreshold=0 -XX:TargetSurvivorRatio=75
@rem set PAGOPTS=-XX:+UseLargePages -XX:LargePageSizeInBytes=4M
@rem set POPTS=-XX:PermSize=128M -XX:MaxPermSize=256M

SET PRJDRV=N
IF EXIST %PRJDRV%:\%~NX0 GOTO finish

%~D0
CD "%~DP0"

SUBST %PRJDRV%: /D
SUBST %PRJDRV%: .
IF ERRORLEVEL 1 PAUSE

:finish
%PRJDRV%:
CD %PRJDRV%:\
"%COMMANDER_EXE%" /O /S "%PRJDRV%:\"

START %ECLIPSE_HOME%\eclipse.exe -data %PRJDRV%:\. -showlocation -vmargs %MOPTS% %GOPTS% %XOPTS% %PAGOPTS% %POPTS%