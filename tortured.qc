/*
==============================================================================

SOLDIER / PLAYER

==============================================================================
*/

$cd id1/models/soldier3
$origin 0 -6 24
$base base		
$skin skin


/*
==============================================================================
Totured CODE
==============================================================================
*/

.float startframe;

void()	tort_run1;

void()	tort_startrun1 = [ 38, tort_startrun2 ] {};
void()	tort_startrun2 = [ self.frame, self.think ] 
{
	self.frame = self.frame + 1;
	
	if (self.frame >= 59)
		self.think = tort_run1;
	else
		self.think = tort_startrun2;

	self.nextthink = time + 0.1;
};

void()	tort_find =
{	
	self.cnt = 1;
	if (random() <= 0.9)
		return;

	self.goalentity = self.movetarget = checkclient ();	
	self.enemy = self.goalentity;
	if (self.goalentity && self.movetarget)
	{
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
		tort_startrun1 ();
		return;
	}
}

void()	tort_stand1	=[	self.startframe,	tort_stand2	] 
{
	ai_stand(); 	
	
	if(random() < 0.2)
	{
		if (self.cnt != 1)
			tort_find ();

		sound (self, CHAN_VOICE, "tortured/idle1.wav", 1, ATTN_STATIC);
	}
};
void()	tort_stand2	=[	self.frame,	tort_stand2	] 
{
	ai_stand();
	self.frame = self.frame + 1;
	
	if (self.frame >= 18)
	{	
		self.startframe = 0;
		self.think = tort_stand1;
	}
	else
		self.think = tort_stand2;

	self.nextthink = time + 0.1;
};

void()	tort_walk1	=[	19,	tort_walk2	] {ai_walk(2); 	if(random() < 0.2)
		sound (self, CHAN_VOICE, "tortured/idle2.wav", 1, ATTN_STATIC);};
void()	tort_walk2	=[	self.frame,	self.think	] 
{
	ai_walk(2);
	self.frame ++;
	
	if (self.frame >= 28)
		self.think = tort_walk1;
	else
		self.think = tort_walk2;

	self.nextthink = time + 0.1;
};

void()	tort_run1	=[	19,	tort_run2	] {ai_run(6); 	if(random() < 0.2)
		sound (self, CHAN_VOICE, "tortured/idle2.wav", 1, ATTN_STATIC);};
void()	tort_run2	=[	self.frame,	self.think	] 
{
	ai_run(6);
	self.frame ++;
	
	if (self.frame >= 28)
		self.think = tort_run1;
	else
		self.think = tort_run2;

	self.nextthink = time + 0.1;
};



void(entity attacker, float damage)	tort_pain =
{
	local float rs;
	rs = rint((random() * 5) + 1);

	self.noise = "";
	if (rs == 1)
		self.noise = "player/pain1.wav";
	else if (rs == 2)
		self.noise = "player/pain2.wav";
	else if (rs == 3)
		self.noise = "player/pain3.wav";
	else if (rs == 4)
		self.noise = "player/pain4.wav";
	else if (rs == 5)
		self.noise = "player/pain5.wav";
	else
		self.noise = "player/pain6.wav";

	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	self.pain_finished = time + 0.3;
	return;
};

void () zombie_touch = 
{ 
        self.velocity = '0 0 0';

        if (!(other.flags & FL_ONGROUND) && (other.health) && (other.flags & FL_CLIENT))
                other.flags = other.flags + FL_ONGROUND;
};

void()	tort_die1	=[	33,	tort_die2	] { };
void()	tort_die2	=[	34,	tort_die3	] { };
void()	tort_die3	=[	35,	tort_die4	] { };
void()	tort_die4	=[	36,	tort_die4	] { };

void()	tort_dieb1	=[	29,	tort_dieb2	] { };
void()	tort_dieb2	=[	30,	tort_dieb3	] { };
void()	tort_dieb3	=[	31,	tort_dieb4	] { };
void()	tort_dieb4	=[	32,	tort_dieb4	] { };

void() tort_die =
{	
// check for gib
	if (self.health < -50)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);

		ThrowGib ("progs/gib1.mdl", -20);
		ThrowGib ("progs/gib2.mdl", -20);
		ThrowGib ("progs/gib3.mdl", -20);
		ThrowHead ("progs/h_tort.mdl", -20);

		remove(self);
		return;
	}
	
