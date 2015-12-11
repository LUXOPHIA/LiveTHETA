unit LIB.Material;

interface //#################################################################### ■

uses System.Classes, System.SysUtils, System.UITypes,
     FMX.Graphics, FMX.Types3D, FMX.Materials, FMX.MaterialSources,
     LUX, LUX.DirectX.d3dcompiler, LUX.FireMonkey.Material;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TMyMaterial

     TMyMaterial = class( TMaterial )
     private
     protected
       _FMatrixMVP :TShaderVarMatrix;
       _FMatrixMV  :TShaderVarMatrix;
       _TIMatrixMV :TShaderVarMatrix;
       _EyePos     :TShaderVarVector;
       _Opacity    :TShaderVarFloat;
       _Texture    :TShaderVarTexture;
       _ShaderV    :TShaderSourceV;
       _ShaderP    :TShaderSourceP;
       ///// メソッド
       procedure DoInitialize; override;
       procedure DoApply( const Context_:TContext3D ); override;
     public
       constructor Create; override;
       destructor Destroy; override;
       ///// プロパティ
       property Texture   :TShaderVarTexture read _Texture;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TMyMaterialSource

     TMyMaterialSource = class( TMaterialSource )
     private
     protected
       _Texture :TBitmap;
       ///// アクセス
       procedure SetTexture( const Texture_:TBitmap );
       ///// メソッド
       function CreateMaterial: TMaterial; override;
       procedure DoTextureChanged( Sender_:TObject );
     public
       constructor Create( AOwner_:TComponent ); override;
       destructor Destroy; override;
       ///// プロパティ
       property Texture   :TBitmap     read _Texture     write SetTexture;
     end;

//const //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

//var //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

implementation //############################################################### ■

uses System.Math, System.Math.Vectors;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TMyMaterialSource

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// メソッド

procedure TMyMaterial.DoInitialize;
begin

end;

procedure TMyMaterial.DoApply( const Context_:TContext3D );
begin
     inherited;

     with Context_ do
     begin
          SetShaders( _ShaderV.Shader, _ShaderP.Shader );

          _FMatrixMVP.Value := CurrentModelViewProjectionMatrix;
          _FMatrixMV .Value := CurrentMatrix;
          _TIMatrixMV.Value := CurrentMatrix.Inverse.Transpose;
          _EyePos    .Value := CurrentCameraInvMatrix.M[ 3 ];
          _Opacity   .Value := CurrentOpacity;
     end;

     _ShaderV.SendVars( Context_ );
     _ShaderP.SendVars( Context_ );
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TMyMaterial.Create;
begin
     inherited;

     _FMatrixMVP := TShaderVarMatrix .Create( 'FMatrixMVP'  );
     _FMatrixMV  := TShaderVarMatrix .Create( 'FMatrixMV'   );
     _TIMatrixMV := TShaderVarMatrix .Create( 'IMatrixMV'   );
     _EyePos     := TShaderVarVector .Create( '_EyePos'     );
     _Opacity    := TShaderVarFloat  .Create( '_Opacity'    );
     _Texture    := TShaderVarTexture.Create( '_Texture'    );

     _ShaderV := TShaderSourceV.Create;
     _ShaderP := TShaderSourceP.Create;

     with _ShaderV do
     begin
          Vars := [ _FMatrixMVP,
                    _FMatrixMV ,
                    _TIMatrixMV ];

          LoadFromFile( '..\..\_SHADER\MyMaterial.hvs' );
     end;

     with _ShaderP do
     begin
          Vars := [ _FMatrixMVP,
                    _FMatrixMV ,
                    _TIMatrixMV,
                    _EyePos    ,
                    _Opacity   ,
                    _Texture    ];

          LoadFromFile( '..\..\_SHADER\MyMaterial.hps' );
     end;
end;

destructor TMyMaterial.Destroy;
begin
     _ShaderV.Free;
     _ShaderP.Free;

     _FMatrixMVP.Free;
     _FMatrixMV .Free;
     _TIMatrixMV.Free;
     _EyePos    .Free;
     _Opacity   .Free;
     _Texture   .Free;
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TMyMaterialSource

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

procedure TMyMaterialSource.SetTexture( const Texture_:TBitmap );
begin
     _Texture.Assign( Texture_ );
end;

/////////////////////////////////////////////////////////////////////// メソッド

function TMyMaterialSource.CreateMaterial: TMaterial;
begin
     Result := TMyMaterial.Create;
end;

procedure TMyMaterialSource.DoTextureChanged( Sender_:TObject );
begin
     if not _Texture.IsEmpty then TMyMaterial( Material ).Texture.Value := TTextureBitmap( _Texture ).Texture;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TMyMaterialSource.Create( AOwner_:TComponent );
begin
     inherited;

     _Texture := TTextureBitmap.Create;

     _Texture.OnChange := DoTextureChanged;
end;

destructor TMyMaterialSource.Destroy;
begin
     _Texture.Free;

     inherited;
end;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

//############################################################################## □

initialization //######################################################## 初期化

finalization //########################################################## 最終化

end. //######################################################################### ■
