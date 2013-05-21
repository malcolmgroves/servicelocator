program ServiceLocatorTest;

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  ServiceLocator in 'ServiceLocator.pas',
  TestServiceLocator in 'TestServiceLocator.pas';

{R *.RES}

begin
  ReportMemoryLeaksOnShutdown := True;
  DUnitTestRunner.RunRegisteredTests;
end.

