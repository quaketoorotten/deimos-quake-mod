/*
==============================================================================

WIZARD

==============================================================================
*/

$cd id1/models/a_wizard
$origin 0 0 24
$base wizbase	
$skin wizbase

/*
==============================================================================

WIZARD

If the player moves behind cover before the missile is launched, launch it
at the last visible spot with no velocity leading, in hopes that the player
will duck back out and catch it.
==============================================================================
*/


void() wiz_run1;
void() wiz_side1;

/*
=================
WizardCheckAttack
=================
*/
float()	WizardCheckAttack =
{
	local vector	spot1, spot2;	
	local entity	targ;
	local float		chance;

	if (time < self.attack_finished)
		return FALSE;
	if (!enemy_vis)
		return FALSE;
	
	if (enemy_range == RANGE_FAR)
	{
		if (self.attack_state != AS_STRAIGHT)
		{
			self.attack_state = AS_STRAIGHT;
			wiz_run1 ();
		}
		return FALSE;
	}
	
	targ = self.enemy;
	
// see if any entities are in the way of the shot
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	traceline (spot1, spot2, FALSE, self);

	if (trace_ent != targ)
	{	// don't have a clear shot, so move to a side
		if (self.attack_state != AS_STRAIGHT)
		{
			self.attack_state = AS_STRAIGHT;
			wiz_run1 ();
		}
		return FALSE;
	}

	if ( enemy_range == RANGE_MELEE)
	{
		if (CanDamage (self.enemy, self))
		{
			self.attack_state = AS_MELEE;
			SUB_AttackFinishedSpecial (self, 0.5 + 2*random());
			return TRUE;
		}
	}
		
	if (enemy_range == RANGE_CLOSE)
		chance = 0.3;
	else if (enemy_range == RANGE_NEAR)
		chance = 0.6;
	else if (enemy_range == RANGE_MID)
		chance = 0.9;
	else
		chance = 1;

	if (random () < chance)
	{
		self.attack_state = AS_MISSILE;
		return TRUE;
	}

	if (enemy_range == RANGE_MID)
	{
		if (self.attack_state != AS_STRAIGHT)
		{
			self.attack_state = AS_STRAIGHT;
			wiz_run1 ();
		}
	}
	else
	{
		if (self.attack_state != AS_SLIDING)
		{
			self.attack_state = AS_SLIDING;
			wiz_side1 ();
		}
	}
	
	return FALSE;
};

/*
=================
WizardAttackFinished
=================
*/
void()	WizardAttackFinished =
{
	if (enemy_range >= RANGE_MID || !enemy_vis)
	{
		self.attack_state = AS_STRAIGHT;
		self.think = wiz_run1;
	}
	else
	{
		self.attack_state = AS_SLIDING;
		self.think = wiz_side1;
	}
};

/*
==============================================================================

WIZ ATTACKS

==============================================================================
*/


