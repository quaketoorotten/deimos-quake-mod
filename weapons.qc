/*
*/

void () player_run; void() player_zero_FX;
void(entity bomb, entity attacker, float rad, entity ignore) T_RadiusDamage;
void(vector org, vector vel, float colour, float damage) SpawnBlood;
void() SuperDamageSound;
void() W_ResetWeaponState;
vector(float dm) VelocityForDamage;
vector(vector vel) ClipGibVelocity;

// called by worldspawn
void() W_Precache =
{
	precache_sound ("weapons/r_exp3.wav");	// new rocket explosion
	precache_sound ("weapons/rocket1i.wav");	// spike gun
	precache_sound ("weapons/sgun1.wav");
	precache_sound ("weapons/sshotf1b.wav");  // ssg
	precache_sound ("weapons/bfgstart.wav");
	precache_sound ("weapons/bfgfly.wav");
	precache_sound ("weapons/hyper.wav");
	precache_sound ("weapons/hyperup.wav");
	precache_sound ("weapons/hyperdn.wav");
	precache_sound ("weapons/chngnu1a.wav");
	precache_sound ("weapons/chngnd1a.wav");
	precache_sound ("weapons/chngnl1a.wav");
	precache_sound ("weapons/guncock.wav");	// player shotgun
	precache_sound ("weapons/ric1.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");	// ricochet (used in c code)
	precache_sound ("weapons/spike2.wav");	// super spikes
	precache_sound ("weapons/tink1.wav");	// spikes tink (used in c code)
	precache_sound ("weapons/grenade.wav");	// grenade launcher
	precache_sound ("weapons/bounce.wav");		// grenade bounce
	precache_sound ("weapons/ax1.wav");
};

float() crandom =
{
	return 2*(random() - 0.5);
};

void (vector src, vector dir, float speed) CheckDodge = 
{
	local float dtime;
	local float dist;
	local entity targ;

	if(skill <= 1)
		if(random() > 0.3)
			return;

	if(skill == 2)
		if(random() > 0.6)
			return;

	if(skill == 3)
		if(random() > 0.9)
			return;

	traceline (src, src + dir*2048, FALSE, self);
	
	if (!trace_ent)
		return;

	targ = trace_ent;
	
	if( (targ.flags & FL_MONSTER) && (targ.health > 0) && visible(targ, self) )
	{	
		if(targ.flags & FL_DODGED)
			return;

		if(targ.dodge_finished > time)
			return;
		
		if(!targ.th_dodge || (targ.dodge_finished > time) )
		{	
			targ.flags = targ.flags | FL_STRAFE;
			targ.dodge_finished = time + 0.6 + random()*2;		
		}
		else if(targ.th_dodge)
		{		
			dist = vlen(trace_endpos - src);
			dtime = (dist - targ.maxs_x) / speed;

			if(dtime <= 0) 
				dtime = 0.2;

			targ.enemy = self;
			targ.flags = targ.flags | FL_DODGED;
			targ.dspeed = dtime;
			targ.think = targ.th_dodge; 
			targ.dodge_finished = time + 3 + random()*2;
		}
	}
};

//============================================================================


vector() wall_velocity =
{
	local vector	vel;
	
	vel = normalize (self.velocity);
	vel = normalize(vel + v_up*(random()- 0.5) + v_right*(random()- 0.5));
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;
	
	return vel;
};


/*
================
SpawnMeatSpray
================
*/
void(vector org, vector vel) SpawnMeatSpray =
{
	local	entity missile;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_NOT;

	makevectors (self.angles);

	missile.velocity = vel;
	missile.velocity_z = missile.velocity_z + 250 + 50*random();

	missile.avelocity = '3000 1000 2000';
	
// set missile duration
	missile.nextthink = time + 1;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/zom_gib.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, org);
};

/*
================
SpawnBlood
================
*/
void(vector org, vector vel, float colour, float damage) SpawnBlood =
{
	particle (org, vel*0.1, colour, damage*2);
};

void(vector org, vector vel, float damage, float colour) SpawnSpark =
{
	particle (org, vel*0.1, colour, damage*2);
};

void(vector org, vector vel, float colour1) spawnfumes =
{
	particle (org, '0 25 100', colour1, 128);

};

/*
================
spawn_touchblood
================
*/
void(float damage, float colour) spawn_touchblood =
{
	local vector	vel;

	vel = wall_velocity () * 0.2;
	SpawnBlood (self.origin + vel*0.01, vel, colour, damage);
};


void(float damage) spawn_touchspark =
{
	local vector	vel;

	vel = wall_velocity () * 0.2;
	SpawnSpark (self.origin + vel*0.2, vel, damage*2, 228);
};

/*
================
SpawnChunk
================
*/
void(vector org, vector vel) SpawnChunk =
{
	particle (org, vel*0.02, 0, 10);
};

/*
================
TE_BFGEXPLOD
================
*/

void() TE_BFGEXPLOD_THINK =	
{
	if (self.frame < 4)
		self.frame += 1;
	if (self.frame == 4)
	{
		TE_BFGEXPLOD_CNT = TE_BFGEXPLOD_CNT - 1;
		remove(self);
		return;
	}
	self.think = TE_BFGEXPLOD_THINK;
	self.nextthink = time + 0.13;
};

void(vector to) TE_BFGEXPLOD =
{
	if (TE_BFGEXPLOD_CNT > TE_BFGEXPLOD_LIMIT)
		return;

	local entity thingamabob;
	thingamabob = spawn();
	thingamabob.origin = to;
	thingamabob.movetype = MOVETYPE_NONE;
	thingamabob.velocity = '0 0 0';
	thingamabob.touch = SUB_Null;
	setmodel (thingamabob , "progs/bfg3.spr");
	thingamabob.solid = SOLID_NOT;
	thingamabob.think = TE_BFGEXPLOD_THINK;
	thingamabob.nextthink = time + 0.25;
	
	TE_BFGEXPLOD_CNT = TE_BFGEXPLOD_CNT + 1;
};

