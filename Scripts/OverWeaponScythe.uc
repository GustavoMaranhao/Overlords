class OverWeaponScythe extends OverWeaponBase placeable;

simulated event SetPosition(UDKPawn Holder){
	super.SetPosition(Holder);
	if(OverPlayerController(HolderPawn.Controller)!=none) OverPlayerController(HolderPawn.Controller).weaponType = "Scythe";
}

simulated function StartFire(byte FireModeNum){
	`log("Scythe Attack");
	if(OverPlayerController(HolderPawn.Controller)!=none) OverPlayerController(HolderPawn.Controller).weaponType = "Scythe";
	super.StartFire(FireModeNum);
}


DefaultProperties
{
	Begin Object class=SkeletalMeshComponent Name=GunMesh
		SkeletalMesh=SkeletalMesh'pacote_gustavo.Meshes.SK_Carrot'
		HiddenGame=false
		HiddenEditor=false
		Scale=0.3
	end object
	Mesh=GunMesh
	Components.Add(Mesh)

	WeaponDelay = 1.5

	FiringStatesArray(0)=WeaponFiring
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponRange(0) = 100
	bMeleeWeapon = true
	FireInterval(0) = WeaponDelay
	InstantHitDamage(0) = 10
	Spread(0)=0

	bMelee = true
	InventoryGroup=2

	Damage = 45
}
