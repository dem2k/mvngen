@echo off

if not "%_CMDPROC%" == "" (
	echo.
	echo WARN: geht nur mit cmd.exe nicht mit 4nt!
	goto fehler
)

echo.
set /p runide="Run IDE and import Preferences and Existing Maven Projects? [Yes] : "

set prjname=%1
echo.
if "%prjname%" == "" (
	echo.
	set /p prjname="Please enter Projectname (this is the maven artifactId) : "
)

if "%prjname%" == "" (
	echo.
	echo ERROR: Project name can not be empty!
	goto ende
)

echo.
echo starting maven archetype plugin ...
call mvn archetype:generate -DgroupId=simple -DartifactId=%prjname%
if errorlevel 1 goto fehler

cd %prjname%
if errorlevel 1 goto fehler

@rem -------- add log4j and junit to pom --------------
echo.
echo modifying pom.xml ...
rem sed "s/<\/dependencies>/<dependency><groupId>ch.qos.logback<\/groupId><artifactId>logback-classic<\/artifactId><version>1.1.2<\/version><\/dependency><\/dependencies>/g" pom.xml >pom.tmp
sed "s/<\/dependencies>/<dependency><groupId>org.apache.logging.log4j<\/groupId><artifactId>log4j-core<\/artifactId><version>2.2<\/version><\/dependency><\/dependencies>/g" pom.xml >pom.tmp
sed "s/<\/properties>/<java.version>1.8<\/java.version><findbugs.version>3.0.1<\/findbugs.version><\/properties>/g" pom.tmp >pom.tmp1
sed "s/<version>3.8.1<\/version>/<version>4.12<\/version>\n<!--<exclusions><exclusion><groupId>org.hamcrest<\/groupId><artifactId>hamcrest-core<\/artifactId><\/exclusion><\/exclusions>-->/g" pom.tmp1 >pom.tmp2
sed "s/<\/project>/<build><plugins>\n<plugin><groupId>org.apache.maven.plugins<\/groupId><artifactId>maven-compiler-plugin<\/artifactId><version>3.3<\/version><configuration><source>${java.version}<\/source><target>${java.version}<\/target><\/configuration><\/plugin>\n<\/plugins><\/build>\n<\/project>/g" pom.tmp2 >pom.tmp3
sed "s#</plugins>#<!--\n<plugin><groupId>org.codehaus.mojo</groupId><artifactId>findbugs-maven-plugin</artifactId><version>${findbugs.version}</version></plugin>\n-->\n</plugins>#g" pom.tmp3 >pom.tmp4
sed "s#</build>#</build>\n<!--\n<reporting><plugins><plugin><groupId>org.codehaus.mojo</groupId><artifactId>findbugs-maven-plugin</artifactId><version>${findbugs.version}</version></plugin></plugins></reporting>\n-->#g" pom.tmp4 >pom.tmp5
copy pom.tmp5 pom.xml
del pom.tmp*