/*
==============================================================================

MULTI-DAMAGE

Collects multiple small damages into a single damage

==============================================================================
*/

entity	multi_ent;
float	multi_damage;
float multi_knock;

void() ClearMultiDamage =
{
	multi_ent = world;
	multi_damage = 0;
	multi_knock = 0;
};

void(float kick) ApplyMultiDamage =
{
	if (!multi_ent)
		return;

	T_Damage (multi_ent, self, self, multi_damage, multi_knock);
};

void(entity hit, float damage, float  kick) AddMultiDamage =
{
	if (!hit)
		return;
	
	if (hit != multi_ent)
	{
		multi_knock = 1;
		ApplyMultiDamage (kick);
		multi_damage = damage;
		multi_ent = hit;
		multi_knock = 0;
	}
	else
	{
		multi_damage = multi_damage + damage;
		multi_knock += kick;
	}
};
/*
==============================================================================

BULLETS

==============================================================================
*/

/*
================
TraceAttack
================
*/

void(float damage, vector org, vector vel) TraceDamageTrigger =
{
	local entity damager;
	damager = spawn();
	damager.dmg = damage;
	damager.origin = org;
	damager.solid = SOLID_BBOX;
	setsize(damager, VEC_ORIGIN, VEC_ORIGIN);
	
	damager.think = SUB_Remove;
	damager.nextthink = time + 0.3;
	damager.movetype = MOVETYPE_FLY;
	damager.owner = self;
	damager.flags |= FL_DEADMONSTER;
}

void(float damage, vector dir, float kick) TraceAttack =
{
	local	vector	vel, org;
	local entity	e;
	local float		c = 0, corpse = 0;

	vel = normalize(dir + v_up*crandom() + v_right*crandom());
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;

	org = trace_endpos - dir*4;
	
	if (self.classname == "player") // less breaking the engine
	{
		for (e= findradius(self.origin, 2048); e; e = e.chain)
		{
			if (!(e.flags & FL_DEADMONSTER))
				continue;
			if (!(e.flags & FL_MONSTER))
				continue;
			if (e.health > 0)
				continue;
			if (!infront(e))
				continue;
			corpse = 1;
			
			if (corpse == 1)
				break;
		}

		if (corpse)
			TraceDamageTrigger (damage, org, vel); 	
	}
	
	if (trace_ent.takedamage)
	{	
		if (trace_ent.color)	
			SpawnBlood (org, vel*0.2, trace_ent.color, damage*1.25);
		else	
			SpawnBlood (org, vel*0.2, 73, damage*1.25);

		AddMultiDamage (trace_ent, damage, kick);
	}
	else
	{	
		if (self.classname == "player")
		{
			for (e= findradius(org, 24); e; e = e.chain)
			{
				if (!(e.flags & FL_DEADMONSTER))
					continue;
				if (!(e.flags & FL_MONSTER))
					continue;
				if (e.health > 0)
					continue;
				if (!infront(e))
					continue;

				c = 1;
			
				if (c == 1)
					break;
			}
		}
		if (!c)
		{
			WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
			WriteByte (MSG_BROADCAST, TE_GUNSHOT);
			WriteCoord (MSG_BROADCAST, org_x);
			WriteCoord (MSG_BROADCAST, org_y);
			WriteCoord (MSG_BROADCAST, org_z);
		}
	}
};


/*
================
FireBullets

Used by shotgun, super shotgun, and enemy soldier firing
Go to the trouble of combining multiple pellets into a single damage call.
================
*/
void(float shotcount, vector dir, vector spread, float amount, float kick) FireBullets =
{
	local	vector direction;
	local	vector	src;
	
	makevectors(self.v_angle);

	src = self.origin + v_forward*10;
	src_z = self.absmin_z + self.size_z * 0.7;

	ClearMultiDamage ();
	while (shotcount > 0)
	{
		direction = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;

		traceline (src, src + direction*2048, FALSE, self);
		if (trace_fraction != 1.0)
			TraceAttack (amount, direction, kick);

		shotcount = shotcount - 1;
	}

	ApplyMultiDamage (kick);
};

/*
================
W_FireShotgun
================
*/
void() W_FireShotgun =
{
	local float dmg;
	local vector dir;
				
	if(!deathmatch)
		dmg = 7;
	else
		dmg = 4;
	
	sound (self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);	
	//stuffcmd (self, "vibrate tactile/weapons/guncock.bnvib");

	self.punchangle_x = -2.5;
	
	self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	dir = aim (self, 100000);
	FireBullets (9, dir, '0.04 0.04 0', dmg, 2);
};

/*
================
W_FireSuperShotgun
================
*/
void() W_FireSuperShotgun =
{
	local float dmg;
	local vector dir;
				
	if(!deathmatch)
		dmg = 7;
	else
		dmg = 4;

	if (self.currentammo == 1)
	{
		W_FireShotgun ();
		return;
	}
		
	sound (self ,CHAN_WEAPON, "weapons/sshotf1b.wav", 1, ATTN_NORM);	

	self.punchangle_x = -5;
	
	self.currentammo = self.ammo_shells = self.ammo_shells - 2;
	dir = aim (self, 100000);
	FireBullets (12, dir, '0.145 0.05 0', dmg, 5);
	FireBullets (12, dir, '0.145 0.05 0', dmg, 5);
};

/*
================
W_FireAxe
================
*/