void(float speed) WizShoot =
{
	local	vector	org, dir;
	local entity	targ = self.enemy;
	local vector	targorg = targ.origin + targ.view_ofs;
	
	makevectors (self.angles);
	
	self.effects = self.effects | EF_MUZZLEFLASH;

	org = self.origin + '0 0 16';
	dir = normalize (targorg - org);
	
	launch_spike (org, dir);
	newmis.classname = "wizspike";
	newmis.velocity = dir * speed;
	setmodel (newmis, "progs/w_spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
};


void() WizFire =
{
	WizShoot (600);
	WizShoot (500);
	WizShoot (400);
};



void() Wiz_idlesound =
{
local float wr;
	wr = random() * 5;

	if (self.waitmin < time)
	{
	 	self.waitmin = time + 2;
	 	if (wr > 4.5) 
	 		sound (self, CHAN_VOICE, "wizard/widle1.wav", 1,  ATTN_IDLE);
	 	if (wr < 1.5)
	 		sound (self, CHAN_VOICE, "wizard/widle2.wav", 1, ATTN_IDLE);
	}
	return;
};

void()	wiz_stand1	=[	0,		wiz_stand2	] {ai_stand();};
void()	wiz_stand2	=[	1,		wiz_stand3	] {ai_stand();};
void()	wiz_stand3	=[	2,		wiz_stand4	] {ai_stand();};
void()	wiz_stand4	=[	3,		wiz_stand5	] {ai_stand();};
void()	wiz_stand5	=[	4,		wiz_stand6	] {ai_stand();};
void()	wiz_stand6	=[	5,		wiz_stand7	] {ai_stand();};
void()	wiz_stand7	=[	6,		wiz_stand8	] {ai_stand();};
void()	wiz_stand8	=[	7,		wiz_stand1	] {ai_stand();};

void()	wiz_walk1	=[	0,		wiz_walk2	] {ai_walk(8);
Wiz_idlesound();};
void()	wiz_walk2	=[	1,		wiz_walk3	] {ai_walk(8);};
void()	wiz_walk3	=[	2,		wiz_walk4	] {ai_walk(8);};
void()	wiz_walk4	=[	3,		wiz_walk5	] {ai_walk(8);};
void()	wiz_walk5	=[	4,		wiz_walk6	] {ai_walk(8);};
void()	wiz_walk6	=[	5,		wiz_walk7	] {ai_walk(8);};
void()	wiz_walk7	=[	6,		wiz_walk8	] {ai_walk(8);};
void()	wiz_walk8	=[	7,		wiz_walk1	] {ai_walk(8);};

void()	wiz_side1	=[	0,		wiz_side2	] {ai_run(8);
Wiz_idlesound();};
void()	wiz_side2	=[	1,		wiz_side3	] {ai_run(8);};
void()	wiz_side3	=[	2,		wiz_side4	] {ai_run(8);};
void()	wiz_side4	=[	3,		wiz_side5	] {ai_run(8);};
void()	wiz_side5	=[	4,		wiz_side6	] {ai_run(8);};
void()	wiz_side6	=[	5,		wiz_side7	] {ai_run(8);};
void()	wiz_side7	=[	6,		wiz_side8	] {ai_run(8);};
void()	wiz_side8	=[	7,		wiz_side1	] {ai_run(8);};

void()	wiz_run1	=[	15,		wiz_run2	] {ai_run(16);
Wiz_idlesound();
};
void()	wiz_run2	=[	16,		wiz_run3	] {ai_run(16);};
void()	wiz_run3	=[	17,		wiz_run4	] {ai_run(16);};
void()	wiz_run4	=[	18,		wiz_run5	] {ai_run(16);};
void()	wiz_run5	=[	19,		wiz_run6	] {ai_run(16);};
void()	wiz_run6	=[	20,		wiz_run7	] {ai_run(16);};
void()	wiz_run7	=[	21,		wiz_run8	] {ai_run(16);};
void()	wiz_run8	=[	22,		wiz_run9	] {ai_run(16);};
void()	wiz_run9	=[	23,		wiz_run10	] {ai_run(16);};
void()	wiz_run10	=[	24,		wiz_run11	] {ai_run(16);};
void()	wiz_run11	=[	25,		wiz_run12	] {ai_run(16);};
void()	wiz_run12	=[	26,		wiz_run13	] {ai_run(16);};
void()	wiz_run13	=[	27,		wiz_run14	] {ai_run(16);};
void()	wiz_run14	=[	28,		wiz_run1	] {ai_run(16);};

void()	wiz_Melee =
{
	local vector	delta;
	local float 	ldmg;
	
	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 100)
		return;
	if (!CanDamage (self.enemy, self))
		return;
		
      sound (self, CHAN_WEAPON, "demon/dhit2.wav", 1, ATTN_NORM);
	ldmg = 15 + 10*random();
	T_Damage (self.enemy, self, self, ldmg, 50);
	self.enemy.origin_z += 10;
	
	if(!(self.enemy.movetype & MOVETYPE_WALK))
		self.enemy.flags = self.enemy.flags - (self.enemy.flags & FL_ONGROUND);
};


void()	wiz_bite1	=[	71,		wiz_bite2	] {ai_face();};
void()	wiz_bite2	=[	72,		wiz_bite3	] {ai_face();};
void()	wiz_bite3	=[	73,		wiz_bite4	] {ai_face();};
void()	wiz_bite4	=[	74,		wiz_bite5	] {ai_face();wiz_Melee();};
void()	wiz_bite5	=[	75,		wiz_bite6	] {ai_face();};
void()	wiz_bite6	=[	76,		wiz_run1	] {ai_face();};

void() wiz_soul14;

void() wiz_soultouch =
{	
	if (self.health <= 0)
		return;

	if (!other.takedamage)
	{
		self.think = wiz_soul14;
		self.nextthink = time + 0.1;	
		return;
	}

	self.touch = __NULL__;
	self.think = wiz_bite3;	
	self.velocity = '0 0 0';
	self.movetype = MOVETYPE_STEP;
	self.nextthink = time + 0.01;	

};

void()	wiz_soul1	=[	54,		wiz_soul2	] 
{
	sound (self, CHAN_WEAPON, "wizard/wattack.wav", 1, ATTN_NORM);

	ai_face();
	self.movetype = MOVETYPE_FLY;
	local float vel;
	vel = CalcVelocity(800, self.origin - self.enemy.origin, 0);

	self.touch = wiz_soultouch;
	self.velocity = normalize(self.enemy.origin - self.origin)*vel;
	
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
};

void()	wiz_soul2	=[	56,		wiz_soul3	] {};
void()	wiz_soul3	=[	57,		wiz_soul4	] {};
void()	wiz_soul4	=[	58,		wiz_soul5	] {};
void()	wiz_soul5	=[	59,		wiz_soul6	] {};
void()	wiz_soul6	=[	60,		wiz_soul7	] {};
void()	wiz_soul7	=[	61,		wiz_soul8	] {};
void()	wiz_soul8	=[	62,		wiz_soul9	] {};
void()	wiz_soul9	=[	63,		wiz_soul10	] {};
void()	wiz_soul10	=[	64,		wiz_soul11	] {};
void()	wiz_soul11	=[	65,		wiz_soul12	] {};
void()	wiz_soul12	=[	66,		wiz_soul13	] {};
void()	wiz_soul13	=[	67,		wiz_soul14	] {};
void()	wiz_soul14	=[	68,		wiz_soul15	] {ai_face(); self.velocity = '0 0 0'; self.movetype = MOVETYPE_STEP;  self.touch = __NULL__;};
void()	wiz_soul15	=[	69,		wiz_soul16	] {ai_face();};
void()	wiz_soul16	=[	70,		wiz_run1	] {ai_face();};


