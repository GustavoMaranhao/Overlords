class OverCamera extends Camera placeable;
var vector Loc;
var OverCameraProperties CameraProperties;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	`log("Custom Camera up");
	CameraProperties = OverGameInfo(WorldInfo.Game).ArchetypeManager.OverCameraTemplate;
}

function UpdateViewTarget(out TViewTarget OutVT, float DeltaTime)
{
	local vector		Pos, HitLocation, HitNormal;
	local rotator		Rot;
	local Actor			HitActor;
	local CameraActor	CamActor;
	local bool			bDoNotApplyModifiers;
	local TPOV			OrigPOV;
	local Pawn          TPawn;

	// store previous POV, in case we need it later
	OrigPOV = OutVT.POV;

	// Default FOV on viewtarget
	OutVT.POV.FOV = DefaultFOV;

	// Viewing through a camera actor.
	CamActor = CameraActor(OutVT.Target);
	if( CamActor != None )
	{
		CamActor.GetCameraView(DeltaTime, OutVT.POV);

		// Grab aspect ratio from the CameraActor.
		bConstrainAspectRatio	= bConstrainAspectRatio || CamActor.bConstrainAspectRatio;
		OutVT.AspectRatio		= CamActor.AspectRatio;

		// See if the CameraActor wants to override the PostProcess settings used.
		CamOverridePostProcessAlpha = CamActor.CamOverridePostProcessAlpha;
		CamPostProcessSettings = CamActor.CamOverridePostProcess;
	}
	else
	{
		TPawn = Pawn(OutVT.Target);
		// Give Pawn Viewtarget a chance to dictate the camera position.
		// If Pawn doesn't override the camera view, then we proceed with our own defaults
		if( Pawn(OutVT.Target) == None ||
			!Pawn(OutVT.Target).CalcCamera(DeltaTime, OutVT.POV.Location, OutVT.POV.Rotation, OutVT.POV.FOV) )
		{
			// don't apply modifiers when using these debug camera modes.
			bDoNotApplyModifiers = TRUE;
			CameraStyle = CameraProperties.getCameraStyle();

			switch( CameraStyle )
			{
				case 'FixedGlobal'		:
										Loc.X = CameraProperties.FixedGlobalCamLoc.X;
										Loc.Y = CameraProperties.FixedGlobalCamLoc.Y;
										Loc.Z = CameraProperties.FixedGlobalCamLoc.Z;

										Rot.Pitch = CameraProperties.FixedGlobalCamRot.Pitch;
										Rot.Roll = CameraProperties.FixedGlobalCamRot.Roll;
										Rot.Yaw = CameraProperties.FixedGlobalCamRot.Yaw;

										HitActor = Trace(HitLocation, HitNormal, Pos, Loc, FALSE, vect(12,12,12));
										OutVT.POV.Location = (HitActor == None) ? Pos : HitLocation;
										OutVT.POV.Rotation = Rot;
										break;

				case 'FixedThirdPerson'	: // Simple third person view implementation
				case 'FreeCam'		:
				case 'FreeCam_Default':
				case 'Lock':
										Loc = OutVT.Target.Location;
										if(CameraStyle != 'Lock')
											Rot = OutVT.Target.Rotation;

										Loc.X += CameraProperties.CamLocOffset.X;
										Loc.Y += CameraProperties.CamLocOffset.Y;
										Loc.Z += CameraProperties.CamLocOffset.Z;

										// Take into account Mesh Translation so it takes into account the PostProcessing we do there.
										if ((TPawn != None) && (TPawn.Mesh != None))
										{
											Loc += (TPawn.Mesh.Translation - TPawn.default.Mesh.Translation) >> OutVT.Target.Rotation;
										}

										//OutVT.Target.GetActorEyesViewPoint(Loc, Rot);
										if( CameraStyle == 'FreeCam' || CameraStyle == 'FreeCam_Default' )
										{
											Rot = PCOwner.Rotation;
										}										
										Loc += CameraProperties.CamRotOffset >> Rot;

										Pos = Loc - Vector(Rot) *  CameraProperties.CamDistance;
										// @fixme, respect BlockingVolume.bBlockCamera=false

										if(CameraStyle == 'Lock'){
											Rot = OverGameInfo(WorldInfo.Game).PlayerController.Pawn.Rotation;
											Pos = Loc - Vector(Rot) *  CameraProperties.CamDistance;
										}

										HitActor = Trace(HitLocation, HitNormal, Pos, Loc, FALSE, vect(12,12,12));
										OutVT.POV.Location = (HitActor == None) ? Pos : HitLocation;
										OutVT.POV.Rotation = Rot;
										Rot.Pitch = 0;
										PCOwner.Pawn.SetRotation(Rot);
										break;

				case 'FirstPerson'	:   // Simple first person, view through viewtarget's 'eyes'
				default				:	OutVT.Target.GetActorEyesViewPoint(OutVT.POV.Location, OutVT.POV.Rotation);
										// Take into account Mesh Translation so it takes into account the PostProcessing we do there.
										if ((TPawn != None) && (TPawn.Mesh != None)){
											OutVT.POV.Location += (TPawn.Mesh.Translation - TPawn.default.Mesh.Translation) >> OutVT.Target.Rotation;
										}
										break;

			}
		}
	}

	SetRotation(OutVT.POV.Rotation);

	if( !bDoNotApplyModifiers )	{
		// Apply camera modifiers at the end (view shakes for example)
		ApplyCameraModifiers(DeltaTime, OutVT.POV);
	}
	//`log( WorldInfo.TimeSeconds  @ GetFuncName() @ OutVT.Target @ OutVT.POV.Location @ OutVT.POV.Rotation @ OutVT.POV.FOV );
}

function ChangeCameraStyle(string type){
	switch(type){
		case "FreeCam":
			CameraProperties.CameraStyle=2;
			break;
		case "Lock":
			CameraProperties.CameraStyle=4;
			break;
	}
}





DefaultProperties
{
}