void() W_FireAxe =
{
	local	vector	source;
	local	vector	org;
	local float 	oldaxedmg, c;
	local entity	e;
	
	oldaxedmg = self.axedmg;

	makevectors (self.v_angle);
	source = self.origin + '0 0 16';
	traceline (source, source + v_forward*64, FALSE, self);

	if (trace_fraction == 1.0)
		return;

	org = trace_endpos - v_forward*4;

	TraceDamageTrigger (self.axedmg, org, '0 0 0'); 

	if (trace_ent.takedamage)
	{
		trace_ent.axhitme = 1;

		if (trace_ent.color)	
			SpawnBlood (org, '0 0 0', trace_ent.color, 12);
		else	
			SpawnBlood (org, '0 0 0', 73, 12*1.25);

		if (!(self.flags & FL_ONGROUND) && (self.flags & FL_JUMPRELEASED) && (self.waterlevel < 2))
			self.axedmg = oldaxedmg + (random() + random() + random())*25;

		T_Damage (trace_ent, self, self, self.axedmg, 5);
		dprint("axe dmg:");
		dprint(ftos(self.axedmg));
		dprint("\n");
		
		self.axedmg = oldaxedmg;
		
		if((trace_ent.flags & FL_MONSTER) || (trace_ent.movetype == MOVETYPE_WALK))
			sound (self, CHAN_WEAPON, "zombie/z_miss.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
	}
	else
	{	
		for (e= findradius(org, 24); e; e = e.chain)
		{
			if (!(e.flags & FL_DEADMONSTER))
				continue;
			if (!(e.flags & FL_MONSTER))
				continue;
			if (e.health > 0)
				continue;
			if (!infront(e))
				continue;
			c = 1;
			
			if (c == 1)
				break;
		}

		if (c)
			sound (self, CHAN_WEAPON, "zombie/z_miss.wav", 1, ATTN_NORM);
		
		else
		{
			// hit wall
			sound (self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
			WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
			WriteByte (MSG_BROADCAST, TE_GUNSHOT);
			WriteCoord (MSG_BROADCAST, org_x);
			WriteCoord (MSG_BROADCAST, org_y);
			WriteCoord (MSG_BROADCAST, org_z);
		}
	}
};
/*
================
W_FireChaingun
================
*/

void() player_chngstop1;
void() plas_cooldown1;

void() W_FireChaingun =
{
	local float spin_speed = 0.65;
	local vector dir = aim (self, 100000); 

	if (self.ammo_nails < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}
	
	if (self.shotcount > 4 && self.button0 && self.ammo_nails > 10 - self.shotcount)
		self.fastspin = 1;

	self.shotcount += 1; 
	
	if (self.fastspin)
	{
		if (self.shotcount == 4)
			spin_speed = 1.0;
		if (self.shotcount == 5)
			spin_speed = 1.25;
		if (self.shotcount == 6)
			spin_speed = 1.5;
		if (self.shotcount == 7)
			spin_speed = 1.5;
		if (self.shotcount == 8)
			spin_speed = 1.75;
		if (self.shotcount > 8)
			spin_speed = 2;
	}
	
	makevectors (self.v_angle);

	local float dmg;
				
	if(!deathmatch)
		dmg = 14;
	else
		dmg = 6;

	if (self.ammo_nails > 0)	
	{
		FireBullets (1, dir, '0.03 0.03 0', dmg , 2);
		self.currentammo = self.ammo_nails = self.ammo_nails - 1;
	}

	self.punchangle_x = -3;
	
	sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);

	self.attack_finished = time + (0.1/spin_speed);

};

void() CheckChaingunStop = 
{
	local float ammoleft;
	ammoleft = 0;

	if (self.ammo_nails >= 1)
		ammoleft = 1;

	if (!self.button0 && !self.fastspin) 
	{ 
		self.shotcount = 0;
		self.fastspin = 0;
		self.weaponframe = 0;
	}

	if ((self.fastspin && !self.button0) || !ammoleft)
	{
		self.shotcount = 0;
		self.fastspin = 0;
		player_chngstop1();
		self.attack_finished = time + 0.8; 
	}
};


/*
================
W_FireMachinegun
================
*/

void() W_FireMachinegun =
{
	local vector dir = aim (self, 100000); 
	local float dmg;
				
	if(!deathmatch)
		dmg = 13;
	else
		dmg = 5;

	if (self.ammo_nails < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}	
	self.currentammo = self.ammo_nails = self.ammo_nails - 1;
	FireBullets (1, dir, '0.02 0.02 0', dmg , 2);
	
	makevectors (self.v_angle);
	self.punchangle_x = -2;
	sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);

	self.attack_finished = time + 0.08;

};


/*
==============================================================================

ROCKETS

==============================================================================
*/

void()	s1_explode1	=	[0,		s1_explode2] {self.origin_z += 55;};
void()	s1_explode2	=	[1,		s1_explode3] {};
void()	s1_explode3	=	[2,		s1_explode4] {};
void()	s1_explode4	=	[3,		s1_explode5] {};
void()	s1_explode5	=	[4,		s1_explode6] {};
void()	s1_explode6	=	[5,		s1_explode7] {};
void()	s1_explode7	=	[6,		s1_explode8] {};
void()	s1_explode8	=	[7,		s1_explode9] {};
void()	s1_explode9	=	[8,		s1_explode10] {};
void()	s1_explode10=	[9,		s1_explode11] {};
void()	s1_explode11=	[10,		s1_explode12] {};
void()	s1_explode12=	[11,		s1_explode13] {};
void()	s1_explode13=	[12,		SUB_Remove] {};

void()	s2_explode1	=	[0,		s2_explode2] {};
void()	s2_explode2	=	[1,		s2_explode3] {};
void()	s2_explode3	=	[2,		s2_explode4] {};
void()	s2_explode4	=	[3,		s2_explode5] {};
void()	s2_explode5	=	[4,		s2_explode6] {};
void()	s2_explode6	=	[5,		s2_explode7] {};
void()	s2_explode7	=	[6,		s2_explode8] {};
void()	s2_explode8	=	[7,		SUB_Remove] {};


void()	s_explode1	=	[0,		s_explode2] {};
void()	s_explode2	=	[1,		s_explode3] {};
void()	s_explode3	=	[2,		s_explode4] {};
void()	s_explode4	=	[3,		s_explode5] {};
void()	s_explode5	=	[4,		s_explode6] {};
void()	s_explode6	=	[5,		SUB_Remove] {};

