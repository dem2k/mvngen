@echo off
set starteclipsebat=zz_start_eclipse.bat

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
rem call mvn archetype:create -DgroupId=deminator -DartifactId=%prjname%
rem call mvn archetype:generate -DgroupId=dem2k -DartifactId=%prjname% -DarchetypeArtifactId=com.mycodefu:executable-jar-archetype -DinteractiveMode=false
rem call mvn archetype:generate -DgroupId=dem2k -DartifactId=%prjname% -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
rem call mvn archetype:generate -DgroupId=dem2k -Dpackage=dem2k -Dversion=1.0-SNP -DartifactId=%prjname% -DarchetypeArtifactId=maven-archetype-quickstart
rem call mvn archetype:generate -DgroupId=dem2k -DartifactId=%prjname% -DarchetypeArtifactId=maven-archetype-quickstart
rem mvn archetype:generate -DgroupId=com.companyname.bank -DartifactId=consumerBanking -DarchetypeArtifactId=maven-archetype-quickstart
call mvn archetype:generate -DgroupId=d2k -DartifactId=%prjname%
rem call mvn archetype:generate -DartifactId=%prjname%

rem if not %errorlevel% == 0 goto fehler
if errorlevel 1 goto fehler

cd %prjname%
if errorlevel 1 goto fehler

rem -------- add log4j and junit to pom --------------
echo.
echo modifying pom.xml ...
rem sed "s/<dependencies>/<dependencies><dependency><groupId>log4j<\/groupId><artifactId>log4j<\/artifactId><version>1.2.17<\/version><\/dependency>/g" pom.xml >pom.tmp
sed "s/<\/dependencies>/<dependency><groupId>ch.qos.logback<\/groupId><artifactId>logback-classic<\/artifactId><version>1.1.2<\/version><\/dependency><\/dependencies>/g" pom.xml >pom.tmp
sed "s/<\/properties>/<java.version>1.8<\/java.version><\/properties>/g" pom.tmp >pom.xml
sed "s/<version>3.8.1<\/version>/<version>4.11<\/version>\n<!--\n<exclusions><exclusion><groupId>org.hamcrest<\/groupId><artifactId>hamcrest-core<\/artifactId><\/exclusion><\/exclusions>\n-->/g" pom.xml >pom.tmp
sed "s/<\/project>/<build><plugins>\n<plugin><groupId>org.apache.maven.plugins<\/groupId><artifactId>maven-compiler-plugin<\/artifactId><version>3.1<\/version><configuration><source>${java.version}<\/source><target>${java.version}<\/target><\/configuration><\/plugin>\n<\/plugins><\/build>\n<\/project>/g" pom.tmp >pom.xml

rem xml ed -L -u "/_:project/_:dependencies/_:dependency/_:groupId[text()='junit']/../_:version" -v "4.11" pom.xml
rem xml ed -L -s "/_:project/_:properties" -t elem -n "java.version" -v "1.7" x1\pom.xml
rem xml ed -L -s /_:project -t elem -n build pom.xml
rem xml ed -L -s /_:project/_:build -t elem -n plugins pom.xml
rem xml ed -L -s /_:project/_:build/_:plugins -t elem -n plugin pom.xml
rem xml ed -L -s /_:project/_:build/_:plugins/_:plugin -t elem -n groupId -v org.apache.maven.plugins pom.xml
rem xml ed -L -s /_:project/_:build/_:plugins/_:plugin -t elem -n artifactId -v maven-compiler-plugin pom.xml
rem xml ed -L -s /_:project/_:build/_:plugins/_:plugin -t elem -n version -v 3.1 pom.xml
rem xml ed -L -s /_:project/_:build/_:plugins/_:plugin -t elem -n configuration pom.xml
rem xml ed -L -s /_:project/_:build/_:plugins/_:plugin/_:configuration -t elem -n source -v ${java.version} pom.xml
rem xml ed -L -s /_:project/_:build/_:plugins/_:plugin/_:configuration -t elem -n target -v ${java.version} pom.xml

del pom.tmp*
rem --------------------------------------------------

rem --- log4j -----------
echo.
echo creating log4j.properties ...
mkdir src\main\resources
copy %~dpn0-log4j.properties src\main\resources\log4j.properties
rem --------------

rem --- logback ----------------------
echo.
echo creating logback.xml ...
copy %~dpn0-logback.xml src\main\resources\logback.xml
rem ----------------------------------

rem echo.
rem echo mvn eclipse:eclipse ...
rem call mvn eclipse:eclipse

 >mvn-compile.bat echo @call mvn compile
>>mvn-compile.bat echo @if errorlevel 1 pause

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

echo.
echo configuring eclipse workspace ...
cd ..
call mvn eclipse:configure-workspace "-Declipse.workspace=."

 >%starteclipsebat% echo @rem set JAVA_HOME=%%~dps0jdk
>>%starteclipsebat% echo @rem set ECLIPSE_HOME=%%~dps0eclipse
>>%starteclipsebat% echo @rem set PATH=%%JAVA_HOME%%\bin;%%PATH%%
>>%starteclipsebat% echo @rem set MOPTS=-Xms512M -Xmx1024M
>>%starteclipsebat% echo @rem set GOPTS=-XX:+UseParallelGC -XX:+UseParallelOldGC
>>%starteclipsebat% echo @rem set XOPTS=-XX:NewRatio=1 -XX:SurvivorRatio=6 -XX:MaxTenuringThreshold=0 -XX:TargetSurvivorRatio=75
>>%starteclipsebat% echo @rem set PAGOPTS=-XX:+UseLargePages -XX:LargePageSizeInBytes=4M
>>%starteclipsebat% echo @rem set POPTS=-XX:PermSize=128M -XX:MaxPermSize=256M
>>%starteclipsebat% echo.
>>%starteclipsebat% echo start %%ECLIPSE_HOME%%\eclipse.exe -data %%~dps0. -showlocation -vmargs %%MOPTS%% %%GOPTS%% %%XOPTS%% %%PAGOPTS%% %%POPTS%%

echo.
echo creating ahk scripts ...
copy %~dpn0-eclipse-preferences.epf eclipse-preferences.epf
copy %~dpn0-prefs-and-projects.ahk import-preferenses-and-projects.ahk
copy %~dpn0-import-maven-projects.ahk import-maven-projects.ahk

goto finish

:fehler
pause

:finish
if "%runide%" == "" (
	start import-preferenses-and-projects.ahk
	call %starteclipsebat%
)

:ende