void()	wiz_fast1	=[	29,		wiz_fast2	] {ai_face();};
void()	wiz_fast2	=[	30,		wiz_fast3	] {ai_face();};
void()	wiz_fast3	=[	31,		wiz_fast4	] {ai_face();};
void()	wiz_fast4	=[	32,		wiz_fast5	] {ai_face();};
void()	wiz_fast5	=[	33,		wiz_fast6	] {ai_face(); sound (self, CHAN_WEAPON, "wizard/wattack.wav", 1, ATTN_NORM);};
void()	wiz_fast6	=[	34,		wiz_fast7	] {ai_face();};
void()	wiz_fast7	=[	35,		wiz_fast8	] {ai_face();};
void()	wiz_fast8	=[	36,		wiz_fast9	] {ai_face();};
void()	wiz_fast9	=[	37,		wiz_fast10	] {ai_face();WizFire();};
void()	wiz_fast10	=[	38,		wiz_run1	] {ai_face();SUB_AttackFinished(self, 2);WizardAttackFinished ();};

void()	wiz_pain1	=[	42,		wiz_pain2	] {};
void()	wiz_pain2	=[	43,		wiz_pain3	] {};
void()	wiz_pain3	=[	44,		wiz_pain4	] {};
void()	wiz_pain4	=[	45,		wiz_run1	] {};

void()	wiz_death1	=[	46,		wiz_death2	] {

self.flags = self.flags - (self.flags & FL_ONGROUND);
sound (self, CHAN_VOICE, "wizard/wdeath.wav", 1, ATTN_NORM);
};
void()	wiz_death2	=[	47,		wiz_death3	] {};
void()	wiz_death3	=[	48,		wiz_death4	] {};
void()	wiz_death4	=[	49,		wiz_death5	] {};
void()	wiz_death5	=[	51,		wiz_death6	] {};
void()	wiz_death6	=[	52,		wiz_death7	] {};
void()	wiz_death7	=[	53,		wiz_death7	] {
	self.solid = SOLID_NOT; 
};

void() wiz_die =
{
	// check for gib
	if (self.health < -50)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_wizard.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		for(float i = 0; i < 3; i++)
			ThrowGib ("progs/gib3.mdl", self.health);
		remove(self);
		return;
	}
	
	// don't die a regular death again as corpse
	if((self.deadflag & DEAD_DEAD))
		return;

	// regular death

	sound (self, CHAN_VOICE, "wizard/wdeath.wav", 1, ATTN_NORM);
	self.movetype = MOVETYPE_TOSS;
	self.takedamage = DAMAGE_YES;
	self.skin = 1;
	wiz_death1 ();

	self.deadflag = DEAD_DEAD;
};


void(entity attacker, float damage) Wiz_Pain =
{
	sound (self, CHAN_VOICE, "wizard/wpain.wav", 1, ATTN_NORM);

	if(self.health < self.max_health / 2)
		self.skin = 1;

	if (random()*120 > damage)
		return;		// didn't flinch

	wiz_pain1 ();
};

float wiz_type;

void() wiz_changetypes =
{
	wiz_type = wiz_type + 1;

	if (wiz_type == 1)
		wiz_soul1 ();
	else if (wiz_type == 2)
		wiz_fast1();
	else 
	{
		wiz_fast1();
		wiz_type = 0;
	}
};
	
/*QUAKED monster_wizard (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
void() monster_wizard =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/wizard.mdl");
	precache_model ("progs/h_wizard.mdl");
	precache_model ("progs/w_spike.mdl");

	precache_sound ("wizard/hit.wav");		// used by c code
	precache_sound ("wizard/wattack.wav");
	precache_sound ("wizard/wdeath.wav");
	precache_sound ("wizard/widle1.wav");
	precache_sound ("wizard/widle2.wav");
	precache_sound ("wizard/wpain.wav");
	precache_sound ("wizard/wsight.wav");

	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/wizard.mdl");

	setsize (self, '-32 -32 -24', '32 32 40');
	self.health = 175;
	self.max_health = 175;
	self.mass = 200;
	self.skin = 0;

	self.th_stand = wiz_stand1;
	self.th_walk = wiz_walk1;
	self.th_run = wiz_run1;
	self.th_missile = wiz_changetypes;
	self.th_pain = Wiz_Pain;
	self.th_die = wiz_die;
	self.th_melee = wiz_bite1;
	self.th_checkattack = WizardCheckAttack;
		
	flymonster_start ();
};