void() BecomeExplosion =
{
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;

	self.solid = SOLID_NOT;
	self.nextthink = time + 0.25;
	self.think = SUB_Remove;
	
	self.angles = '0 0 0';

	if (self.cnt == 1 || (self.classname == "grenade" && !(self.flags & FL_ONGROUND)))
	{
		setmodel (self, "progs/s_explod.spr"); 
		s_explode1 ();
	}
	else if (self.flags & FL_ONGROUND)
	{
		setmodel (self, "progs/s_explo1.spr"); 
		s1_explode1 ();
	}		
	else
	{
		setmodel (self, "progs/s_explo2.spr");
		s2_explode1();
	}
};

void() T_MissileTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner

	if (other.solid == SOLID_TRIGGER)
		return;

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	if (other.health)
		T_Damage (other, self, self.owner, self.dmg, 30);

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	T_RadiusDamage (self, self.owner, self.dmg_rad, other);

//	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};

void() rockEXPLOD = 
{
	T_RadiusDamage (self, self.owner, self.dmg_rad, self);
	
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};

/*
================
W_FireRocket
================
*/
void() W_FireRocket =
{
	local	entity missile;
	
	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	
	sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;
	missile.classname = "missile";
		
// set missile speed	

	makevectors (self.v_angle);
	missile.velocity = aim(self, 10000);
	missile.velocity = missile.velocity * 600;
	missile.angles = vectoangles(missile.velocity);

	missile.dmg = 182 + random()*35;
	missile.dmg_rad = 140;
	missile.flags |= FL_DEADMONSTER;
	
	missile.touch = T_MissileTouch;
	missile.missile_explode = rockEXPLOD;
	
// set missile duration
	missile.nextthink = time + 5;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/missile.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin + '0 0 16'); 

	if (self.flags & FL_CLIENT)
		CheckDodge(missile.origin, aim(self, 10000), 650);
};

//=============================================================================


void() GrenadeExplode =
{
	T_RadiusDamage (self, self.owner, self.dmg_rad, world);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};

void() GrenadeTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner
	if (other.takedamage == DAMAGE_AIM)
	{
		GrenadeExplode();
		return;
	}
	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

/*
================
W_FireGrenade
================
*/
void() W_FireGrenade =
{
	local	entity missile;
	
	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	
	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.classname = "grenade";
		
// set missile speed	

	makevectors (self.v_angle);

	if (self.v_angle_x)
		missile.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else
	{
		missile.velocity = aim(self, 10000);
		missile.velocity = missile.velocity * 500;
		missile.velocity_z = 200;
	}

	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);
	missile.dmg = 182 + random()*35;
	missile.dmg_rad = 140;
	
	missile.touch = GrenadeTouch;
	
// set missile duration
	missile.nextthink = time + 2.5;
	missile.think = GrenadeExplode;

	setmodel (missile, "progs/grenade.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin + v_forward*8 + '0 0 16');

	if (self.flags & FL_CLIENT)
		CheckDodge(missile.origin, aim(self, 10000), 650);
};

/*
==============================================================================

PLASMAS AND BFG10K

==============================================================================
*/

/*
================
Lasers for laser traps.
================
*/