// don't die a regular death again as corpse
	if((self.deadflag & DEAD_DEAD))
		return;

// regular death
	
	self.movetype = MOVETYPE_TOSS;
	self.takedamage = DAMAGE_YES;

	self.deadflag = DEAD_DEAD;
		
	DeathSound();
		
	self.maxs_z -= 48;
	self.touch = zombie_touch;
	if (self.frame < 19)
		tort_die1 ();
	else
		tort_dieb1 ();
};

void() tortured_touch =
{
	if(!(other.flags & FL_ONGROUND) && (other.classname != "player") && (other.health <= 0))
		return;

	if (!(other.flags & FL_ONGROUND) )
	{	
		other.flags = other.flags + FL_ONGROUND;
		return;
	}

	if(!checkbottom(other)) 
		return;
	
	local float ratio;
	local vector v;
	
	ratio = other.mass / 150; // 150 is the barrel's magic mass
	v = ((self.maxs - self.mins) * 0.5 + self.absmin) - ((other.maxs - other.mins) * 0.5 + other.absmin);

	walkmove (vectoyaw(v), 46 * ratio * frametime);
};

void() cruxthink =
{
	self.frame = self.frame + 1;
	
	if(self.frame > 18) self.frame = 0;
	if(self.frame == 12)
		if(random() < 0.2)
			sound (self, CHAN_VOICE, "tortured/idle2.wav", 1, ATTN_STATIC);
	
	if(self.frame == 1)
		if(random() < 0.2)
			sound (self, CHAN_VOICE, "tortured/idle1.wav", 1, ATTN_STATIC);

	self.think = cruxthink;
	self.nextthink = time + 0.1;
}

void() func_cruxcorpse =
{
	precache_model ("progs/cruxplayer.mdl");
	precache_sound ("tortured/idle1.wav");
	precache_sound ("tortured/idle2.wav");

	setmodel (self, "progs/cruxplayer.mdl");

	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	
	self.frame = 0;
	self.think = cruxthink;
	self.nextthink = time + 0.1;
};

void() hangthink =
{	
	if(self.frame == 12)
		if(random() < 0.2)
			sound (self, CHAN_VOICE, "tortured/idle2.wav", 1, ATTN_STATIC);
	
	if(self.frame == 1)
		if(random() < 0.2)
			sound (self, CHAN_VOICE, "tortured/idle1.wav", 1, ATTN_STATIC);

	self.frame = self.frame + 1;
	
	if(self.frame > 18) self.frame = 0;

	self.think = hangthink;
	self.nextthink = time + 0.1;
}

void() func_hangcorpse =
{
	precache_model ("progs/hangplayer.mdl");
	precache_sound ("tortured/idle1.wav");
	precache_sound ("tortured/idle2.wav");	

	setmodel (self, "progs/hangplayer.mdl");

	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	
	self.startframe = mod(random()*100, 18);
	self.frame = ceil(self.startframe);
	self.think = hangthink;
	self.nextthink = time + 0.1;
};


/*QUAKED monster_army (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
void() monster_tortured =
{	
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/tortplayer.mdl");
	precache_model ("progs/h_tort.mdl");

	precache_sound ("player/pain1.wav");
	precache_sound ("player/pain2.wav");
	precache_sound ("player/pain3.wav");
	precache_sound ("player/pain4.wav");
	precache_sound ("player/pain5.wav");
	precache_sound ("player/pain6.wav");
	precache_sound ("tortured/idle1.wav");
	precache_sound ("tortured/idle2.wav");

	precache_sound ("player/udeath.wav");		// gib death

	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/tortplayer.mdl");

	setsize (self, '-16 -16 -24', '16 16 24');
	self.health = 100;
	self.max_health = 100;
	self.mass = 500;
	self.startframe = mod(random()*100, 18);
	self.frame = ceil(self.startframe);

	self.th_stand = tort_stand1;
	self.th_die = tort_die;
	self.th_walk = tort_walk1;
	self.th_pain = tort_pain;
	self.touch = tortured_touch;
	
	walkmonster_start ();
	
	self.flags |= FL_TORTURED;
};
