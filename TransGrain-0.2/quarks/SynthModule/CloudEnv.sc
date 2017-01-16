CloudEnv {

	var <server, <proxy, <>inbus_name, <env_name, <>param;

	classvar <n_instances = 0, <synth_name = \cloud_env;

	*new { | server, proxy, inbus_name, env_name |
		n_instances = n_instances + 1;
		^super.newCopyArgs(server ? Server.default, proxy, inbus_name, env_name).initSynth.initParam;
	}

	initSynth {

		if(SynthDescLib.global.at(synth_name) == nil, {

			//ADSR cloud event envelope - fixed length - use with PatternProxy
			SynthDef(synth_name, {|out=0,inbus,sus_lvl=0.75,atk=0.1,dec=0.1,sus=1,rel=1|
				var env = Env([0.001,1,sus_lvl,sus_lvl,0.001],[atk,dec,sus,rel],\exp); // 4 stage adsr fixed length
				Out.ar(out, In.ar(inbus, 2) * EnvGen.kr(env,doneAction:2)); // Julian's fix... In.ar(inbus)
			}).add;

		},{
			"SynthDef already initiated".postln;
		});
	}

	initParam {
		this.param = (
			instrument: synth_name,   // don't change the instrument !
			inbus: proxy[this.inbus_name].index,      // don't change the inbus !
			sus_lvl: 0.25,
			dur: 5,
			atk: 0.01,
			dec: 0.12,
			sus: 1,
			rel: 3
		);
	}

	// individual getters and setters for cloud_env
	getInst { ^this.param.instrument }
	getInbus { ^this.param.inbus }
	getSusLvl { ^this.param.sus_lvl }
	getDur { ^this.param.dur }
	getAtk { ^this.param.atk }
	getDec { ^this.param.dec }
	getSus { ^this.param.sus }
	getRel { ^this.param.rel }

	setInbus {|n| this.inbus_name = n; this.param.inbus = proxy[this.inbus_name].index;}
	setSusLvl {|n| this.param.sus_lvl = n }
	setDur { |n| this.param.dur = n }
	setAtk { |n| this.param.atk = n }
	setDec { |n| this.param.dec = n }
	setSus { |n| this.param.sus = n }
	setRel { |n| this.param.rel = n }

	cloudGen { |fadeTime = 3|
		proxy[this.env_name] = nil;
		proxy[this.env_name].fadeTime = fadeTime;

		proxy[this.env_name] = Pbind(
			\instrument, synth_name,
			\inbus, proxy[this.inbus_name].index,

			\sus_lvl, Pif(this.param.sus_lvl.isKindOf(Function), this.param.sus_lvl.value, this.param.sus_lvl),
			\dur, Pif(this.param.dur.isKindOf(Function), this.param.dur.value , this.param.dur),
			\atk, Pif(this.param.atk.isKindOf(Function), this.param.atk.value, this.param.atk),
			\dec, Pif(this.param.dec.isKindOf(Function), this.param.dec.value, this.param.dec),
			\sus, Pif(this.param.sus.isKindOf(Function), this.param.sus.value, this.param.sus),
			\rel, Pif(this.param.rel.isKindOf(Function), this.param.rel.value, this.param.rel)
		);

		^proxy[this.env_name].ar;
	}
}