void() Laser_Touch =
{
	local vector org;
	
	if (other == self.owner)
		return;		// don't explode on owner

	if (other.solid == SOLID_TRIGGER)
		return;

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	org = self.origin - 8*normalize(self.velocity);

	if (other.health)
	{
		if (other.color)	
			SpawnBlood (org, self.velocity*0.2, other.color, 15);
		else	
			SpawnBlood (org, self.velocity*0.2, 73, 15*1.25);

		spawnfumes (org, self.velocity*0.2, 0);

		T_Damage (other, self, self.owner, 15, 2);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
	
	remove(self);	
};

void(vector org, vector vec) LaunchLaser =
{		
	vec = normalize(vec);
	
	newmis = spawn();
	newmis.classname = "laser";
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLY;
	newmis.solid = SOLID_BBOX;
	newmis.effects = EF_DIMLIGHT;

	setmodel (newmis, "progs/laser.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		
	newmis.flags |= FL_DEADMONSTER;

	setorigin (newmis, org);

	newmis.velocity = vec * 600;
	newmis.angles = vectoangles(newmis.velocity);
	newmis.dmg = 15;

	newmis.nextthink = time + 5;
	newmis.think = SUB_Remove;
	newmis.touch = Laser_Touch;
};

//=============================================================================


void() BFGspray =
{
	local	entity target; 
	local float points, dist;
	local vector org;
	
// literal copy of quake 2's code
	for (target = findradius(self.origin, self.dmg_rad); target; target= target.chain)
	{
    		if(!target.takedamage)
                	continue;
        	if(target == self.owner)
                	continue;
        	if(!CanDamage(target, self.owner))
            	continue;
        	if(!CanDamage(target, self))
            	continue;
		if((target.movetype == MOVETYPE_PUSH))
			continue;
		if((target.movetype == MOVETYPE_NONE))
			continue;
		if((target.classname == "explo_box"))
			continue;

        	org = target.origin + (target.mins + target.maxs) * 0.5;
		dist = vlen(self.origin - org);
        	points = self.dmg * (1.0 - sqrt(dist / self.dmg_rad)); 
        	if (points < 0)
            	points = 0;
                    
        	if (points > 0)
        	{	
			T_Damage (target, self, self.owner, points, points);  
			dprint("bfg damage: ");
			dprint(ftos(points));
			dprint("\n");
			TE_BFGEXPLOD((target.absmin + target.absmax) * 0.5);
            	  
            	//stuffcmd(self.owner, "v_cshift 0 250 60 50\n");
        	}
	}
	if (!target)
		return;
};

void()	bfg_explode1	=	[0,		bfg_explode2] { self.effects = self.effects | EF_BRIGHTLIGHT;}
void()	bfg_explode2	=	[1,		bfg_explode3] { }
void()	bfg_explode3	=	[2,		bfg_explode4] { self.effects = 0;   }
void()	bfg_explode4	=	[3,		bfg_explode5] { self.effects = self.effects | EF_DIMLIGHT;}
void()	bfg_explode5	=	[4,		bfg_explode6] { }
void()	bfg_explode6	=	[5,		SUB_Remove	] { self.effects = 0;  }

void() BecomeExplosionBFG =
{
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel (self, "progs/bfg2.spr");
	self.solid = SOLID_NOT;

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION2);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	WriteByte (MSG_BROADCAST, 241);
	WriteByte (MSG_BROADCAST, 3);

	bfg_explode1 ();
	BFGspray ();
};


void() BFGthink =
{      
	local	entity ent, ignore;
	local vector point, dir, end, from;

	if (self.frame < 1)
		self.frame += 1;
	else 
		self.frame = 0;

	if(time > self.dspeed)
		remove(self);
		
// literal copy of quake 2's code
	
	for (ent= findradius(self.origin, 256); ent; ent = ent.chain)
	{
		if(!ent.takedamage)
                	continue;
        	if(ent== self.owner)
                	continue;
        	if(!CanDamage(ent, self))
            	continue;
		if((ent.movetype == MOVETYPE_PUSH))
			continue;
		if((ent.movetype == MOVETYPE_NONE))
			continue;
		if((ent.classname == "explo_box"))
			continue;
		
		point = (ent.maxs - ent.mins) * 0.5 + ent.absmin;
		dir = normalize (point - self.origin);
		
		ignore = self;
		
		from = self.origin;
		end = self.origin + dir*1024;	
		
		while(1)
		{
			traceline (from, end, 2, ignore);

			if (!trace_ent)
				break;
		
			if((trace_ent != self.owner) && (trace_ent.takedamage))
			{	
				local entity targ = trace_ent;
				T_Damage (targ, self, self, self.dmg_lsr, 0);
				particle (targ.origin, '0 0 100', 192, self.dmg_lsr* 8);
			}
			
			if(!(trace_ent.flags & FL_MONSTER) && !(trace_ent.flags & FL_CLIENT))
			{
				WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
				WriteByte (MSG_BROADCAST, TE_GUNSHOT);
				WriteCoord (MSG_BROADCAST, trace_endpos_x);
				WriteCoord (MSG_BROADCAST, trace_endpos_y);
				WriteCoord (MSG_BROADCAST, trace_endpos_z);
			}
			
			ignore = trace_ent;
			from = trace_endpos;
		}

		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_BEAM);

		if(self.owner.flags & FL_CLIENT)
			WriteEntity(MSG_BROADCAST, ent);
		else
			WriteEntity(MSG_BROADCAST, self);

		WriteCoord(MSG_BROADCAST, self.origin_x);
		WriteCoord(MSG_BROADCAST, self.origin_y);
		WriteCoord(MSG_BROADCAST, self.origin_z);
		WriteCoord(MSG_BROADCAST, trace_endpos_x);
		WriteCoord(MSG_BROADCAST, trace_endpos_y);
		WriteCoord(MSG_BROADCAST, trace_endpos_z);

		sound(self, CHAN_BODY, "weapons/lhit.wav", TRUE, ATTN_STATIC);
	}

	self.think = BFGthink;
	self.nextthink = time + 0.1;
};

void() T_BFGtouch =
{ 
	self.effects = 0;

	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	if (other.takedamage)
	{
		T_Damage (other, self, self.owner, self.dmg, 0);
	}
	self.origin = self.origin - 8*normalize(self.velocity);

	T_RadiusDamage (self, self.owner, 160, other);
	BecomeExplosionBFG ();
};

void() BfgEXPLOD = 
{
	T_RadiusDamage (self, self.owner, 160, self);
	BecomeExplosionBFG ();
}

void(vector dir, vector org) launch_bfgball=
{
	newmis = spawn ();
	newmis.angles = vectoangles(dir);
	newmis.effects = newmis.effects | EF_DIMLIGHT;
	newmis.movetype = MOVETYPE_FLY;
	newmis.solid = SOLID_BBOX;
	
	newmis.owner = self;
	newmis.classname = "bfg";
	newmis.flags |= FL_DEADMONSTER;
	newmis.dspeed = time + 6;

	newmis.think = BFGthink;
	newmis.touch = T_BFGtouch;
	newmis.nextthink = time + 0.1;
	newmis.velocity = dir * 400;
	newmis.missile_explode = BfgEXPLOD;
		
	setmodel (newmis, "progs/bfg1.spr");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);	
	setorigin (newmis, org);
	
	if (self.flags & FL_CLIENT)
		CheckDodge(newmis.origin, dir, 650);
};

/*
================
W_FireBFG 
================
*/

void() W_FireBFG =
{
	local vector dir; local float cells; 

	self.currentammo  = self.ammo_cells = self.ammo_cells - 50;

	if (self.waterlevel > 1)
	{
		cells = self.ammo_cells;
		self.ammo_cells = 0;
		self.dmg = 1000;
		T_RadiusDamage (self, self, 50*cells, world);
		W_SetCurrentAmmo ();
		sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
		self.dmg = 0;
		return;
	}

	makevectors (self.v_angle);

	local vector ang;
	ang_x = -25;
	ang_y = (crandom() * 0.35) - 0.25;
	ang_z = 0;
	ang = ang + self.v_angle;

	msg_entity = self;
	WriteByte ( MSG_ONE, 10 );
	WriteAngle( MSG_ONE, ang_x );
	WriteAngle( MSG_ONE, ang_y );
	WriteAngle( MSG_ONE, ang_z ); 

	self.fixangle = 3;
	self.angles = self.v_angle = ang;

	dir = aim (self, 1000);
	
	launch_bfgball(dir, self.origin + '0 0 16' + v_forward * 24);
	newmis.dmg_rad = 1024;

	if (!deathmatch)
	{
		newmis.dmg = 650;
		newmis.dmg_lsr = 15;
	}
	else 
	{
		newmis.dmg = 200;
		newmis.dmg_lsr = 5;
	}
};

//=============================================================================

