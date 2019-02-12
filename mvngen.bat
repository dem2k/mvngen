@echo off
@setlocal

set starteclipsebat=zz_start_eclipse.bat

if not "%_CMDPROC%" == "" (
	echo.
	echo WARN: This script is working only with CDM.EXE!
	goto fehler
)

if "%WGET_OPTIONS%"=="" set WGET_OPTIONS=--no-check-certificate
if "%WGET_OPTIONS:no-check-certificate=%"=="%WGET_OPTIONS%" set WGET_OPTIONS=%WGET_OPTIONS% --no-check-certificate

echo.
set /p runide="Run IDE and import Preferences and existing Maven Projects? [(I)dea/(E)clipe/(N)one] : "

set prjname=%1
if "%prjname%" == "" (
	echo.
	set /p prjname="Please enter Project Name (this is the maven artifactId) : "
)

if "%prjname%" == "" (
	echo.
	echo ERROR: Project name can not be empty!
	goto ende
)

echo.
echo starting maven archetype plugin ...
call mvn archetype:generate -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.1 -DgroupId=simple -DartifactId=%prjname% -Dversion=1.0-SNAPSHOT 
if errorlevel 1 goto fehler

cd %prjname%
if errorlevel 1 goto fehler

@rem -------- add log4j and junit to pom --------------
echo.
echo modifying pom.xml ...
rem sed "s#</dependencies>#<dependency><groupId>ch.qos.logback</groupId><artifactId>logback-classic</artifactId><version>1.1.2</version></dependency></dependencies>#g" pom.xml >pom.tmp
rem sed "s#</dependencies>#<dependency><groupId>org.apache.logging.log4j</groupId><artifactId>log4j-core</artifactId><version>2.9.1</version></dependency></dependencies>#g" pom.xml >pom.tmp
set RE1="s#</dependencies>#<dependency><groupId>org.slf4j</groupId><artifactId>slf4j-api</artifactId><version>1.7.25</version></dependency><dependency><groupId>ch.qos.logback</groupId><artifactId>logback-classic</artifactId><version>1.2.3</version></dependency></dependencies>#g"
set RE2="s#</properties>#<java.version>1.8</java.version><findbugs.version>3.0.1</findbugs.version></properties>#g"
set RE3="s#<version>3.8.1</version>#<version>4.12</version>\n<!--<exclusions><exclusion><groupId>org.hamcrest</groupId><artifactId>hamcrest-core</artifactId></exclusion></exclusions>-->#g"
set RE4="s#</project>#<build><plugins>\n<plugin><groupId>org.apache.maven.plugins</groupId><artifactId>maven-compiler-plugin</artifactId><version>3.8.0</version><configuration><source>${java.version}</source><target>${java.version}</target></configuration></plugin>\n</plugins></build>\n</project>#g"
set RE5="s#</plugins>#<!--\n<plugin><groupId>org.codehaus.mojo</groupId><artifactId>findbugs-maven-plugin</artifactId><version>${findbugs.version}</version></plugin>\n-->\n</plugins>#g"
set RE6="s#</plugins>#\n<!-- for jetty-run add to your pom.xml under /project/build/plugins/ \(http://www.eclipse.org/jetty/documentation/current/jetty-maven-plugin.html\)\n<plugin><groupId>org.eclipse.jetty</groupId><artifactId>jetty-maven-plugin</artifactId><configuration><webApp><contextPath>/%prjname%</contextPath></webApp></configuration></plugin>\n-->\n</plugins>#g"
set RE7="s#</build>#</build>\n<!--\n<reporting><plugins><plugin><groupId>org.codehaus.mojo</groupId><artifactId>findbugs-maven-plugin</artifactId><version>${findbugs.version}</version></plugin></plugins></reporting>\n-->#g"

@for %%i in (%RE1% %RE2% %RE3% %RE4% %RE5% %RE6% %RE7%) do (
   cat pom.xml | sed %%i > pom.new
   move pom.new pom.xml >nul 
)

@rem --- log4j -----------
echo.
echo creating log4j.properties ^& logback.xml ...
mkdir src\main\resources
pushd src\main\resources
wget %WGET_OPTIONS% https://raw.githubusercontent.com/dem2k/mvngen/master/log4j2.xml
wget %WGET_OPTIONS% https://raw.githubusercontent.com/dem2k/mvngen/master/log4j.properties
wget %WGET_OPTIONS% https://raw.githubusercontent.com/dem2k/mvngen/master/logback.xml
popd
@rem --------------

