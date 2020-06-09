program ServiceLocatorTest;

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
// Only one of the next two lines should be uncommented.
//  DUnitTestRunner, // uncomment to use DUnit, or
  TestInsight.Dunit, // uncomment to use TestInsight
  ServiceLocator in 'ServiceLocator.pas',
  TestServiceLocator in 'TestServiceLocator.pas';

{R *.RES}

begin
  ReportMemoryLeaksOnShutdown := True;
  RunRegisteredTests;
end.