void() T_PlasmaTouch =
{
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	local vector org = self.origin - 8*normalize(self.velocity);

	if (other.health)
	{
		if (other.color)	
			SpawnBlood (org, self.velocity*0.2, other.color, 30*1.25);
		else	
			SpawnBlood (org, self.velocity*0.2, 73, 30*1.25);

		spawnfumes (org, self.velocity*0.2, 0);

		T_Damage (other, self, self.owner, 30, 4);
	}
	else
	{	
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
		spawn_touchspark (5);
	}
	remove(self);

};

void() plasmathink = 
{
	if(time > self.dspeed)
		remove(self);

	particle (self.origin, '0 0 0' , 229, 1);
	self.think = plasmathink;
	self.nextthink = time + 0.01;
};

void(vector dir, vector org) launch_plasma =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLY;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	newmis.flags |= FL_DEADMONSTER;
	
	newmis.touch = T_PlasmaTouch;
	newmis.dspeed = time + 6;  // using dodge speed for plasma's expire date
	newmis.classname = "plasma";
	newmis.think = plasmathink;
	newmis.nextthink = time + 0.012;
	setmodel (newmis, "progs/laser.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org);
	newmis.dmg = 30;

	newmis.velocity = dir * 1000;

	if (self.flags & FL_CLIENT)
		CheckDodge(newmis.origin, dir, 1000);

};

void() CheckPlasmaStop = 
{
	local float ammoleft;
	ammoleft = 0;

	if (self.ammo_cells >= 1)
		ammoleft = 1;
	
	if (self.fastspin && (!self.button0 || !ammoleft))
	{
		self.fastspin = 0;
		plas_cooldown1();
		self.attack_finished = time + 0.8; 
	}
};


/*
================
W_FirePlasma 
================
*/

void() W_FirePlasma =
{
	local vector dir;
	
	makevectors (self.v_angle);
	
	if (self.ammo_cells < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}

	sound (self, CHAN_BODY, "weapons/hyper.wav", 1, ATTN_NORM);	
	
	self.currentammo = self.ammo_cells = self.ammo_cells - 1;
	self.fastspin = 1;
	dir = aim (self, 1000);
	launch_plasma (dir, self.origin + '0 0 16' + v_forward * 18);
	
	self.punchangle_x = -3; 
	self.attack_finished = time + 0.1;
};


//=============================================================================

void() spike_touch;
void() superspike_touch;


/*
===============
launch_spike

Used for both the player and the ogre
===============
*/
void(vector org, vector dir) launch_spike =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLY;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org);
	newmis.flags |= FL_DEADMONSTER;

	newmis.velocity = dir * 1000;
};

void(float ox) W_FireSpikes =
{
	local vector	dir;
	
	makevectors (self.v_angle);

	sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
	self.attack_finished = time + 0.2;
	dir = aim (self, 1000);
	launch_spike (self.origin + '0 0 16' + v_right*ox, dir);	

	self.punchangle_x = -3;
};


.float hit_z;
void() spike_touch =
{
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		if (other.color)	
			spawn_touchblood (9, other.color);
		else	
			spawn_touchblood (9, 73);

		T_Damage (other, self, self.owner, 9, 2);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		
		if (self.classname == "wizspike")
			WriteByte (MSG_BROADCAST, TE_WIZSPIKE);
		else if (self.classname == "knightspike")
			WriteByte (MSG_BROADCAST, TE_KNIGHTSPIKE);
		else
			WriteByte (MSG_BROADCAST, TE_SPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};

void() superspike_touch =
{
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		if (other.color)	
			spawn_touchblood (18, other.color);
		else	
			spawn_touchblood (18, 73);

		T_Damage (other, self, self.owner, 18, 2);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};



/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/



void() W_SetCurrentAmmo =
{
	self.items = self.items - ( self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS) );
	
	if (self.weapon == IT_AXE)
	{
		self.currentammo = 0;
		self.weaponmodel = "progs/v_axe.mdl";
	}
	else if (self.weapon == IT_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.weaponmodel = "progs/v_shot.mdl";
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.weaponmodel = "progs/v_shot2.mdl";
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == IT_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_nail.mdl";
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == IT_SUPER_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_nail2.mdl";
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_rock.mdl";
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_rock2.mdl";
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == IT_PLASMA)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_light.mdl";
		self.items = self.items | IT_CELLS;
	}
	else if (self.weapon == IT_BFG_9K)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_light2.mdl";
		self.items = self.items | IT_CELLS;
	}
	else
	{
		self.currentammo = 0;
		self.weaponmodel = "";
		self.weaponframe = 0;
	}
};

void() W_ResetWeaponState =
{
	player_run (); player_zero_FX();		// get out of any weapon firing states

	self.weaponframe = 0;	// don't lose attack debounce time from last attack,
		// if any, or picking up/switching weapons can cause double attacks
	
	if (self.weapon == IT_AXE )
		self.weaponmodel = "progs/v_axe.mdl";
	else if (self.weapon == IT_SHOTGUN)
		self.weaponmodel = "progs/v_shot.mdl";
	else if (self.weapon == IT_SUPER_SHOTGUN)
		self.weaponmodel = "progs/v_shot2.mdl";
	else if (self.weapon == IT_NAILGUN)
		self.weaponmodel = "progs/v_nail.mdl";
	else if (self.weapon == IT_SUPER_NAILGUN)
		self.weaponmodel = "progs/v_nail2.mdl";
	else if (self.weapon == IT_GRENADE_LAUNCHER)
		self.weaponmodel = "progs/v_rock.mdl";
	else if (self.weapon == IT_ROCKET_LAUNCHER)
		self.weaponmodel = "progs/v_rock2.mdl";
	else if (self.weapon == IT_PLASMA)
		self.weaponmodel = "progs/v_light.mdl";
	else if (self.weapon == IT_BFG_9K)
		self.weaponmodel = "progs/v_light2.mdl";
	else
		self.weaponmodel = string_null;

	W_SetCurrentAmmo();
};