(
 echo @call mvn compile
 echo @if errorlevel 1 pause
) >mvn-compile.bat 

(
 echo @SET ROOT=%prjname%
 echo @SET PORT=8080
 echo SET MAVEN_OPTS=-Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,address=5%%PORT%%,server=y,suspend=n
 echo SET MAVEN_CMD=mvn -DskipTests -Djetty.reload=automatic -Djetty.scanIntervalSeconds=5 -Djetty.port=%%PORT%% -Djetty.contextPath=/%%ROOT%% jetty:run
 echo @TITLE JETTY %%MAVEN_CMD%%
 echo @START "" http://localhost:%%port%%/%%root%%/application.wadl
 echo @CALL %%MAVEN_CMD%%
 echo @IF ERRORLEVEL 1 PAUSE
 echo @REM -Djetty.scanIntervalSeconds=5
 echo @REM    The pause in seconds between sweeps of the webapp to check for changes and automatically hot redeploy if any are detected. By default this is 0, which disables hot deployment scanning. A number greater than 0 enables it.
 echo @REM -Djetty.reload=automatic
 echo @REM    Default value is "automatic", used in conjunction with a non-zero scanIntervalSeconds causes automatic hot redeploy when changes are detected. Set to "manual" instead to trigger scanning by typing a linefeed in the console running the plugin. This might be useful when you are doing a series of changes that you want to ignore until you're done. In that use, use the reload parameter.
) >mvn-jetty-run.bat

(
 echo @call mvn findbugs:gui
 echo @if errorlevel 1 pause
) >mvn-findbugs-gui.bat

(
 echo @call mvn dependency:sources dependency:resolve -Dclassifier=javadoc
 echo @if errorlevel 1 pause
) >mvn-dependency-sources-javadoc.bat

(
 echo @call mvn compile findbugs:check
 echo @if errorlevel 1 pause
) >mvn-findbugs-check.bat

(
 echo @call mvn dependency:copy-dependencies
 echo @if errorlevel 1 pause
) >mvn-copy-dependencies.bat

(
 echo @call mvn dependency:tree
 echo @if errorlevel 1 pause
) >mvn-dependency-tree.bat

(
 echo @call mvn com.github.ekryd.sortpom:sortpom-maven-plugin:verify
 echo @if errorlevel 1 pause
) >mvn-sortpom-verify.bat 

(
 echo @call mvn eclipse:eclipse
 echo @if errorlevel 1 pause
) >mvn-eclipse-eclipse.bat 

(
 echo @call mvn findbugs:gui
 echo @if errorlevel 1 pause
) >mvn-findbugs-gui.bat

(
 echo @mvn eclipse:configure-workspace -Declipse.workspace=c:\xtest
 echo @if errorlevel 1 pause
) >mvn-eclipse-configure-workspace.bat 

(
 echo @echo off
 echo set CLASSPATH=%%~dp0target\classes;%%~dp0config
 echo for %%%%i in ^("%%~dp0target\dependency\*.jar"^) do call :addcp %%%%i
 echo java %%*
 echo goto ende
 echo :addcp
 echo set CLASSPATH=%%1;%%CLASSPATH%%
 echo :ende
) >class-runner.bat

(
 echo @call %%~dp0class-runner.bat some.package.MainClass %%*
 echo @if errorlevel 1 pause
) >class-runner-usage-example.bat

(
 echo @call mvn exec:java -Dexec.mainClass="d2k.App" -Dexec.args="argument1" -Dexec.args="argument2"
 echo @if errorlevel 1 pause
) >mvn-exec-java.bat 

(
 echo @echo off
 echo set report=
 echo set /p report="Run tests? [y/N] : "
 echo if "%%report%%" == "" goto ronly
 echo call mvn surefire-report:report
 echo goto finish
 echo :ronly
 echo call mvn surefire-report:report-only
 echo :finish
 echo if errorlevel 1 pause
 echo start target/site/surefire-report.html
) >mvn-surefire-report.bat

cd ..

REG Query HKEY_CLASSES_ROOT\Applications\idea.exe\shell\open\command |grep bin |sed "s/(Standard)    REG_SZ/START \"\"/g" |sed "s/%%1/%prjname%/g" >zz_start_intellij_idea.bat

