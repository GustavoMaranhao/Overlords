class OverCameraProperties extends Object placeable HideCategories(Object);

var() float DefaultFOV;
var() float CamDistance;
var() vector CamLocOffset, CamRotOffset, FixedGlobalCamLoc;
var() rotator FixedGlobalCamRot;


enum CameraStyles{	
	FixedGlobal,
	FirstPerson,
	ThirdPerson,	
	FixedThirdPerson,
	Locked
};
var() CameraStyles CameraStyle;

function name getCameraStyle(){
	switch(CameraStyle){
	case 0:
		return 'FixedGlobal';
	case 1:
		return 'FirstPerson';
	case 2:
		return 'FreeCam';
	case 3:
		return 'FixedThirdPerson';
	case 4:
		return 'Lock';
	}
}

DefaultProperties
{
	CameraStyle = 2
	CamDistance = 50.f //Distance of the camera to the player	
	CamRotOffset = 45.f
	CamLocOffset = (X=0,Y=0,Z=30)
	DefaultFOV = 90.f
}
