/*
==============================================================================

SOLDIER / PLAYER

==============================================================================
*/

$cd id1/models/enforcer
$origin 0 -6 24
$base base		
$skin skin

/*
===========
EnforcerCheckAttack 

The player is in view, so decide to move or launch an attack
Returns FALSE if movement should continue
============
*/

float() EnforcerCheckAttack =
{
	local vector	spot1, spot2;	
	local entity	targ;
	local float		chance;

	targ = self.enemy;
	
// see if any entities are in the way of the shot
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	traceline (spot1, spot2, FALSE, self);

	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if ( enemy_range == RANGE_MELEE)
	{
		if (CanDamage (self.enemy, self))
		{
			self.attack_state = AS_MELEE;
			SUB_AttackFinishedSpecial (self, 2*random());
			return TRUE;
		}
	}

	if (trace_ent != targ)
		return FALSE;	
							// don't have a clear shot
// missile attack
	if (time < self.attack_finished)
		return FALSE;
		
	if (enemy_range == RANGE_FAR)
		return FALSE;

	if (enemy_range == RANGE_CLOSE)
		chance = 0.4;
	else if (enemy_range == RANGE_NEAR)
		chance = 0.6;
	else if (enemy_range == RANGE_MID)
		chance = 0.9;


	if (random () < chance)
	{
		self.th_missile ();
		SUB_AttackFinished (self, 1 + random());
		if (random() < 0.3)
			self.lefty = !self.lefty;

		return TRUE;
	}
		
	// missile attack
		
	self.attack_state = AS_MISSILE;
	SUB_AttackFinished (self, 1+2*random() );
	return TRUE;
};


void() enf_CheckForCharge;

void() enforcer_fire =
{
	makevectors (self.angles);
	local vector dir;
	local entity en;
	local float num;
	
	if( random() <= 0.25 ) num = 2;
	else num = 1;

	self.effects = self.effects | EF_MUZZLEFLASH;
	
	en = self.enemy;
	
	dir = en.origin - en.velocity*0.2;
	dir = normalize (dir - self.origin);
 
	sound (self, CHAN_VOICE, "weapons/spike2.wav", 1, ATTN_NORM);
	
	FireBullets (2, dir, '0.02 0.04 0', num, 0);
};

void() enf_melee =
{
local vector	delta;
local float 	ldmg;

	if (!self.enemy)
		return;

	if (!CanDamage (self.enemy, self))
		return;

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 90)
		return;
		
	sound (self, CHAN_AUTO, "weapons/tink1.wav", 1, ATTN_NORM);	
	
	ldmg = (random() + random() + random()) * 8;
	T_Damage (self.enemy, self, self, ldmg, 25);
};
//============================================================================

void()	enf_stand1	=[	0,	enf_stand2	] {ai_stand();};
void()	enf_stand2	=[	1,	enf_stand3	] {ai_stand();};
void()	enf_stand3	=[	2,	enf_stand4	] {ai_stand();};
void()	enf_stand4	=[	3,	enf_stand5	] {ai_stand();};
void()	enf_stand5	=[	4,	enf_stand6	] {ai_stand();};
void()	enf_stand6	=[	5,	enf_stand7	] {ai_stand();};
void()	enf_stand7	=[	6,	enf_stand1	] {ai_stand();};

void()	enf_walk1	=[	7,	enf_walk2	] {
if (random() < 0.2)
	sound (self, CHAN_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE);
ai_walk(2);};
void()	enf_walk2	=[	8,	enf_walk3	] {ai_walk(4);};
void()	enf_walk3	=[	9,	enf_walk4	] {ai_walk(4);};
void()	enf_walk4	=[	10,	enf_walk5	] {ai_walk(3);};
void()	enf_walk5	=[	11,	enf_walk6	] {ai_walk(1);};
void()	enf_walk6	=[	12,	enf_walk7	] {ai_walk(2);};
void()	enf_walk7	=[	13,	enf_walk8	] {ai_walk(2);};
void()	enf_walk8	=[	14,	enf_walk9	] {ai_walk(1);};
void()	enf_walk9	=[	15,	enf_walk10	] {ai_walk(2);};
void()	enf_walk10	=[	16,	enf_walk11	] {ai_walk(4);};
void()	enf_walk11	=[	17,	enf_walk12	] {ai_walk(4);};
void()	enf_walk12	=[	18,	enf_walk13	] {ai_walk(1);};
void()	enf_walk13	=[	19,	enf_walk14	] {ai_walk(2);};
void()	enf_walk14	=[	20,	enf_walk15	] {ai_walk(3);};
void()	enf_walk15	=[	21,	enf_walk16	] {ai_walk(4);};
void()	enf_walk16	=[	22,	enf_walk1	] {ai_walk(2);};

