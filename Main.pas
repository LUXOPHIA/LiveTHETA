unit Main;

interface //#################################################################### ■

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Math.Vectors,
  FMX.Types3D, FMX.Controls3D, FMX.MaterialSources, FMX.Objects3D, FMX.Viewport3D, FMX.Media,
  LIB.Material;

type
  TForm1 = class(TForm)
    Viewport3D1: TViewport3D;
    Dummy1: TDummy;
    Dummy2: TDummy;
    Camera1: TCamera;
    Sphere1: TSphere;
    CameraComponent1: TCameraComponent;
    procedure FormCreate(Sender: TObject);
    procedure Viewport3D1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure Viewport3D1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure Viewport3D1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure CameraComponent1SampleBufferReady(Sender: TObject;
      const ATime: TMediaTime);
  private
    { private 宣言 }
    _MouseS :TShiftState;
    _MouseP :TPointF;
    ///// メソッド
  public
    { public 宣言 }
    _Material :TMyMaterialSource;
    ///// メソッド
    function SearchTHETAS :TVideoCaptureDevice;
  end;

     HCameraComponent = class helper for TCameraComponent
     private
     protected
       function GetDevice_:TVideoCaptureDevice; inline;
       procedure SetDevice( const Device_:TVideoCaptureDevice );
     public
       property Device :TVideoCaptureDevice read GetDevice_ write SetDevice;
     end;

var
  Form1: TForm1;

implementation //############################################################### ■

{$R *.fmx}

uses System.Generics.Collections;

function HCameraComponent.GetDevice_:TVideoCaptureDevice;
begin
     with Self do
     begin
          Result := GetDevice;
     end;
end;

procedure HCameraComponent.SetDevice( const Device_:TVideoCaptureDevice );
begin
     with Self do
     begin
          FDevice := Device_;
     end;
end;

function TForm1.SearchTHETAS :TVideoCaptureDevice;
var
   I :Integer;
   D :TCaptureDevice;
begin
     with TCaptureDeviceManager do
     begin
          if Current <> nil then
          begin
               for I := 0 to Current.Count - 1 do
               begin
                    D := Current.Devices[ I ];

                    if ( D.MediaType = TMediaType.Video ) and
                       ( D is TVideoCaptureDevice       ) then
                    begin
                         if D.Name = 'RICOH THETA S' then
                         begin
                              Result := TVideoCaptureDevice( D );

                              Exit;
                         end;
                    end;
               end;
          end;
     end;

     Result := nil;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

procedure TForm1.FormCreate(Sender: TObject);
var
   VCD :TVideoCaptureDevice;
begin
     _Material := TMyMaterialSource.Create( Self );

     Sphere1.MaterialSource := _Material;

     with CameraComponent1 do
     begin
          VCD := SearchTHETAS;

          if Assigned( VCD ) then
          begin
               Device := VCD;

               Active := True;
          end
          else
          begin
               ShowMessage( 'THETA S が見つかりません。' );

               _Material.Texture.LoadFromFile( '..\..\_DATA\DualFisheye 1920x1080.png' );
          end;
     end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Viewport3D1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
     _MouseS := Shift;
     _MouseP := TPointF.Create( X, Y );
end;

procedure TForm1.Viewport3D1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
   P :TPointF;
begin
     if ssLeft in _MouseS then
     begin
          P := TPointF.Create( X, Y );

          with Dummy1.RotationAngle do Y := Y + ( P.X - _MouseP.X ) / 2;
          with Dummy2.RotationAngle do X := X - ( P.Y - _MouseP.Y ) / 2;

          _MouseP := P;
     end;
end;

procedure TForm1.Viewport3D1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
     Viewport3D1MouseMove( Sender, Shift, X, Y );

     _MouseS := [];
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.CameraComponent1SampleBufferReady(Sender: TObject; const ATime: TMediaTime);
begin
     CameraComponent1.SampleBufferToBitmap( _Material.Texture, True );

     Viewport3D1.Repaint;
end;

end. //######################################################################### ■
