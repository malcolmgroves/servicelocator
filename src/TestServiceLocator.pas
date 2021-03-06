{****************************************************}
{                                                    }
{  ServiceLocator                                    }
{                                                    }
{  Copyright (C) 2013 Malcolm Groves                 }
{                                                    }
{  http://www.malcolmgroves.com                      }
{                                                    }
{****************************************************}
{                                                    }
{  This Source Code Form is subject to the terms of  }
{  the Mozilla Public License, v. 2.0. If a copy of  }
{  the MPL was not distributed with this file, You   }
{  can obtain one at                                 }
{                                                    }
{  http://mozilla.org/MPL/2.0/                       }
{                                                    }
{****************************************************}

unit TestServiceLocator;

interface

uses
  TestFramework, Generics.Collections, ServiceLocator;

type
  IService1 = interface
    ['{09ACA776-FCD2-4200-8F9D-CC5375D2E4D2}']
    function GetID : integer;
  end;

  IService2 = interface
    ['{2A720636-9051-4741-BECB-FAD1BB96CE74}']
    function GetID : integer;
  end;

  TObject1 = class(TInterfacedObject, IService1)
  public
    function GetID : integer;
  end;

  TObject2 = class(TInterfacedObject, IService1, IService2)
  public
    function GetID : integer;
  end;


  TestTServiceLocator = class(TTestCase)
  strict private
    FServiceLocator: TServiceLocator;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAvailableWhenAdded;
    procedure TestAvailableWhenNotAdded;
    procedure TestGetWhenAdded;
    procedure TestGetWhenSameInstanceAddedUnderDifferentTypes;
    procedure TestGetWhenNotAdded;
    procedure TestAddNotAlreadyAdded;
    procedure TestAddAlreadyAdded;
    procedure TestAddWhenNull;
    procedure TestRemoveWhenAdded;
    procedure TestRemoveWhenNotAdded;
    procedure TestTemp;
  end;

implementation
uses
  System.SysUtils;

procedure TestTServiceLocator.SetUp;
begin
  FServiceLocator := TServiceLocator.Create;
end;

procedure TestTServiceLocator.TearDown;
begin
  FServiceLocator.Free;
  FServiceLocator := nil;
end;

procedure TestTServiceLocator.TestGetWhenAdded;
var
  Service1Instance : IService1;
  Service2Instance : IService2;

begin
  Service1Instance := TObject1.Create as IService1;
  Service2Instance := TObject2.Create as IService2;

  FServiceLocator.Add<IService1>(Service1Instance);
  FServiceLocator.Add<IService2>(Service2Instance);

  Service1Instance := nil;
  Service2Instance := nil;


  Service1Instance := FServiceLocator.Get<IService1>;
  Service2Instance := FServiceLocator.Get<IService2>;

  Check(Assigned(Service1Instance), 'Get returned a nil instance even when it was added');
  Check(Assigned(Service2Instance), 'Get returned a nil instance even when it was added');

  Check(Service1Instance.GetID = 1, 'GetID on returned instance should give 1');
  Check(Service2Instance.GetID = 2, 'GetID on returned instance should give 2');
end;

procedure TestTServiceLocator.TestGetWhenNotAdded;
var
  Service1Instance : IService1;
  Service2Instance : IService2;
begin
  FServiceLocator.Add<IService1>(TObject1.Create as IService1);
  Service1Instance := FServiceLocator.Get<IService1>;
  ExpectedException := EServiceNotRegisteredException;
  Service2Instance := FServiceLocator.Get<IService2>;
  StopExpectingException('Get on a non-existant service failed to raise an exception');
  Check(not Assigned(Service2Instance), 'Get returned an instance even when it was not added');
end;

procedure TestTServiceLocator.TestGetWhenSameInstanceAddedUnderDifferentTypes;
var
  Service1Instance : IService1;
  Service2Instance : IService2;
  Object2 : TObject2;
begin
  Object2 := TObject2.Create;

  FServiceLocator.Add<IService1>(Object2 as IService1);
  FServiceLocator.Add<IService2>(Object2 as IService2);
  Service1Instance := FServiceLocator.Get<IService1>;
  Service2Instance := FServiceLocator.Get<IService2>;

  Check(Assigned(Service1Instance), 'Get returned a nil instance even when it was added');
  Check(Assigned(Service2Instance), 'Get returned a nil instance even when it was added');

  Check(Service1Instance.GetID = 2, 'GetID on returned Intf1 instance should give 2');
  Check(Service2Instance.GetID = 2, 'GetID on returned Intf2 instance should give 2');
end;

procedure TestTServiceLocator.TestRemoveWhenAdded;
begin
  FServiceLocator.Add<IService1>(TObject1.Create as IService1);
  FServiceLocator.Remove<IService1>;
  Check(not FServiceLocator.Available<IService1>, 'Just removed IService1 instance, yet Available returned true');
end;

procedure TestTServiceLocator.TestRemoveWhenNotAdded;
begin
  ExpectedException := EServiceNotRegisteredException;
  FServiceLocator.Remove<IService1>;
  StopExpectingException('Removing a non-existant instance should have failed');
end;

procedure TestTServiceLocator.TestTemp;
var
  Intf1Instance : IService1;
begin
  Intf1Instance := TObject1.Create as IService1;
  Check(Intf1Instance.GetID = 1, 'GetID should return 1');
end;

procedure TestTServiceLocator.TestAddAlreadyAdded;
begin
  FServiceLocator.Add<IService1>(TObject1.Create as IService1);
  ExpectedException := EServiceAlreadyRegisteredException;
  FServiceLocator.Add<IService1>(TObject2.Create as IService1);
  StopExpectingException('Adding a second instance of the same interface should have failed');
end;

procedure TestTServiceLocator.TestAddNotAlreadyAdded;
begin
  FServiceLocator.Add<IService1>(TObject1.Create as IService1);
  Check(FServiceLocator.Available<IService1>, 'Just added IService1 instance, yet Available returned false');
end;

procedure TestTServiceLocator.TestAddWhenNull;
begin
  ExpectedException := EArgumentNilException;
  FServiceLocator.Add<IService1>(nil);
  StopExpectingException('Adding a nil instance should have failed');
end;

procedure TestTServiceLocator.TestAvailableWhenAdded;
begin
  FServiceLocator.Add<IService1>(TObject1.Create as IService1);
  FServiceLocator.Add<IService2>(TObject2.Create as IService2);
  Check(FServiceLocator.Available<IService1>, 'Just added IService1 instance, yet Available returned false');
  Check(FServiceLocator.Available<IService2>, 'Just added IService2 instance, yet Available returned false');
end;

procedure TestTServiceLocator.TestAvailableWhenNotAdded;
begin
  FServiceLocator.Add<IService1>(TObject1.Create as IService1);
  Check(FServiceLocator.Available<IService1>, 'Just added IService1 instance, yet Available returned false');
  Check(not FServiceLocator.Available<IService2>, 'Haven''t added IService2 instance, yet Available returned true');
end;


{ TObject2 }

function TObject2.GetID: integer;
begin
  Result := 2;
end;

{ TObject1 }

function TObject1.GetID: integer;
begin
  Result := 1;
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTServiceLocator.Suite);
end.

