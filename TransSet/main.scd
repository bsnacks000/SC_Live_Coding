/* START */
// globals: s=server, b=buffers,p=ProxySpace, f=functions
/*
Execution order: 1. server block, 2. ProxySpace block in main.scd
                 Pattern -> Cloud -> Output on each seperate page

Be careful running pulse convolver at high rates with other synths...
memory issues
*/
s.options.memSize_(32768);
s.options.memSize;
(
s.waitForBoot({

	/* grains */
	//basic gauss sine
	SynthDef(\gauss_sine, {|out=0,freq=200,amp=0.1,grain_dur=0.01,pos=0|
		var sig = FSinOsc.ar(freq) * amp * EnvGen.ar(Env.sine(grain_dur),doneAction:2);
		OffsetOut.ar(out,Pan2.ar(sig,pos));
	}).add;

	//expodec sample from the drum folder only
	SynthDef(\perc_drum_samp,{|out=0,rate=1,amp=0.1,atk=0.001,rel=0.2,buf_num=0,pos=0|
		var env = EnvGen.ar(Env.perc(atk,rel),doneAction:2);
		var sig = PlayBuf.ar(1,buf_num,rate/BufRateScale.kr(buf_num)) * env;
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
				startPos:LinRand(0,bufsize*0.5),loop:1)!2 * 0.5 * env;
			var sig = Convolution.ar(input_sig, kernel,1024,0.1) * env;
			OffsetOut.ar(out, Pan2.ar(sig,pos));
	}).add;


	//ADSR cloud event envelope - fixed length - use with PatternProxy
	SynthDef(\cloud_env,{|out=0,inbus,sus_lvl=0.75,atk=0.1,dec=0.1,sus=1,rel=1|
        var env = Env([0.001,1,sus_lvl,sus_lvl,0.001],[atk,dec,sus,rel],\exp); // 4 stage adsr fixed length
		Out.ar(out, In.ar(inbus, 2) * EnvGen.kr(env,doneAction:2)); // Julian's fix... In.ar(inbus)
	}).add;

});
)

/** Set Environments push ProxySpace **/
(
b = Environment();
b[\prep] = PathName("Samples/prep_piano".resolveRelative).entries.collect({|sf| Buffer.read(s,sf.fullPath)});
b[\voice] = PathName("Samples/mello_voice".resolveRelative).entries.collect({|sf| Buffer.read(s,sf.fullPath)});

f = Environment();
p = ProxySpace.push(s);
ProxyMixer(p);
p.fadeTime = 5;
)

/** MASTER CONTROLS -- only use after patterns/clouds initialized**/
~out0_gsine.play;
~out0_gsine.end;

~out1_pconv.play;
~out1_pconv.end;

~out2_dsamp.play;
~out2_dsamp.end;

~out3_ptrain.play;
~out3_ptrain.end;



/***********************************/
/*...testing and pattern recipes...*/

(
Synth(\pulse_convolver2,
	[\env_dur,1,\freq,1,\nharm,25,
		\amp,1,\rate,1,\bufnum,b[\voice][0],\bufsize,b[\voice][0].numFrames,\pos,0]);
)

(
var arr = {b[\prep].choose}!5;  // pull five from array for this stream
Pdef(\p1,Pbind(\instrument,\expodec_drum_samp,
	\dur, Pseq([0.1,0.2,0.2,0.2,0.3],inf), \rate,Pxrand([Pwhite(0.1,0.7),Pwhite(-0.7,-0.1)],inf),\amp,0.05,
	\rel,0.1,
	\buf_num,Pxrand(arr,inf),\pos,0
)).play;
)
Pdef(\p1).stop;

(
var sf = (0..b[\voice].size-1).choose;  // pull n from array for this stream
Pdef(\p,Pbind(\instrument,\pulse_convolver2,
	\dur, Pbrown(0.3,2.5), \env_dur,Pwhite(3,5),\freq,Pwhite(1,45),\nharm,Pxrand([10,25,50],inf),
	\amp,Pwhite(0.5,0.9),\rate,Pbrown(0.5,1),\bufnum,b[\voice][sf],\bufsize,b[\voice][sf].numFrames,\pos,0
)).play;
)

Pdef(\p).stop

x = [1,2,3,4,5,6]
{x.choose}!1
