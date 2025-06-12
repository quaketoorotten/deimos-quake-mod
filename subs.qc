

void() SUB_Null = {};

void() SUB_Remove = {remove(self);};


/*
QuakeEd only writes a single float for angles (bad idea), so up and down are
just constant angles.
*/
void() SetMovedir =
{
	if (self.angles == '0 -1 0')
		self.movedir = '0 0 1';
	else if (self.angles == '0 -2 0')
		self.movedir = '0 0 -1';
	else
	{
		makevectors (self.angles);
		self.movedir = v_forward;
	}
	
	self.angles = '0 0 0';
};

/*
================
InitTrigger
================
*/
void() InitTrigger =
{
// trigger angles are used for one-way touches.  An angle of 0 is assumed
// to mean no restrictions, so use a yaw of 360 instead.
	if (self.angles != '0 0 0')
		SetMovedir ();
	self.solid = SOLID_TRIGGER;
	setmodel (self, self.model);	// set size and link into world
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";
};

void SpawnBlood(vector org, vector v, float col, float dmg);

void(entity e) corpsetoucherboom =
{
	local entity olself;
	olself = self;
	self = e;
	self.missile_explode();
	self = olself;
};

void() corpse_detect =
{	
	local float damage;

	if(!(other.flags & FL_DEADMONSTER))
		return;
	if((other.flags & FL_MONSTER))
		return;
	
	if(other.dmg)
		damage = other.dmg;
	else
		damage = 0;
		
	T_Damage(self, other, other.owner, damage, 0);
	if(!self.color)
		SpawnBlood (self.origin, '0 0 80' , 73, damage*1.25);
	else
		SpawnBlood (self.origin, '0 0 80' , self.color, damage*1.25);
	
	if(other.missile_explode)
		corpsetoucherboom(other);
	else
		remove(other);
};

void() InitCorpse =
{	
	self.flags |= FL_DEADMONSTER;
	self.solid = SOLID_TRIGGER;
	setorigin (self, self.origin);	// link into world
	self.touch = corpse_detect;
	self.movetype = MOVETYPE_NONE; // so that the bfg won't target it, saving edict space
	self.velocity = '0 0 0';
	self.mass = 0;
};

/*
=============
SUB_CalcMove

calculate self.velocity and self.nextthink to reach dest from
self.origin traveling at speed
===============
*/
void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt =
{
local entity	stemp;
	stemp = self;
	self = ent;

	SUB_CalcMove (tdest, tspeed, func);
	self = stemp;
};

void(vector tdest, float tspeed, void() func) SUB_CalcMove =
{
local vector	vdestdelta;
local float		len, traveltime;

	if (!tspeed)
		objerror("No speed is defined!");

	self.think1 = func;
	self.finaldest = tdest;
	self.think = SUB_CalcMoveDone;

	if (tdest == self.origin)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}
		
// set destdelta to the vector needed to move
	vdestdelta = tdest - self.origin;
	
// calculate length of vector
	len = vlen (vdestdelta);
	
// divide by speed to get time to reach dest
	traveltime = len / tspeed;

	if (traveltime < 0.1)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}
	
// set nextthink to trigger a think when dest is reached
	self.nextthink = self.ltime + traveltime;

// scale the destdelta vector by the time spent traveling to get velocity
	self.velocity = vdestdelta * (1/traveltime);	// qcc won't take vec/float	
};

/*
============
After moving, set origin to exact final destination
============
*/
void()  SUB_CalcMoveDone =
{
	setorigin(self, self.finaldest);
	self.velocity = '0 0 0';
	self.nextthink = -1;
	if (self.think1)
		self.think1();
};


/*
=============
SUB_CalcAngleMove

calculate self.avelocity and self.nextthink to reach destangle from
self.angles rotating 

The calling function should make sure self.think is valid
===============
*/
void(entity ent, vector destangle, float tspeed, void() func) SUB_CalcAngleMoveEnt =
{
local entity		stemp;
	stemp = self;
	self = ent;
	SUB_CalcAngleMove (destangle, tspeed, func);
	self = stemp;
};

void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove =
{
local vector	destdelta;
local float		len, traveltime;

	if (!tspeed)
		objerror("No speed is defined!");
		
// set destdelta to the vector needed to move
	destdelta = destangle - self.angles;
	
// calculate length of vector
	len = vlen (destdelta);
	
// divide by speed to get time to reach dest
	traveltime = len / tspeed;

// set nextthink to trigger a think when dest is reached
	self.nextthink = self.ltime + traveltime;

// scale the destdelta vector by the time spent traveling to get velocity
	self.avelocity = destdelta * (1 / traveltime);
	
	self.think1 = func;
	self.finalangle = destangle;
	self.think = SUB_CalcAngleMoveDone;
};

/*
============
After rotating, set angle to exact final angle
============
*/
void() SUB_CalcAngleMoveDone =
{
	self.angles = self.finalangle;
	self.avelocity = '0 0 0';
	self.nextthink = -1;
	if (self.think1)
		self.think1();
};


//=============================================================================

void() DelayThink =
{
	activator = self.enemy;
	SUB_UseTargets ();
	remove(self);
};

