(
s.options.memSize_(32768);
s.waitForBoot({

	/* grains */
	//basic gauss sine
	SynthDef(\gauss_sine, {|out=0,freq=200,amp=0.1,grain_dur=0.01,pos=0|
		var sig = FSinOsc.ar(freq) * amp * EnvGen.ar(Env.sine(grain_dur),doneAction:2);
		OffsetOut.ar(out,Pan2.ar(sig,pos));
	}).add;

	//expodec or rexpodec sine
	SynthDef(\perc_sine, { |out=0,freq=200,amp=0.1,atk=0.01,rel=0.05,pos=0 |
		var sig = FSinOsc.ar(freq) * amp * EnvGen.ar(Env.perc(atk,rel),doneAction:2);
		OffsetOut.ar(out,Pan2.ar(sig,pos));
	}).add;

	//expodec sample from the drum folder only
	SynthDef(\expodec_drum_samp,{|out=0,rate=1,amp=0.1,rel=0.1,buf_num=0,pos=0|
		var env = EnvGen.ar(Env.perc(0.001,rel),doneAction:2);
		var sig = PlayBuf.ar(1,buf_num,rate/BufRateScale.kr(buf_num)) * env;
		OffsetOut.ar(out,Pan2.ar(sig,pos));
	}).add;

	// gauss enveloped pulse train
	SynthDef(\gauss_train, {|out=0,freq=100,nharm=10,amp=0.1,grain_dur=0.1,pos=0|
		var env = EnvGen.ar(Env.sine(grain_dur),doneAction:2);
		var sig = Blip.ar(freq,nharm) * amp * env;
		OffsetOut.ar(out,Pan2.ar(sig,pos));
	}).add;

	// expodec/rexpodec pulse train
	SynthDef(\perc_train, {|out=0,freq=100,nharm=10,amp=0.1,atk=0.01,rel=0.1,pos=0|
		var env = EnvGen.ar(Env.perc(atk,rel),doneAction:2);
		var sig = Blip.ar(freq,nharm) * amp * env;
		OffsetOut.ar(out,Pan2.ar(sig,pos));
	}).add;

	//pulse_convolver2 -- pulse convolver using Blip -> 1-10 second samples

	SynthDef(\pulse_convolver2, {|out=0,env_dur=1,freq=1,nharm=25,amp=0.5,rate=1,bufnum=0,bufsize=0,pos=0|
			var kernel = Blip.ar(freq,nharm) * amp;
			var env = EnvGen.ar(Env.sine(env_dur),doneAction:2);
			var input_sig = PlayBuf.ar(1,bufnum,rate/BufRateScale.kr(bufnum),
				startPos:LinRand(0,bufsize*0.5))!2 * 0.1 * env;
			var sig = Convolution.ar(input_sig, kernel,1024,0.1) * env;
			OffsetOut.ar(out, Pan2.ar(sig,pos));
	}).add;


	//ADSR cloud event envelope - fixed length - use with PatternProxy
	SynthDef(\cloud_env,{|out=0,inbus,sus_lvl=0.75,atk=0.1,dec=0.1,sus=1,rel=1|
        var env = Env([0.001,1,sus_lvl,sus_lvl,0.001],[atk,dec,sus,rel],\exp); // 4 stage adsr fixed length
		Out.ar(out, In.ar(inbus, 2) * EnvGen.kr(env,doneAction:2)); // Julian's fix... In.ar(inbus)
	}).add;

});

// initialize proxy space and pspace gui
p = ProxySpace(s,"TransGrain");

// initialize buffer Environment and load samples into global "b"
b = Environment();

)


/********************TEST SCRIPTING*********************/

currentEnvironment

~moduleSynth = "moduleSynth.scd".loadRelative[0];
~gsine = ~moduleSynth[\gauss_sine_constructor].(\gsine_pattern,\gsine_cloud,\gsine_out,\gauss_sine,\cloud_env)

// change parameters
(
~gsine.patternParam.dur = 0.1;
~gsine.patternParam.freq = Pseq((400,800..11000).pyramid,inf);
~gsine.patternParam.amp = Pwhite(0.1,0.3);
~gsine.patternParam.atk = 0.001;
~gsine.patternParam.rel = 0.005;
~gsine.patternParam.pos = Pwhite(-1,1);
//
~gsine.patternGen(3,1)
)

(
~gsine.cloudParam.sus_lvl = 0.25;
~gsine.cloudParam.dur = 10;
~gsine.cloudParam.atk = 0.1;
~gsine.cloudParam.dec = 0.5;
~gsine.cloudParam.sus = 2;
~gsine.cloudParam.rel = 5;

~gsine.cloudGen();
)


~gsine.patternGen(5,1)

~gsine.cloudGen();

~gsine.play;
~gsine.end;

~gsine.destroy;