>>pom.xml echo ^<!-- for jetty-run add to your pom.xml under /project/build/plugins/
>>pom.xml echo    (http://www.eclipse.org/jetty/documentation/current/jetty-maven-plugin.html)
>>pom.xml echo ^<plugin^>^<groupId^>org.eclipse.jetty^</groupId^>^<artifactId^>jetty-maven-plugin^</artifactId^>^<configuration^>^<webApp^>^<contextPath^>/%prjname%^</contextPath^>^</webApp^>^</configuration^>^</plugin^>
>>pom.xml echo --^>

@rem --- log4j -----------
echo.
echo creating log4j.properties ...
mkdir src\main\resources
copy %~dpn0-log4j.properties src\main\resources\log4j.properties
copy %~dpn0-log4j2.xml src\main\resources\log4j2.xml
@rem --------------

@rem --- logback ----------------------
echo.
echo creating logback.xml ...
copy %~dpn0-logback.xml src\main\resources\logback.xml
@rem ----------------------------------

 >mvn-compile.bat echo @call mvn compile
>>mvn-compile.bat echo @if errorlevel 1 pause

 >mvn-jetty-run.bat echo @SET ROOT=%prjname%
>>mvn-jetty-run.bat echo @SET PORT=8080
>>mvn-jetty-run.bat echo SET MAVEN_OPTS=-Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,address=5%%PORT%%,server=y,suspend=n
>>mvn-jetty-run.bat echo SET MAVEN_CMD=mvn -DskipTests -Djetty.reload=automatic -Djetty.scanIntervalSeconds=5 -Djetty.port=%%PORT%% -Djetty.contextPath=/%%ROOT%% jetty:run
>>mvn-jetty-run.bat echo @TITLE JETTY %%MAVEN_CMD%%
>>mvn-jetty-run.bat echo @START "" http://localhost:%%port%%/%%root%%/application.wadl
>>mvn-jetty-run.bat echo @CALL %%MAVEN_CMD%%
>>mvn-jetty-run.bat echo @IF ERRORLEVEL 1 PAUSE
>>mvn-jetty-run.bat echo @rem -Djetty.scanIntervalSeconds=5
>>mvn-jetty-run.bat echo @rem    The pause in seconds between sweeps of the webapp to check for changes and automatically hot redeploy if any are detected. By default this is 0, which disables hot deployment scanning. A number greater than 0 enables it.
>>mvn-jetty-run.bat echo @rem -Djetty.reload=automatic
>>mvn-jetty-run.bat echo @rem    Default value is "automatic", used in conjunction with a non-zero scanIntervalSeconds causes automatic hot redeploy when changes are detected. Set to "manual" instead to trigger scanning by typing a linefeed in the console running the plugin. This might be useful when you are doing a series of changes that you want to ignore until you're done. In that use, use the reload parameter.

 >mvn-findbugs-gui.bat echo @call mvn findbugs:gui
>>mvn-findbugs-gui.bat echo @if errorlevel 1 pause

 >mvn-dependency-sources-javadoc.bat echo @call mvn dependency:sources dependency:resolve -Dclassifier=javadoc
>>mvn-dependency-sources-javadoc.bat echo @if errorlevel 1 pause

 >mvn-findbugs-check.bat echo @call mvn compile findbugs:check
>>mvn-findbugs-check.bat echo @if errorlevel 1 pause

 >mvn-copy-dependencies.bat echo @call mvn dependency:copy-dependencies
>>mvn-copy-dependencies.bat echo @if errorlevel 1 pause

 >mvn-dependency-tree.bat echo @call mvn dependency:tree
>>mvn-dependency-tree.bat echo @if errorlevel 1 pause

 >mvn-sortpom-verify.bat echo @call mvn com.google.code.sortpom:maven-sortpom-plugin:verify
>>mvn-sortpom-verify.bat echo @if errorlevel 1 pause

 >mvn-eclipse-eclipse.bat echo @call mvn eclipse:eclipse
>>mvn-eclipse-eclipse.bat echo @if errorlevel 1 pause

 >mvn-findbugs-gui.bat echo @call mvn findbugs:gui
>>mvn-findbugs-gui.bat echo @if errorlevel 1 pause

 >mvn-eclipse-configure-workspace.bat echo @mvn eclipse:configure-workspace -Declipse.workspace=c:\xtest
>>mvn-eclipse-configure-workspace.bat echo @if errorlevel 1 pause

 >class-runner.bat echo @echo off
>>class-runner.bat echo set CLASSPATH=target\classes;config
>>class-runner.bat echo for %%%%i in ("target\dependency\*.jar") do call :addcp %%%%i
>>class-runner.bat echo java %%*
>>class-runner.bat echo goto ende
>>class-runner.bat echo :addcp
>>class-runner.bat echo set CLASSPATH=%%1;%%CLASSPATH%%
>>class-runner.bat echo :ende

 >runaclass.bat echo @call %%~dp0class-runner.bat %%~n0 %%*
>>runaclass.bat echo @if errorlevel 1 pause

 >mvn-exec-java.bat echo @call mvn exec:java -Dexec.mainClass="d2k.App" -Dexec.args="argument1" -Dexec.args="argument2"
>>mvn-exec-java.bat echo @if errorlevel 1 pause

 >mvn-surefire-report.bat echo @echo off
>>mvn-surefire-report.bat echo set report=
>>mvn-surefire-report.bat echo set /p report=Run tests (ENTER=No, something else=Yes)? 
>>mvn-surefire-report.bat echo if "%%report%%" == "" goto ronly
>>mvn-surefire-report.bat echo call mvn surefire-report:report
>>mvn-surefire-report.bat echo goto finish
>>mvn-surefire-report.bat echo :ronly
>>mvn-surefire-report.bat echo call mvn surefire-report:report-only
>>mvn-surefire-report.bat echo :finish
>>mvn-surefire-report.bat echo if errorlevel 1 pause
>>mvn-surefire-report.bat echo start target/site/surefire-report.html


(
 echo @ECHO OFF
 echo SET DRV=N:
 echo SUBST %%DRV%% .
 echo IF ERRORLEVEL 1 PAUSE
 echo %%~d0
 echo CD %%~dp0
 echo "%%COMMANDER_EXE%%" /O /S "%%DRV%%"
) >map-drive.bat

 >map-drive-for-%prjname%.bat echo SET PRJDRV=N
>>map-drive-for-%prjname%.bat echo IF EXIST %%PRJDRV%%:\%%~NX0 GOTO finish
>>map-drive-for-%prjname%.bat echo %%~D0
>>map-drive-for-%prjname%.bat echo CD "%%~DP0"
>>map-drive-for-%prjname%.bat echo SUBST %%PRJDRV%%: /D
>>map-drive-for-%prjname%.bat echo SUBST %%PRJDRV%%: .
>>map-drive-for-%prjname%.bat echo IF ERRORLEVEL 1 PAUSE
>>map-drive-for-%prjname%.bat echo :finish
>>map-drive-for-%prjname%.bat echo %%PRJDRV%%:
>>map-drive-for-%prjname%.bat echo CD %%PRJDRV%%:\
>>map-drive-for-%prjname%.bat echo "%%COMMANDER_EXE%%" /O /S "%%PRJDRV%%:\"


echo.
echo configuring eclipse workspace ...
cd ..
call mvn eclipse:configure-workspace "-Declipse.workspace=."

set starteclipsebat=zz_start_eclipse.bat

(
 echo @rem set JAVA_HOME=%%~dps0jdk
 echo @rem set ECLIPSE_HOME=%%~dps0eclipse
 echo @rem set PATH=%%JAVA_HOME%%\bin;%%PATH%%
 echo @rem set MOPTS=-Xms512M -Xmx1024M
 echo @rem set GOPTS=-XX:+UseParallelGC -XX:+UseParallelOldGC
 echo @rem set XOPTS=-XX:NewRatio=1 -XX:SurvivorRatio=6 -XX:MaxTenuringThreshold=0 -XX:TargetSurvivorRatio=75
 echo @rem set PAGOPTS=-XX:+UseLargePages -XX:LargePageSizeInBytes=4M
 echo @rem set POPTS=-XX:PermSize=128M -XX:MaxPermSize=256M
 echo.
 echo start %%ECLIPSE_HOME%%\eclipse.exe -data %%~dps0. -showlocation -vmargs %%MOPTS%% %%GOPTS%% %%XOPTS%% %%PAGOPTS%% %%POPTS%%
) >%starteclipsebat%

echo.
echo creating ahk scripts ...
copy %~dpn0-eclipse-preferences.epf eclipse-preferences.epf
copy %~dpn0-prefs-and-projects.ahkx import-preferenses-and-projects.ahk
copy %~dpn0-import-maven-projects.ahk import-maven-projects.ahk

echo.
echo copy some other files ...
@rem copy %~dpn0-map-drive.batx map-drive.bat
@rem copy %~dpn0-map-drive-for-project.batx map-drive-for-%prjname%.bat
copy %~dpn0-map-drive-and-start-eclipse.batx zz_%prjname%_map_drive_and_start_eclipse.bat

goto finish

:fehler
pause

:finish
if "%runide%" == "" (
	@echo all done. starting eclipse...
	start import-preferenses-and-projects.ahk
	call %starteclipsebat%
)

:ende
