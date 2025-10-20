Java 21 upgrade helper

This repository was updated to target Java 21 (see `pom.xml`).

Quick options to build with Java 21:

1) Run the provided Windows script (recommended for Windows):
   - Open PowerShell as Administrator and run:
     pwsh .\scripts\setup-and-build-windows.ps1
   - The script will install Temurin 21 and Maven (winget/choco), refresh the session, and run `mvn clean package`.

2) Use Docker (no host JDK required):
   - If Docker Desktop is available, from repo root run:
     docker run --rm --mount type=bind,source="${PWD}",target=/usr/src/mymaven -w /usr/src/mymaven maven:3.9.6-jdk-21 mvn -U -DskipTests clean package

3) Manual install:
   - Install JDK 21 from https://adoptium.net/temurin/releases/?version=21
   - Install Apache Maven from https://maven.apache.org/download.cgi
   - Set JAVA_HOME and add %JAVA_HOME%\bin and Maven's bin to PATH, then run:
     mvn -U -DskipTests clean package

If you run into build errors after upgrading, copy the full Maven error output into an issue here and I'll update dependencies or code as needed.