float() W_BestWeapon =
{
	local	float	it;
	
	it = self.items;

	if (self.waterlevel <= 1 && self.ammo_cells >= 1 && (it & IT_PLASMA) )
		return IT_PLASMA;
	else if(self.ammo_nails >= 2 && (it & IT_SUPER_NAILGUN) )
		return IT_SUPER_NAILGUN;
	else if(self.ammo_shells >= 2 && (it & IT_SUPER_SHOTGUN) )
		return IT_SUPER_SHOTGUN;
	else if(self.ammo_nails >= 1 && (it & IT_NAILGUN) )
		return IT_NAILGUN;
	else if(self.ammo_shells >= 1 && (it & IT_SHOTGUN) )
		return IT_SHOTGUN;

	return IT_AXE;
};

float() W_CheckNoAmmo =
{
	if (self.currentammo > 0)
		return TRUE;

	if (self.weapon == IT_AXE)
		return TRUE;
	
	self.weapon = W_BestWeapon ();

	W_SetCurrentAmmo ();
	
// drop the weapon down
	return FALSE;
};

/*
============
W_Attack

An attack impulse can be triggered now
============
*/
void()	player_axe1;
void()	player_axeb1;
void()	player_axec1;
void()	player_axed1;
void()	player_shot1; void()	player_sshot1;
void()	player_plas1;
void()	player_rocket1;
void()	player_bfg1;
void() 	player_chngstart1  ; void() 	player_nail1;

void() W_Attack =
{
	local float r;

	if (!W_CheckNoAmmo ())
		return;

	makevectors	(self.v_angle);			// calculate forward angle for velocity
	
	if(!(self.flags & FL_NOTARGET))
		self.show_hostile = time + 1;	// wake monsters up

	if (self.weapon == IT_AXE)
	{
		sound (self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
		//stuffcmd (self, "vibrate tactile/weapons/ax1.bnvib");
		r = random();
		if (r < 0.25)
			player_axe1 ();
		else if (r<0.5)
			player_axeb1 ();
		else if (r<0.75)
			player_axec1 ();
		else
			player_axed1 ();
		self.attack_finished = time + 0.5;
	}
	else if (self.weapon == IT_SHOTGUN)
	{
		player_shot1 ();
		W_FireShotgun ();
		self.attack_finished = time + 0.7;
	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		player_sshot1 ();
		W_FireSuperShotgun ();
		self.attack_finished = time + 1.18;
	}
	else if (self.weapon == IT_NAILGUN)
	{
		player_nail1 (); 
	}
	else if (self.weapon == IT_SUPER_NAILGUN)
	{
		player_chngstart1 ();
	}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		player_rocket1();
		W_FireGrenade();
		self.attack_finished = time + 0.78;
	}
	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		player_rocket1();
		W_FireRocket();
		self.attack_finished = time + 0.84;
	}
	else if (self.weapon == IT_PLASMA)
	{
		player_plas1 ();
	}
	else if (self.weapon == IT_BFG_9K)
	{
		if (self.ammo_cells < 50)
		{
			W_ResetWeaponState ();
			self.weapon = W_BestWeapon ();
			W_SetCurrentAmmo ();
			return;
		}
		player_bfg1();
		self.attack_finished = time + 2.05;
		sound (self, CHAN_WEAPON, "weapons/bfgstart.wav", 1, ATTN_NORM);
	}

};

/*
============
W_ChangeWeapon

============
*/
void() W_ChangeWeapon =
{
	local	float	it, am, fl;
	
	it = self.items;
	am = 0;	

	if (time < self.attack_finished) return;
	if (self.button0) return;

	if (self.impulse == 1)
	{
		fl = IT_AXE;
	}
	else if (self.impulse == 2)
	{
		fl = IT_SHOTGUN;
		if (self.ammo_shells < 1)
			am = 1;
	}
	else if (self.impulse == 3)
	{
		fl = IT_SUPER_SHOTGUN;
		if (self.ammo_shells < 2)
			am = 1;
	}		
	else if (self.impulse == 4)
	{
		fl = IT_NAILGUN;
		if (self.ammo_nails < 1)
			am = 1;
	}
	else if (self.impulse == 5)
	{
		fl = IT_SUPER_NAILGUN;
		if (self.ammo_nails < 2)
			am = 1;
	}
	else if (self.impulse == 6)
	{
		fl = IT_GRENADE_LAUNCHER;
		if (self.ammo_rockets < 1)
			am = 1;
	}
	else if (self.impulse == 7)
	{
		fl = IT_ROCKET_LAUNCHER;
		if (self.ammo_rockets < 1)
			am = 1;
	}
	else if (self.impulse == 8)
	{
		fl = IT_PLASMA;
		if (self.ammo_cells < 1)
			am = 1;
	}
	else if (self.impulse == 9)
	{
		fl = IT_BFG_9K;
		if (self.ammo_cells < 50)
			am = 1;
	}

	self.impulse = 0;
	
	if (!(self.items & fl))
	{	// don't have the weapon or the ammo
		sprint (self, "no weapon.\n");
		return;
	}
	
	if (am)
	{	// don't have the ammo
		sprint (self, "not enough ammo.\n");
		return;
	}
//
// set weapon, set ammo
//
	self.weapon = fl;
	W_ResetWeaponState ();		
	W_SetCurrentAmmo ();
};

/*
============
CheatCommand
============
*/
void() CheatCommand =
{
	if (deathmatch || coop)
		return;

	self.ammo_rockets = 50;
	self.ammo_nails = 250;
	self.ammo_shells = 150;
	self.items = self.items | 
		IT_AXE |
		IT_SHOTGUN |
		IT_SUPER_SHOTGUN |
		IT_NAILGUN |
		IT_SUPER_NAILGUN |
		IT_GRENADE_LAUNCHER |
		IT_ROCKET_LAUNCHER;

	self.ammo_cells = 250;
	self.items = self.items | IT_PLASMA | IT_BFG_9K;
	//self.armortype = 0.8;
	//self.armorvalue = 200;
	//self.items = self.items - (self.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3)) + IT_ARMOR3;
	//self.health = 100;

	self.impulse = 0;
	W_SetCurrentAmmo ();
};

