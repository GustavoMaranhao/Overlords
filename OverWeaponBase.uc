class OverWeaponBase extends UDKWeapon placeable;

var UDKPawn HolderPawn;
var bool bWeaponCooldown;
var() bool bMelee;
var() float Damage;
var() class<DamageType> Damage_Type;
var() float WeaponDelay;
var() name EquipToSocket, Trace_Start, Trace_End;
var() SoundCue HitSound;

simulated event PostBeginPlay(){
	super.PostBeginPlay();
}

simulated function TimeWeaponPutDown(){
	super.TimeWeaponPutDown();
	mesh.setHidden(true);
}

simulated function TimeWeaponEquipping(){	
	super.TimeWeaponEquipping();
	SetPosition(UDKPawn(Instigator));
	AttachWeaponTo(Instigator.Mesh,EquipToSocket);
	mesh.setHidden(false);
}

simulated event SetPosition(UDKPawn Holder){
	local SkeletalMeshComponent compo;
	local vector X,Y,Z;
	local SkeletalMeshSocket socket;
	local Vector FinalLocation;

	HolderPawn = Holder;

	compo = Holder.Mesh;
	if (compo != none){
		socket = compo.GetSocketByName(EquipToSocket);
		if (socket != none){
			FinalLocation = compo.GetBoneLocation(socket.BoneName);
		}
	}
	SetLocation(FinalLocation);

	Holder.GetAxes(Holder.Controller.Rotation,X,Y,Z);
	
    FinalLocation= Holder.GetPawnViewLocation(); //this is in world space.

    //FinalLocation= FinalLocation - Y*12 - Z*32; // Rough position adjustment

    //SetHidden(False);
    SetLocation(FinalLocation);
    SetBase(Holder);

    SetRotation(Holder.Controller.Rotation);
}

simulated function traceBlade(){
	local actor traced;
	local vector hitlocation, hitnormal, traceEnd, traceStart;
	local pawn hitpawn;

	 // Get location of sockets in world
	SkeletalMeshComponent(self.Mesh).GetSocketWorldLocationAndRotation(Trace_Start, traceStart);
	SkeletalMeshComponent(self.Mesh).GetSocketWorldLocationAndRotation(Trace_End, traceEnd);
	OverHUD(OverPlayerController(HolderPawn.Controller).myHUD).debugWeapon = true;

	//trace from TraceStart to TraceEnd
	Foreach TraceActors(class'actor', traced, hitlocation, hitnormal, traceEnd, traceStart, vect(1,1,1)){
		if(traced != Owner && Pawn(traced) != none && !Pawn(traced).IsInState('Dying')){  //If traced actor isn't you and a pawn.
			hitpawn = Pawn(traced);  
			`log("Attack hit:"@hitPawn);
			//Do damage to the traced pawn
			hitpawn.TakeDamage(Damage, Controller(traced), hitlocation,  Normal((Traced.Location - Owner.Location))*InstantHitMomentum[CurrentFireMode], Damage_Type);   
			traced.TakeDamage(Damage, Controller(traced), hitlocation,  Normal((Traced.Location - Owner.Location))*InstantHitMomentum[CurrentFireMode], Damage_Type); 
			PlaySound(HitSound);
			`log(hitPawn.health);	
			`log(traced);
		}  
	} 
}

simulated function StartFire(byte FireModeNum){
	if(!bWeaponCooldown){
		bWeaponCooldown = true;
		if(bMelee) settimer(0.1,true,'traceBlade');
		settimer(WeaponDelay,false,'Delay');
		super.StartFire(FireModeNum);		
	}
	//else super.StartFire(FireModeNum);
}

simulated function AttachWeaponTo( SkeletalMeshComponent MeshCpnt, optional Name SocketName ){
	MeshCpnt.AttachComponentToSocket(Mesh,SocketName);
}

function Delay(){
	bWeaponCooldown = false;
	clearTimer('traceBlade');
	OverHUD(OverPlayerController(HolderPawn.Controller).myHUD).debugWeapon = false;
}

DefaultProperties
{
	bWeaponCooldown = false
	bMelee = false
	EquipToSocket = "Right_Hand"
	Trace_Start = "TraceStart"
	Trace_End = "TraceEnd"
	Damage = 5;
	Damage_Type = class'DmgType_Crushed'
	HitSound = SoundCue'KismetGame_Assets.Sounds.S_BulletImpact_01_Cue'
}
