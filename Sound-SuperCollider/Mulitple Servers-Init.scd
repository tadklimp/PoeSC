



// start the Servers
(
o = ServerOptions.new;
// o.memSize = 1024*1024*3;
o.memSize = 256*8192;
o.maxNodes = 512*8192;
o.maxSynthDefs = 512*8192;
o.recSampleFormat_("float32");
o.recHeaderFormat_("wav");
o.numWireBufs = 512*8192;
o.numBuffers = 1024 * 4;
o.numInputBusChannels = 2;
o.numOutputBusChannels = 2;
o.numPrivateAudioBusChannels = 1020*4;
o.numControlBusChannels = 16384*4;
o.sampleRate = 96000 ;
o.hardwareBufferSize = 2048;
o.blockSize = 4;
//o.device = "Orion 32";
o.device = "FireWire 410 Multichannel";


w = Server.new(\serverA, NetAddr.new("localhost", 57111), options: o);
v = Server.new(\serverB, NetAddr.new("localhost", 57112), options: o);
h = Server.new(\serverC, NetAddr.new("localhost", 57113), options: o);
// q = Server.new(\serverD, NetAddr.new("localhost", 57114), options: o);
// x = Server.new(\serverX, NetAddr.new("localhost", 57115), options: o);
{
	w.bootSync;
	v.bootSync;
	h.bootSync;
	// q.bootSync;
	// x.bootSync;
	0.2.wait;

	Server.allRunningServers.do{|x| x.latency = 0.2};

	// choose the chillest Server B-)
	l = {[s,w,v,h].minIndex({|item| if (item==0.0){item;}{item.avgCPU.round;};})};

	0.2.wait;
	/////////// Synths ////////////////


	SynthDef(\pulse_noizy, { |freq, gate=1, amp|
		var time,in,filter,out,limit;
		in = Pulse.ar(freq,Rand(0,pi)!2,0.3)* EnvGen.ar(Env.adsr(releaseTime:2),gate,doneAction:2);
		// filter = RHPF.ar(in, Impulse.ar(freq*0.25, Rand(0,pi)).range(50,20000).lag3(0.004)!2,LFNoise2.ar(3!2).range(0.1,3)).lag(0.001).sin;
		filter = RHPF.ar(in,
			Impulse.ar(freq*0.25, BrownNoise.ar(0.1!2).range(0,pi)).range(50,13000).lag2(0.0005),
			LFNoise2.ar(3).range(0.1,3)).lag(0.001
		);
		// filter = HPF.ar(filter, 40);
		filter = LeakDC.ar(filter);
		filter = Compander.ar(filter,filter,0.8,0.2,0.1);
		limit = Limiter.ar(filter, 0.4,0.001);
		out = Out.ar(0,limit*amp);
	}).add;

	SynthDef(\wire, { |freq, gate=1, out=0, amp|
		var time,in,pitch,  filter,filter1, filter2, exit,limit, trig;
		time = Dseq(([Drand([4,4,8],4)] ++ 8!4 ++ 2!4),inf)*25;
		// pitch = Drand([42,20],inf);
		trig = BlitB3.ar(5);
		in = (PinkNoise.ar(0.1.dup)+Dust2.ar(70,1)).lag(0.0003);
		filter = OnePole.ar(in, (Demand.ar(trig,0,time).linlin(0,100,-1,1)) );
		filter1 = RLPF.ar(filter, Demand.ar(trig,0,time)*(freq.cpsmidi-60).midiratio,0.0009,1);
		filter2 = BHiPass4.ar(filter,(Demand.ar(trig,0,time)*100),0.5,0.5);
		filter2 = filter2 * EnvGen.ar(Env.adsr,gate,doneAction:2);
		limit = Limiter.ar(filter1+filter2, 0.7,0.001);
		limit = Normalizer.ar(limit, 0.7,0.001);
		limit= LeakDC.ar(limit);
		exit = OffsetOut.ar(out,limit*0.1);
	}).add;

	SynthDef(\sine_arp,{|freq, points=#[1,1,2,2,1,1,1], gate=1 atk=0.01, sus=0.5, rel=1, amp=0.5, out=0|
		var source, exit, th;
		th = 4;
		source = Splay.ar(Array.fill(th,{ |i|
			SinOsc.ar(freq* EnvGen.ar(
				Env.circle(points.pyramid,((points.scramble%4)/8),\step)),pi.rand,0.25)
		}),1,0.5);
		source = source * EnvGen.kr(Env.new([0,1,1,0],[atk,sus,rel]),gate, amp, doneAction:2);
		exit = Out.ar(out,source);
	}).add;

	SynthDef(\ringz_space, {|freq=200, trig=1, gate=1, out=0, decay=0.5|
		var sig, exit, env;
		sig = Ringz.ar(Impulse.ar(gate).lag3(0.0009)+ PinkNoise.ar(0.003!2),freq.lag(0.02),decay);
		env = EnvGen.ar(Env.adsr(0.001,0.8),gate,doneAction:2);
		exit = Out.ar(out, (sig*env).clip2(0.3).sin)
	}).add;


	SynthDef( \trig_buf, { |freq, bufnum, gate=1, amp, out=0|
		var trig, rin,playb,comp, sidechainEQ, all_pass, outp;
		var ball_freq = 10500 ;
		trig = Trig.ar(EnvGen.ar(Env.adsr(0.01),gate,doneAction:2));
		rin = Ringz.ar(trig, 60, 0.9,0.3);
		// buf = b.normalize;
		playb = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*((freq.cpsmidi-60).midiratio),
			startPos:TRand.ar(0,BufFrames.kr(bufnum),trig!2), loop:1, doneAction:2).sin.softclip;
		comp = Compander.ar(playb,rin,0.6,1,1/20,0.2,0.2);
		sidechainEQ = CompanderD.ar(BPF.ar(comp,7500,0.5),0.2,1.5,1.8);
		sidechainEQ = Normalizer.ar(sidechainEQ,0.8);
		comp = Compander.ar(comp,sidechainEQ,0.3,1,1/30,0.01,0.2);
		comp = CompanderD.ar(comp,0.5,0.4,0.1,0.001).softclip;
		all_pass = BAllPass.ar(comp+rin,ball_freq);
		all_pass = BAllPass.ar(all_pass,ball_freq);
		all_pass = BAllPass.ar(all_pass,ball_freq);
		all_pass = BAllPass.ar(all_pass,ball_freq);
		comp = Limiter.ar(all_pass, 0.5);
		outp = Out.ar(out, (comp*amp));
	}).add;


	SynthDef(\bufRd, { |freq, out, buf, gate=1, loop=1, pan=0, amp=0.5|
		var sig, click ,rate, start, exit, env, reset, end;
		click = Impulse.kr(0);
		rate = TRand.kr(-1.0,3.0,click);
		// rate = TRand.kr(0.99,1.01,click) * ((freq.cpsmidi-60).midiratio);
		// rate = ((freq.cpsmidi-60).midiratio);
		start = TRand.kr(1, BufFrames.kr(buf)-3,click);
		end = LFDNoise0.kr(2).range(0, (BufFrames.kr(buf))-2).round(1);

		sig = BufRd.ar(2, buf, Phasor.ar(gate,rate,start,end),loop,2).softclip * 1.5;
		// env = sig * EnvGen.ar(Env.perc(0.0001,TRand.kr(0.4,3.0,click),curve:-12 ),gate,doneAction:2);
		env = sig * EnvGen.ar(Env.new([0,1,0.9,0], [0.0001,0.3,TRand.kr(0.4,3.0,click)],curve:-12 ), gate, doneAction:2);
		env = CompanderD.ar(env,0.5,0.95,8.reciprocal,0.001);
		env = BAllPass.ar(env,7000);
		env = Pan2.ar(env, pan, amp) ;
		exit = OffsetOut.ar(out, env.softclip);
	}).add;

	//for your joy ...
	SynthDef(\for_ur_joy,{|freq, gate=1, amp=0.5, out=0|
		var triggerSpeed, trigger, syth, syth2, syth3, filter, limiter, exit;
		triggerSpeed =0.5;// LFNoise0.kr(1,1,1);
		trigger = Dust.kr(triggerSpeed);
		syth = Blip.ar(
			freq,
			Decay2.kr(trigger*2,0.001,0.05,TRand.kr(1, 55, trigger)),
			mul: EnvGen.kr(Env.adsr(0.002, 1/triggerSpeed, 0.5), gate, doneAction:2 ));
		syth2 = Blip.ar(
			{ TRand.kr(150, 500, trigger) }.dup,
			Decay2.kr(trigger*2,0.001,0.05,TRand.kr(1, 55, trigger)),
			mul: EnvGen.kr(Env.adsr(0.002, 1/triggerSpeed, 0.125), gate, doneAction:2 ));
		syth3 = SinOsc.ar(
			{TRand.kr(50, 150, trigger)}.dup,
			mul: EnvGen.kr(Env.adsr(0.001, 1/triggerSpeed, 0.5), gate, doneAction:2));
		filter = MoogFF.ar((syth+syth2+syth3)*0.33,TRand.kr(50, 6200, trigger),TRand.kr(0.1, 3, trigger))*0.25;
		limiter = Limiter.ar(FreeVerb2.ar(filter,filter,0.2,0.9,0.5),0.5,0.01);
		exit = Out.ar(out, limiter)
	}).add;

	SynthDef(\feed_flageolet,{ |freq, amp=0.5, gate=1, out=0|
		var source, local, local1, local2, pitch, filterM, filterH, exit; //CONTINUE-MID+HIGH FILTER !!!!!!!
		pitch = freq.reciprocal;

		// source =  BrownNoise.ar(0.8)*EnvGen.ar(Env.adsr,gate,amp,doneAction:2);
		source =  EnvGen.ar(Env.adsr(releaseTime:2),gate,amp,doneAction:2).tanh.distort.lag(0.001);
		local = LocalIn.ar(2) + [source, source];
		//fx feed loop
		local1 = BPF.ar(local, TRand.ar(50,1000,Impulse.ar(0)!2), 0.8, mul:1);
		local1 = DelayC.ar(local1, 0.2, pitch);
		local1 = DelayC.ar(local1, 0.2, pitch*4);

		local2 = BAllPass.ar(local,pitch);
		local2 = BAllPass.ar(local,pitch/2);
		local2 = AllpassN.ar(local2,0.2,pitch*2,0.005);
		// local2 = Compander.ar(local2,local1,0.65,0.65,0.5,mul:0.3).tanh.lag(0.0005).softclip;

		local = LeakDC.ar(local1+local2);
		local = Compander.ar(local,local,0.85,0.95,0.5,mul:0.85).tan;
		//send it back to LocalIn
		LocalOut.ar((local)*0.5);
		//exit
		exit = Out.ar(out,Limiter.ar(local,0.5));
	}).add;

	SynthDef(\feed_low,{ |freq, amp=0.5, gate=1, out=0|
		var source, local, local1, local2, local3, pitch, filterM, filterH, exit; //CONTINUE-MID+HIGH FILTER !!!!!!!
		pitch = freq.reciprocal;

		// source =  BrownNoise.ar(0.8)*EnvGen.ar(Env.adsr,gate,amp,doneAction:2);
		source = EnvGen.ar(Env.adsr(releaseTime:2),gate,amp,doneAction:2).tanh.distort.lag(0.001);
		local = LocalIn.ar(2) + [source, source];
		//fx feed loop
		local1 = BPF.ar(local, TRand.ar(50,1000,Impulse.ar(0)!2), 0.8, mul:1);
		local1 = DelayC.ar(local1, 0.2, pitch);
		local1 = DelayC.ar(local1, 0.2, pitch*4);

		local2 = BAllPass.ar(local,freq);
		local2 = BAllPass.ar(local,freq/2);
		local2 = AllpassN.ar(local2,0.2,pitch*2,0.05);
		local2 = Compander.ar(local2,local1,0.65,0.65,0.5,mul:0.3).tan;
		local2 = AllpassN.ar(local2,0.2,pitch*3,0.5);
		local2 = AllpassN.ar(local2,0.2,pitch*1.33,0.0005);
		local2 = Compander.ar(local2,local1,0.75,0.65,0.5,mul:0.3);

		local1 = Compander.ar(local1,local2,0.75,0.5,0.25,mul:0.3).tan.lag(0.0001);

		local3 = BPF.ar(local2.neg,200, mul:0.9);

		local = LeakDC.ar(local1+local2+local3);
		local = Compander.ar(local,local,0.85,0.85,0.5,mul:0.85);
		// local = Compander.ar(local,local,0.85,0.95,0.5,mul:0.85).tan;
		//send it back to LocalIn
		LocalOut.ar((local.lag(0.0025))*0.5);
		//exit
		exit = Out.ar(out,Limiter.ar(local,0.25));
	}).add;

	SynthDef(\drone1, { |freq, gate=1, out, atk=3, sus=0.5, rel=3 |
		var source, env, exit;
		source = Mix.new((1..6).collect{
			|x| Blip.ar( (x*freq),
				LFNoise1.kr([0.2,0.205]).range(0,pi),
				LFNoise1.kr([1.2,1.1]).range(0.001,2)*x.reciprocal*0.2)
		});
		env = EnvGen.ar(Env.asr(atk,sus,rel,-1),gate,doneAction:2);
		exit = Out.ar(out, source*env);
	}).add;

	SynthDef(\minor1,{|freq, dur,gate=1, amp, out|
		var sig,env,exit;
		sig = FSinOsc.ar(freq* SinOsc.kr(Rand(1.0,3.0)).range(1,1.01)).tanh.softclip;
		env = sig * EnvGen.ar(Env.linen(0.0006,dur,3,0.5),gate,amp,doneAction:2);
		env = env * AmpComp.kr(freq, 523.25,1.3);
		exit = Out.ar(out,Pan2.ar(env,LFNoise1.ar(0.3).range(-1,1)));
	}).add;

	SynthDef(\siren,{ |freq, gate=1, amp=1, out=0, ffreq=5000, freso=0.5|
		var ball_freq, sh,env,exit, osc;
		ball_freq = 375;
		a=Crackle.ar(LFNoise2.kr(0.3).range(0.5,1.9)).lag2(0.00005);//lowpass at 20k
		c = Pulse.ar(LFNoise0.kr(1!2), 0.5);
		sh = Latch.ar(a,c);
		env = EnvGen.ar(Env.adsr(0.6,0.2,0.8,2),gate,1,doneAction:2);
		osc = MoogFF.ar(LFSaw.ar([freq,freq*Rand(0.998,1.01)]),ffreq*sh,freso)*env;
		osc = BAllPass.ar(osc,ball_freq,0.5);
		osc = BAllPass.ar(osc,ball_freq,0.5);
		osc = CompanderD.ar(osc,0.5,0.25,0.5,mul:amp);
		exit = Out.ar(out,osc);
	}).add;


	//////////// FX ////////////////////
	SynthDef(\echo, { arg out=0, maxdtime=0.2, dtime=0.2, decay=2, gate=1;
		var env, in;
		env = Linen.kr(gate, 0.05, 1, 5, 2);
		in = In.ar(out, 2);
		XOut.ar(out, env, CombL.ar(in * env, maxdtime, Lag.kr(dtime, 4), decay, 1, in));
	}, [\ar, \ir, 0.1, 0.1, 0]).add;


	SynthDef( \verb, { |out=0, maxdtime=0.2, dtime=0.2, decay=2, gate=1|
		var inp, env, rev, outp;
		inp = In.ar(out,2);
		env = Linen.kr(gate, 0.05, 1, 5, 2);
		rev =  Mix.fill(15, {LPF.ar(CombC.ar(inp, maxdtime, LFNoise1.kr(0.1,0.05,0.1), 5),12020)});
		2.do({rev = CombC.ar(rev, 0.05, [0.05,0.051], decay)});
		outp = XOut.ar(out,env, (inp+(rev*0.01)) * env, )
	}).add;

	SynthDef(\FreeVerb2x2, { |out=0, mix=0.685, room=0.99, damp=0.8, amp=2|
		var signal;
		signal = In.ar(out, 2);
		ReplaceOut.ar(out,
			FreeVerb2.ar( // FreeVerb2 - true stereo UGen
				signal[0], // Left channel
				signal[1], // Right Channel
				mix, room, damp, 2
			)
		); // same params as FreeVerb 1 chn version
	}).add;

	SynthDef(\monitor, {|in=100, out=0, gate=1|
		var input, env, output;
		input = In.ar(in,2);
		env = Linen.kr(gate, 0.05, 1, 5, 2);
		// XOut.ar(out,env, input * env)
		Out.ar(out,input)
	}).add;
	2.wait;
	{
		s.plotTree;
		w.plotTree;
		v.plotTree;
		h.plotTree;
	}.defer(0.1)

}.fork;

);

// record all servers
Server.allRunningServers.do{|x| x.prepareForRecord(thisProcess.platform.recordingsDir +/+ "SC_" ++ Date.localtime.stamp ++"_"++ x.asString ++ "." ++"wav",2)}
Server.allRunningServers.do{|x| fork{x.sync; x.record(bus:0, node:x)}}
Server.allRunningServers.do{|x| x.stopRecording;}



