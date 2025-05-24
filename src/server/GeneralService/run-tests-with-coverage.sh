#!/bin/bash
echo "Running tests with coverage..."

dotnet test SoftwareSecurity.Tests/SoftwareSecurity.Tests.csproj /p:CollectCoverage=true /p:CoverletOutputFormat=cobertura /p:CoverletOutput=./TestResults/coverage.cobertura.xml

echo "Generating coverage report..."
dotnet tool install -g dotnet-reportgenerator-globaltool
reportgenerator -reports:SoftwareSecurity.Tests/TestResults/coverage.cobertura.xml -targetdir:SoftwareSecurity.Tests/TestResults/CoverageReport -reporttypes:Html

echo "Coverage report generated in SoftwareSecurity.Tests/TestResults/CoverageReport directory."
echo "Opening report..."

# Detect OS and open the report
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    open "SoftwareSecurity.Tests/TestResults/CoverageReport/index.html"
else
    # Linux
    xdg-open "SoftwareSecurity.Tests/TestResults/CoverageReport/index.html" || echo "Please open SoftwareSecurity.Tests/TestResults/CoverageReport/index.html in your browser"
fi 