void()	enf_run1	=[	23,	enf_run2	] {

if (random() < 0.2)
	sound (self, CHAN_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE);
enf_CheckForCharge();
ai_run(18);};
void()	enf_run2	=[	24,	enf_run3	] {ai_run(14);};
void()	enf_run3	=[	25,	enf_run4	] {ai_run(7);};
void()	enf_run4	=[	26,	enf_run5	] {ai_run(12);};
void()	enf_run5	=[	27,	enf_run6	] {ai_run(14);};
void()	enf_run6	=[	28,	enf_run7	] {ai_run(14);};
void()	enf_run7	=[	29,	enf_run8	] {ai_run(7);};
void()	enf_run8	=[	30,	enf_run1	] {ai_run(11);};

void()	enf_runatk1 	=[	60,	enf_runatk2 	] {// sound (self, CHAN_VOICE, "weapons/chngnu1a.wav", 1, ATTN_NORM);
ai_charge(18);};
void()	enf_runatk2 	=[	61,	enf_runatk3 	] {ai_charge(14);enforcer_fire();};
void()	enf_runatk3 	=[	62,	enf_runatk4 	] {ai_charge(10);enforcer_fire();};
void()	enf_runatk4 	=[	63,	enf_runatk5 	] {ai_charge(14);enforcer_fire();};
void()	enf_runatk5 	=[	64,	enf_runatk6 	] {ai_charge(17);enforcer_fire();};
void()	enf_runatk6 	=[	65,	enf_runatk7 	] {ai_charge(16);enforcer_fire();};
void()	enf_runatk7 	=[	66,	enf_runatk8 	] {ai_charge(9);enforcer_fire();};
void()	enf_runatk8 	=[	67,	enf_run1 	      ] {ai_charge(11);enforcer_fire(); SUB_CheckRefireSpecial (enf_runatk1); };

void()	enf_atk1	=[	31,	enf_atk2	] {ai_face(); //sound (self, CHAN_VOICE, "weapons/chngnu1a.wav", 1, ATTN_NORM);
};
void()	enf_atk2	=[	32,	enf_atk3	] {ai_face();};
void()	enf_atk3	=[	33,	enf_atk4	] {ai_face();};
void()	enf_atk4	=[	34,	enf_atk5	] {ai_face();};
void()	enf_atk5	=[	34,	enf_atk6	] {ai_face();};
void()	enf_atk6	=[	35,	enf_atk7	] {ai_face(); enforcer_fire();};
void()	enf_atk7	=[	36,	enf_atk8	] {ai_face(); enforcer_fire();};
void()	enf_atk8	=[	35,	enf_atk9	] {ai_face(); enforcer_fire();};
void()	enf_atk9	=[	36,	enf_atk10	] {ai_face(); enforcer_fire();};
void()	enf_atk10	=[	35,	enf_atk11	] {ai_face(); enforcer_fire();};
void()	enf_atk11	=[	36,	enf_atk12	] {ai_face(); enforcer_fire();};
void()	enf_atk12	=[	35,	enf_atk13	] {ai_face(); enforcer_fire();};
void()	enf_atk13	=[	36,	enf_atk14	] {ai_face(); enforcer_fire();};
void()	enf_atk14	=[	37,	enf_run1	] {ai_face(); //sound (self, CHAN_VOICE, "weapons/chngnd1a.wav", 1, ATTN_NORM);
};

void()	enf_melee1	 	=[	68,	enf_melee2	] {ai_face(); sound (self, CHAN_VOICE, "enforcer/woosh.wav", 1, ATTN_NORM);};
void()	enf_melee2		=[	69,	enf_melee3	] {ai_face();};
void()	enf_melee3		=[	70,	enf_melee4	] {ai_charge(5);};
void()	enf_melee4		=[	71,	enf_melee5	] {ai_charge(8);enf_melee();};
void()	enf_melee5		=[	72,	enf_melee6	] {ai_charge(8);};
void()	enf_melee6		=[	73,	enf_run1 	] {ai_charge(2);};

void() enf_CheckForCharge =
{
// check for mad charge
if (!enemy_vis)
	return;
if (time < self.attack_finished)
	return;	
if ( fabs(self.origin_z - self.enemy.origin_z) > 20)
	return;		// too much height change

if ( vlen (self.origin - self.enemy.origin) < 60)
		return;		// use regular attack

// charge		
	SUB_AttackFinished (self, 3);
	enf_runatk1 ();

};


void()	enf_paina1	=[	55,	enf_paina2	] {};
void()	enf_paina2	=[	56,	enf_paina3	] {};
void()	enf_paina3	=[	57,	enf_paina4	] {};
void()	enf_paina4	=[	58,	enf_run1	] {};

void()	enf_duckdown1	=[	42,	enf_duckdown2	] 
{self.nextthink = self.dspeed; self.maxs_z -= 40; self.takedamage = DAMAGE_YES;};
void()	enf_duckdown2	=[	41,	enf_duckdown3	] {self.pausetime = time + (random()) % 2 + 0.4;};
void()	enf_duckdown3	=[	39,	enf_duckdown4	] {};
void()	enf_duckdown4	=[	38,	enf_duckhold	] {};