/*
============
CycleWeaponCommand

Go to the next weapon with ammo
============
*/
void() CycleWeaponCommand =
{
	local	float	it, am;
	
	it = self.items;
	self.impulse = 0;
	
	while (1)
	{
		am = 0;
		
		if (time < self.attack_finished) return;
		else if (self.button0) return;
		else if (self.weapon == IT_BFG_9K)
		{
			self.weapon = IT_AXE;
		}	
		else if (self.weapon == IT_BFG_9K)
		{
			self.weapon = IT_PLASMA;
		}
		else if (self.weapon == IT_AXE)
		{
			self.weapon = IT_SHOTGUN;
			if (self.ammo_shells < 1)
				am = 1;
		}
		else if (self.weapon == IT_SHOTGUN)
		{
			self.weapon = IT_SUPER_SHOTGUN;
			if (self.ammo_shells < 2)
				am = 1;
		}		
		else if (self.weapon == IT_SUPER_SHOTGUN)
		{
			self.weapon = IT_NAILGUN;
			if (self.ammo_nails < 1)
				am = 1;
		}
		else if (self.weapon == IT_NAILGUN)
		{
			self.weapon = IT_SUPER_NAILGUN;
			if (self.ammo_nails < 2)
				am = 1;
		}
		else if (self.weapon == IT_SUPER_NAILGUN)
		{
			self.weapon = IT_GRENADE_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_GRENADE_LAUNCHER)
		{
			self.weapon = IT_ROCKET_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_ROCKET_LAUNCHER)
		{
			self.weapon = IT_PLASMA;
			if (self.ammo_cells <= 1)
				am = 1;
		}
		else if (self.weapon == IT_PLASMA)
		{
			self.weapon = IT_BFG_9K;
			if (self.ammo_cells < 50)
				am = 1;
		}
	
		if ( (it & self.weapon) && am == 0)
		{
			W_SetCurrentAmmo ();
			W_ResetWeaponState();
			return;
		}
	}

};

/*
============
CycleWeaponReverseCommand

Go to the prev weapon with ammo
============
*/
void() CycleWeaponReverseCommand =
{
	local	float	it, am;
	
	it = self.items;
	self.impulse = 0;

	while (1)
	{
		am = 0;
		if (time < self.attack_finished) return;
		else if (self.button0) return;
	
		else if (self.weapon == IT_BFG_9K)
		{
			self.weapon = IT_PLASMA;
			if (self.ammo_cells < 50)
				am = 1;
		}
		else if (self.weapon == IT_PLASMA)
		{
			self.weapon = IT_ROCKET_LAUNCHER;
			if (self.ammo_cells < 1)
				am = 1;
		}
		else if (self.weapon == IT_ROCKET_LAUNCHER)
		{
			self.weapon = IT_GRENADE_LAUNCHER;
			if (self.ammo_cells < 1)
				am = 1;
		}
		else if (self.weapon == IT_GRENADE_LAUNCHER)
		{
			self.weapon = IT_SUPER_NAILGUN;
			if (self.ammo_cells < 2)
				am = 1;
		}
		else if (self.weapon == IT_SUPER_NAILGUN)
		{
			self.weapon = IT_NAILGUN;
			if (self.ammo_nails < 1)
				am = 1;
		}
		else if (self.weapon == IT_NAILGUN)
		{
			self.weapon = IT_SUPER_SHOTGUN;
			if (self.ammo_shells < 2)
				am = 1;
		}		
		else if (self.weapon == IT_SUPER_SHOTGUN)
		{
			self.weapon = IT_SHOTGUN;
			if (self.ammo_shells < 1)
				am = 1;
		}
		else if (self.weapon == IT_SHOTGUN)
		{
			self.weapon = IT_AXE;
		}
		else if (self.weapon == IT_AXE)
		{
			self.weapon = IT_BFG_9K;
			if (self.ammo_cells < 50)
				am = 1;
		}
	
		if ( (it & self.weapon) && am == 0)
		{	
			self.weaponframe = 0;
			W_SetCurrentAmmo ();
			W_ResetWeaponState();
			return;
		}
	}

};

/*
============
ServerflagsCommand

Just for development
============
*/
void() ServerflagsCommand =
{
	if(serverflags > 5)
		return;
	serverflags = serverflags * 4 + 1;
	self.keys = self.keys | serverflags;
};

void() QuadCheat =
{
	if (deathmatch || coop)
		return;
	self.super_time = 1;
	self.super_damage_finished = time + 30;
	self.items = self.items | IT_QUAD;
	dprint ("quad cheat\n");
};

/*
============
ImpulseCommands

============
*/
void() ImpulseCommands =
{
	if (self.impulse >= 1 && self.impulse <= 9)
		W_ChangeWeapon ();

	if (self.impulse == 10)
		CycleWeaponCommand ();
	if (self.impulse == 11)
		ServerflagsCommand ();
	if (self.impulse == 12)
		CycleWeaponReverseCommand ();
	if (self.impulse == 13)
		CheatCommand ();

	if (self.impulse == 255)
		QuadCheat ();
		
	self.impulse = 0;
};

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void() W_WeaponFrame =
{
	
	if (time < self.attack_finished)
		return;
	
	if (self.impulse)
		ImpulseCommands ();
	
// check for attack
	if (self.button0)
	{
		SuperDamageSound ();
		W_Attack ();
	}
	
	if(self.weapon == IT_SUPER_NAILGUN)
		CheckChaingunStop();
	
	if(self.weapon == IT_PLASMA)
		CheckPlasmaStop();
};

/*
========
SuperDamageSound

Plays sound if needed
========
*/
void() SuperDamageSound =
{
	if (self.super_damage_finished > time)
	{
		if (self.super_sound < time)
		{
			self.super_sound = time + 1;
			sound (self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
		}
	}
	return;
};