/*
==============================
SUB_UseTargets

the global "activator" should be set to the entity that initiated the firing.

If self.delay is set, a DelayedUse entity will be created that will actually
do the SUB_UseTargets after that many seconds have passed.

Centerprints any self.message to the activator.

Removes all entities with a targetname that match self.killtarget,
and removes them, so some events can remove other triggers.

Search for (string)targetname in all entities that
match (string)self.target and call their .use function

==============================
*/
void() SUB_UseTargets =
{
	local entity t, stemp, otemp, act;

//
// check for a delay
//
	if (self.delay)
	{
	// create a temp object to fire at a later time
		t = spawn();
		t.classname = "DelayedUse";
		t.nextthink = time + self.delay;
		t.think = DelayThink;
		t.enemy = activator;
		t.message = self.message;
		t.killtarget = self.killtarget;
		t.target = self.target;
		return;
	}
	
	
//
// print the message
//
	if (activator.classname == "player" && self.message != "")
	{
		centerprint (activator, self.message);
		if (!self.noise)
			sound (activator, CHAN_VOICE, "misc/talk1.wav", 1, ATTN_NORM);
	}

//
// kill the killtagets
//
	if (self.killtarget)
	{
		t = world;
		do
		{
			t = find (t, targetname, self.killtarget);
			if (!t)
				return;
			if((t.classname == "func_breakable") && (t.targetname == self.killtarget)) // make breakables blow up not disapear
			{
				T_Damage (t, activator, activator, t.health, 0);
				return;
			}
			else
				remove (t);
		} while ( 1 );
	}
	
//
// fire targets
//
	if (self.target)
	{
		act = activator;
		t = world;
		do
		{
			t = find (t, targetname, self.target);
			if (!t)
			{
				return;
			}
			stemp = self;
			otemp = other;
			self = t;
			other = stemp;
			if (self.use != SUB_Null)
			{
				if (self.use)
					self.use ();
			}
			self = stemp;
			other = otemp;
			activator = act;
		} while ( 1 );
	}
	

};

//=============================================================================

void(entity e, float normal) SUB_AttackFinished =
{
	e.cnt = 0;

	if(skill !=3)
		e.attack_finished = time + normal;
};

void(entity e, float normal) SUB_AttackFinishedSpecial =
{
	e.cnt = 0;
      e.attack_finished = time + normal;
};

float (entity caller, entity targ) visible;

void (void() thinkst) SUB_CheckRefire =
{
	if (skill != 3)
		return;
	if (self.cnt == 1)
		return;
	if (!visible (self, self.enemy))
		return;
	self.cnt = 1;
	self.think = thinkst;
};

void (void() thinkst) SUB_CheckRefireSpecial=
{
	if (self.cnt == 1)
		return;
	if (!visible (self, self.enemy))
		return;
	self.cnt = 1;
	self.think = thinkst;
};

//=============================================================================

float mathlib_accuracy;

float(float num) sqrt = // copied from copper XD
{
	local float apr;

	if(mathlib_accuracy <= 0)
		mathlib_accuracy = 0.001;   //this sets a level of accuracy, it's a global float

	if (num < mathlib_accuracy)
		return 0;
	if (num>1)
		apr = num;
	else
		apr = 1;
	do
	{
		apr = (num + (apr * apr)) / (2 * apr);
	}
	while (fabs((apr * apr) - num) > (num * mathlib_accuracy));
	return apr;
};

float(float a, float b) mod =
{
	return a - (floor(a / b) * b);
}

float (float accel, vector dis, float discap) CalcVelocity = 
{
	local float lendis;	
	local float vel;
	
	lendis = vlen(dis) - discap;

	vel = 2*accel*lendis;
	vel = ceil(sqrt(vel));
	return vel;
}

vector (float x, float y, float z) setvector = 
{
	local vector v;
	v_x = x;
	v_y = y;
	v_z = z;
	return v;
}

vector (vector a, vector b, vector forward, vector right) ProjectAim =
{
	local vector spit;
	spit = a + forward * b[0] + right * b[1];
	spit_z = spit_z + b[2];
	
	return spit;
}

//=============================================================================

void(vector start, vector pos) line = 
{
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_BEAM);

	WriteEntity(MSG_BROADCAST, self);

	WriteCoord(MSG_BROADCAST, start_x);
	WriteCoord(MSG_BROADCAST, start_y);
	WriteCoord(MSG_BROADCAST, start_z);
	WriteCoord(MSG_BROADCAST, pos_x);
	WriteCoord(MSG_BROADCAST, pos_y);
	WriteCoord(MSG_BROADCAST, pos_z);
}

void(vector start, vector pos) line2 = 
{
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_LIGHTNING1);

	WriteEntity(MSG_BROADCAST, self);

	WriteCoord(MSG_BROADCAST, start_x);
	WriteCoord(MSG_BROADCAST, start_y);
	WriteCoord(MSG_BROADCAST, start_z);
	WriteCoord(MSG_BROADCAST, pos_x);
	WriteCoord(MSG_BROADCAST, pos_y);
	WriteCoord(MSG_BROADCAST, pos_z);
}