void()	enf_duckup1	=[	38,	enf_duckup2	] 
{self.takedamage = DAMAGE_AIM; self.flags = self.flags - (self.flags & FL_DODGED); self.maxs_z += 40;};
void()	enf_duckup2	=[	39,	enf_duckup3	] {};
void()	enf_duckup3	=[	41,	enf_duckup4	] {};
void()	enf_duckup4	=[	42,	enf_run1	] {};

void() enf_duckhold =[	38,	enf_duckhold 	]
{	
	if(time > self.pausetime)
		self.think = enf_duckup1;
}

void(entity attacker, float damage)	enf_pain =
{
	local float r; r = random();

	if(self.health < self.max_health / 2)
		self.skin = 1;
	
	if (self.pain_finished > time)
		return;

	if (r < 0.5)
		sound (self, CHAN_VOICE, "enforcer/pain1.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "enforcer/pain2.wav", 1, ATTN_NORM);

	self.pain_finished = time + 1;

	if (self.flags & FL_DODGED)
		return;

	enf_paina1 ();
};

//============================================================================

void()	enf_fdie1	=[	43,	enf_fdie2	] {};
void()	enf_fdie2	=[	44,	enf_fdie3	] {};
void()	enf_fdie3	=[	45,	enf_fdie4	] {};
void()	enf_fdie4	=[	46,	enf_fdie5	] {ai_forward(5);};
void()	enf_fdie5	=[	47,	enf_fdie6	] {ai_forward(3);};
void()	enf_fdie6	=[	48,	enf_fdie7	] {ai_forward(5);};
void()	enf_fdie7	=[	49,	enf_fdie8	] {ai_forward(10);};
void()	enf_fdie8	=[	50,	enf_fdie9	] {ai_forward(5);};
void()	enf_fdie9	=[	51,	enf_fdie10	] {};
void()	enf_fdie10	=[	52,	enf_fdie11	] {ai_forward(10);};
void()	enf_fdie11	=[	53,	enf_fdie12	] {ai_forward(5); self.solid = SOLID_NOT; setorigin(self, self.origin);};
void()	enf_fdie12	=[	54,	enf_fdie12	] {};

void() enf_die =
{
// if die while dodging remove all dodge related tags
	if(self.flags & FL_DODGED)
	{
		self.maxs_z += 40;
		self.flags = self.flags - (self.flags & FL_DODGED);
	}

// check for gib
	if (self.health < -40)
	{
		self.skin = 0;
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_mega.mdl", self.health);
		//for(float i = 0; i < 2; i++)
			ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		remove(self);
		return;
	}
	
// don't die a regular death again as corpse
	if((self.deadflag & DEAD_DEAD))
		return;

// regular death
	sound (self, CHAN_VOICE, "enforcer/death1.wav", 1, ATTN_NORM);
	self.movetype = MOVETYPE_TOSS;
	self.takedamage = DAMAGE_YES;
	self.skin = 1;

	if(self.spawnflags & DROP_AMMO)
	{
		if(self.ammo_nails <= 0)
			self.ammo_nails = 5; 

		DropBackpack();
	}
	
	enf_fdie1 ();

	self.deadflag = DEAD_DEAD;
};


/*QUAKED monster_enforcer (1 0 0) (-16 -16 -24) (16 16 40) Ambush

*/
void() monster_enforcer =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model2 ("progs/enforcer.mdl");
	precache_model2 ("progs/h_mega.mdl");
	
	precache_sound2 ("enforcer/death1.wav");
	precache_sound2 ("enforcer/enfire.wav");
	precache_sound2 ("enforcer/enfstop.wav");
	precache_sound2 ("enforcer/idle1.wav");
	precache_sound2 ("enforcer/pain1.wav");
	precache_sound2 ("enforcer/pain2.wav");
	precache_sound2 ("enforcer/sight1.wav");
	precache_sound2 ("enforcer/sight2.wav");
	precache_sound2 ("enforcer/sight3.wav");
	precache_sound2 ("enforcer/sight4.wav");
	precache_sound2 ("enforcer/woosh.wav");
	
	spawn_enf();
};

void() spawn_enf =
{
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/enforcer.mdl");

	setsize (self, '-16 -16 -24', '16 16 40');
	self.health = 125;
	self.max_health = 125;
	self.skin = 0;
	self.ammo_nails = self.ammo_nails;

	self.th_stand = enf_stand1;
	self.th_walk = enf_walk1;
	self.th_run = enf_run1;
	self.th_pain = enf_pain;
	self.th_die = enf_die;
	self.th_missile = enf_atk1;	
	self.th_melee = enf_melee1;
	self.th_dodge = enf_duckdown1;
	self.mass = 200;
	self.th_checkattack = EnforcerCheckAttack;
	self.dspeed = 0;
	self.th_spawn = spawn_enf;

	walkmonster_start();
}