(
 echo @REM SET JAVA_HOME=%%~dps0jdk
 echo @REM SET ECLIPSE_HOME=%%~dps0eclipse
 echo @REM SET PATH=%%JAVA_HOME%%\bin;%%PATH%%
 echo @REM SET MOPTS=-Xms512M -Xmx1024M
 echo @REM SET GOPTS=-XX:+UseParallelGC -XX:+UseParallelOldGC
 echo @REM SET XOPTS=-XX:NewRatio=1 -XX:SurvivorRatio=6 -XX:MaxTenuringThreshold=0 -XX:TargetSurvivorRatio=75
 echo @REM SET PAGOPTS=-XX:+UseLargePages -XX:LargePageSizeInBytes=4M
 echo @REM SET POPTS=-XX:PermSize=128M -XX:MaxPermSize=256M
 echo.
 echo START %%ECLIPSE_HOME%%\eclipse.exe -data %%~dps0workspace -showlocation -vmargs %%MOPTS%% %%GOPTS%% %%XOPTS%% %%PAGOPTS%% %%POPTS%%
) >%starteclipsebat%

(
 echo SET DRV=N:
 echo SUBST %%DRV%% .
 echo IF ERRORLEVEL 1 PAUSE
 echo %%~D0
 echo CD %%~DP0
 echo "%%COMMANDER_EXE%%" /O /S "%%DRV%%"
) >map-drive.bat

( echo SET PRJDRV=N
  echo IF EXIST %%PRJDRV%%:\%%~NX0 GOTO finish
  echo %%~D0
  echo CD "%%~DP0"
  echo SUBST %%PRJDRV%%: /D
  echo SUBST %%PRJDRV%%: .
  echo IF ERRORLEVEL 1 PAUSE
  echo :finish
  echo %%PRJDRV%%:
  echo CD %%PRJDRV%%:\
  echo "%%COMMANDER_EXE%%" /O /S "%%PRJDRV%%:\"
) >map-drive-for-%prjname%.bat

( type map-drive-for-%prjname%.bat
  type %starteclipsebat%
) > map-drive-and-start-eclipse.bat

( echo @echo off
  echo wget %%WGET_OPTIONS%% https://raw.githubusercontent.com/dem2k/mvngen/master/eclipse-preferences.epf
  echo wget %%WGET_OPTIONS%% https://raw.githubusercontent.com/dem2k/mvngen/master/import-preferenses-and-projects.ahk
  echo wget %%WGET_OPTIONS%% https://raw.githubusercontent.com/dem2k/mvngen/master/import-maven-projects.ahk
  echo echo.
  echo set /p runide="Run Eclipse and import Preferences and existing Maven Projects? [Y/n] : "
  echo if "%%runide%%" == "" goto runeclipse
  echo if "%%runide%%" == "y" goto runeclipse
  echo if "%%runide%%" == "Y" goto runeclipse
  echo goto ende
  echo :runeclipse
  echo echo.
  echo echo configuring eclipse workspace ...
  echo call mvn eclipse:configure-workspace "-Declipse.workspace=."
  echo echo.
  echo echo starting eclipse...
  echo start import-preferenses-and-projects.ahk
  echo call zz_start_eclipse.bat
  echo :ende
) >wget-download-eclipse-scripts.bat

goto finish

:fehler
pause
goto ende

:finish
if "%runide%" == "" goto ende
if "%runide%" == "i" goto runidea
if "%runide%" == "I" goto runidea
if "%runide%" == "e" goto runeclipse
if "%runide%" == "E" goto runeclipse
goto ende

:runeclipse
echo.
echo creating ahk scripts ...
wget %WGET_OPTIONS% https://raw.githubusercontent.com/dem2k/mvngen/master/eclipse-preferences.epf
wget %WGET_OPTIONS% https://raw.githubusercontent.com/dem2k/mvngen/master/import-preferenses-and-projects.ahk
wget %WGET_OPTIONS% https://raw.githubusercontent.com/dem2k/mvngen/master/import-maven-projects.ahk
echo starting eclipse...
echo.
echo configuring eclipse workspace ...
call mvn eclipse:configure-workspace "-Declipse.workspace=."
start import-preferenses-and-projects.ahk
call %starteclipsebat%
goto ende

:runidea
echo starting idea...
call zz_start_intellij_idea.bat
goto ende

:ende
@endlocal
