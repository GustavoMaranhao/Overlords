class OverWeaponSword extends OverWeaponBase placeable;

simulated event SetPosition(UDKPawn Holder){
	super.SetPosition(Holder);
	if(OverPlayerController(HolderPawn.Controller)!=none) OverPlayerController(HolderPawn.Controller).weaponType = "Sword";
}

simulated function StartFire(byte FireModeNum){
	`log("Sword Attack");
	if(OverPlayerController(HolderPawn.Controller)!=none) OverPlayerController(HolderPawn.Controller).weaponType = "Sword";
	super.StartFire(FireModeNum);
}

DefaultProperties
{
	Begin Object class=SkeletalMeshComponent Name=GunMesh
		SkeletalMesh=SkeletalMesh'pacote_gustavo.Meshes.SK_ExportSword2'
		HiddenGame=false
		HiddenEditor=false
		Scale=0.3
	end object
	Mesh=GunMesh
	Components.Add(Mesh)

	WeaponDelay = 1.17

	FiringStatesArray(0)=WeaponFiring
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponRange(0) = 100
	bMeleeWeapon = true
	FireInterval(0) = 1.17
	InstantHitDamage(0) = 5
	Spread(0)=0

	bMelee = true
	InventoryGroup=1
}
