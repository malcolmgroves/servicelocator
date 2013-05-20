unit ServiceLocator;

interface

uses
  Generics.Collections, System.SysUtils;

type
  TServiceLocator = class
  private
    fServices : TDictionary<TGuid, IInterface>;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function Available<ServiceType: IInterface> : boolean;
    function Get<ServiceType: IInterface>: ServiceType;
    procedure Add<ServiceType: IInterface>(IntfInstance : ServiceType);
    procedure Remove<ServiceType: IInterface>;
  end;

implementation
uses
  System.TypInfo;

procedure TServiceLocator.Add<ServiceType>(IntfInstance: ServiceType);
var
  Guid: TGuid;
begin
  if not Assigned(IntfInstance) then
    raise Exception.Create('Cannot add a nil instance');

  if Available<ServiceType> then
    raise Exception.Create('Interface type already registered');

  Guid := PTypeInfo(TypeInfo(ServiceType)).TypeData.Guid;

  fServices.Add(Guid, IntfInstance);
end;


function TServiceLocator.Available<ServiceType>: boolean;
var
  Guid: TGuid;
begin
  Guid := PTypeInfo(TypeInfo(ServiceType)).TypeData.Guid;
  Result := fServices.ContainsKey(Guid);
end;

constructor TServiceLocator.Create;
begin
  fServices := TDictionary<TGuid, IInterface>.Create;
end;

destructor TServiceLocator.Destroy;
begin
  fServices.Free;
  inherited;
end;

function TServiceLocator.Get<ServiceType>: ServiceType;
var
  Guid: TGuid;
  LInterface : IInterface;
  LSpecificInterface : ServiceType;
begin
  Result := nil;
  Guid := PTypeInfo(TypeInfo(ServiceType)).TypeData.Guid;
  if fServices.TryGetValue(Guid, LInterface) then
    if Supports(LInterface, Guid, LSpecificInterface) then
      Result := LSpecificInterface;
end;

procedure TServiceLocator.Remove<ServiceType>;
var
  Guid: TGuid;
begin
  if not Available<ServiceType> then
    raise Exception.Create('Interface type not registered');

  Guid := PTypeInfo(TypeInfo(ServiceType)).TypeData.Guid;

  fServices.Remove(Guid);
end;

end.
