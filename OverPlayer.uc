class OverPlayer extends UDKPawn placeable;

var AnimNodeSlot FullBodyAnimSlot;
var AnimNodeSlot TopHalfAnimSlot;
var() array<AnimSet> ScytheAnims;
var() array<AnimSet> SwordAnims;
var() array<AnimSet> BowAnims;

var() ParticleSystemComponent DefendParticle;

var() float RagdollLifespan;

var() float LockDistance;

simulated event PostBeginPlay(){
	local vector translateVect;
	local float collisionRadius, collisionHeight;
	super.PostBeginPlay();
	GetBoundingCylinder(collisionRadius,collisionHeight);
	translateVect.Z = -collisionHeight;
	Mesh.SetTranslation(translateVect);
	SetPhysics(PHYS_Falling);
	FullBodyAnimSlot = AnimNodeSlot(mesh.FindAnimNode('FullBodySlot'));
	TopHalfAnimSlot = AnimNodeSlot(mesh.FindAnimNode('TopHalfSlot'));
	AddDefaultInventory();
}

function AddDefaultInventory(){
	 InvManager.CreateInventory(class'Overlords.OverWeaponSword');
	 InvManager.CreateInventory(class'Overlords.OverWeaponScythe');
}

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser){
	if (OverPlayerController(Controller)!=none){
		if (OverPlayerController(Controller).bDefending) super.TakeDamage(DamageAmount/3,EventInstigator, HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
		else super.TakeDamage(DamageAmount,EventInstigator, HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
	} else super.TakeDamage(DamageAmount,EventInstigator, HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
	if(Health<=0){
		DefendParticle.SetActive(false);
		Died(EventInstigator,DamageType,HitLocation); 
		`log(self@"Died");
	}
}

function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation){
	if(Super.Died(Killer, DamageType, HitLocation)){
		Super.PlayDying(damageType, HitLocation);
		LifeSpan=0;
		// Ensure we are always updating kinematic so that it won't go through the ground
		Mesh.MinDistFactorForKinematicUpdate = 0.0;

		Mesh.SetRBCollidesWithChannel(RBCC_Default,TRUE);
		Mesh.ForceSkelUpdate();
		Mesh.SetTickGroup(TG_PostAsyncWork);
		CollisionComponent = Mesh;

		// Turn collision on for skelmeshcomp and off for cylinder
		CylinderComponent.SetActorCollision(false, false);
		Mesh.SetActorCollision(true, true);
		Mesh.SetTraceBlocking(true, true);
		SetPhysics(PHYS_RigidBody);
		Mesh.PhysicsWeight = 1.0;

		// If we had stopped updating kinematic bodies on this character due to distance from camera, force an update of bones now.
		if( Mesh.bNotUpdatingKinematicDueToDistance )
			Mesh.UpdateRBBonesFromSpaceBases(TRUE, TRUE);

		Mesh.PhysicsAssetInstance.SetAllBodiesFixed(FALSE);
		Mesh.bUpdateKinematicBonesFromAnimation=FALSE;
		Mesh.SetRBLinearVelocity(Velocity, false);
		Mesh.SetTranslation(vect(0,0,1) * BaseTranslationOffset);
		Mesh.WakeRigidBody();
		SetTimer(RagdollLifespan,false,'HideRagdoll');		
		return true;
	}
	return false;
}

function HideRagdoll(){
	Mesh.SetHidden(true);
}

DefaultProperties
{
		Components.Remove(Sprite)

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		ModShadowFadeoutTime=0.25
		MinTimeBetweenFullUpdates=0.2
		AmbientGlow=(R=.01,G=.01,B=.01,A=1)
		AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
		LightShadowMode=LightShadow_ModulateBetter
		ShadowFilterQuality=SFQ_High
		bSynthesizeSHLight=TRUE
	End Object
	Components.Add(MyLightEnvironment)

    Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
		CastShadow=true
		bCastDynamicShadow=true
		bOwnerNoSee=false
		LightEnvironment=MyLightEnvironment;
        BlockRigidBody=true;
        CollideActors=true;
        BlockZeroExtent=true;
		BlockNonZeroExtent=TRUE
		bHasPhysicsAssetInstance=true		
		PhysicsAsset=PhysicsAsset'pacote_personagem.humana.humana_saia_Physics'
		AnimSets(0)=AnimSet'pacote_personagem.humana.humana_correndo'
        AnimSets(1)=AnimSet'pacote_personagem.humana.humana_idle'
        AnimSets(2)=AnimSet'pacote_personagem.humana.humana_pulo'
        AnimSets(3)=AnimSet'pacote_personagem.humana.humana_pulo2'
        AnimSets(4)=AnimSet'pacote_personagem.humana.humana_pulo3' 
		AnimSets(5)=AnimSet'pacote_personagem.humana.humana_pulo4' 
		AnimSets(6)=AnimSet'pacote_personagem.humana.humana_pulo5' 
		AnimSets(7)=AnimSet'pacote_personagem.humana.humana_pulo6' 
		AnimSets(8)=AnimSet'pacote_personagem.humana.humana_pulo7' 
		AnimSets(9)=AnimSet'pacote_personagem.humana.humana_ataque01' 
		AnimSets(10)=AnimSet'pacote_personagem.humana.humana_ataque02' 
		AnimSets(11)=AnimSet'pacote_personagem.humana.humana_ataque03' 
		AnimSets(12)=AnimSet'pacote_personagem.humana.humana_fireball' 
		AnimTreeTemplate=AnimTree'pacote_personagem.humana.humana_mulher_animtree'
		SkeletalMesh=SkeletalMesh'pacote_personagem.humana.humana_saia'//SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
		Translation=(X=0,Y=0,Z=0)
		Rotation=(Yaw=0,Roll=0,Pitch=0)
		Scale=1

		Materials(0)=Material'pacote_personagem.Materials.natal1_mat'
		Materials(1)=Material'pacote_personagem.Materials.natal1_mat'
		Materials(2)=Material'pacote_personagem.Materials.natal1_mat'
		Materials(3)=Material'pacote_personagem.Materials.natal2_mat'
		Materials(5)=Material'pacote_personagem.Materials.natal1_mat' 
		Materials(11)=Material'pacote_personagem.Materials.natal1_mat'
		Materials(12)=Material'pacote_personagem.Materials.natal1_mat'
	End Object
	Mesh=InitialSkeletalMesh;
	Components.Add(InitialSkeletalMesh);

	CollisionType=COLLIDE_BlockAll
	Begin Object Name=CollisionCylinder
	CollisionRadius=+006.000000
	CollisionHeight=+0016.000000
	End Object
	CylinderComponent=CollisionCylinder

	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent0                    //Particle used for an Undefined Amount of Time
        Template=ParticleSystem'OverlordsPackage.Particles.DefendParticle'
        bAutoActivate=false
		Translation=(X=20,Y=0,Z=0)
		Rotation=(Yaw=0,Roll=0,Pitch=16384)
		Scale=0.25
	End Object
	DefendParticle=ParticleSystemComponent0
	Components.Add(ParticleSystemComponent0)

	GroundSpeed = 100
	RagdollLifespan=6

	SwordAnims[0] = AnimSet'pacote_personagem.humana.humana_ataque01' 

	ScytheAnims[0] = AnimSet'pacote_personagem.humana.humana_ataque01' 

	InventoryManagerClass=class'Overlords.OverGameInventoryManager'

	DefaultInventory(0)=class'Overlords.OverWeaponSword'
	DefaultInventory(1)=class'Overlords.OverWeaponScythe'

	ControllerClass=class'Overlords.OverPlayerController'

	LockDistance = 270.f
}
