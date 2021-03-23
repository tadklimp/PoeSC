(
~phrase= (
	id: Ref(0),
	poly: Ref(false), // affects Pbindef players
	syll_length: Ref([]),
	syll_stress: Ref([]),
	syll_weight: Ref([]),
	num_words: 0,
	adjs: Ref([]),
	nouns: Ref([]),

	instr: Ref([]),
	pitch_material: Ref([]),
	scale: Scale.major,
	steps_octave: 12,
	stack: Ref(true), // affects Pdefns // wait until the end of phrase or not
	recursion: Ref(true), // affects Pbindef players

	fx:Ref([]),
	all_srvrs: { Server.allRunningServers },
	server: Ref(nil),
	group_main: Ref(nil),
	group_id: Ref(0),
	fx_bus: Ref(nil),
	fx_bus_index: Ref(nil),
	out: Ref(0)
);
);
~phrase.stack.value_(false)
~phrase.stack.value_(true)
~phrase.stack.value
~phrase.keys

~phrase.server
~phrase.group_main.value
~phrase.group_id
~phrase.fx_bus
~phrase.fx_bus_index
~phrase.fx.value_(12)
~phrase.use{ ~server}



(
~phrase_init.remove;
~phrase_init = SimpleController(~phrase.id).put(
	\init, { |values, tag, args|
		var all_srvrs, choose, selected, group, bus;
		// select the most chilled Server :)
		all_srvrs= ~phrase.all_srvrs.value.asArray;
		choose = all_srvrs.minIndex({ |item| item.avgCPU.round });
		selected = all_srvrs[choose]; // selected Server
		~phrase.server.value_(selected);

		// create main Group + fx_bus
		fork{
			group = Group.new(selected);
			bus = Bus.audio(selected,2);
			selected.sync;

			// assign them
			~phrase.group_main.value_(group);
			~phrase.group_id.value_(group.nodeID);
			~phrase.fx_bus.value_(bus);
			~phrase.fx_bus_index.value_(bus.index);

			// set main Out bus
			~phrase.out.value_(0);
			selected.sync;

			// start init of selected FX
			~phrase.fx.changed(\init);
			{"init done!".postln}.defer(0.5);
		};

	}
));







(
~fx_init.remove;
~fx_init = SimpleController(~phrase.fx).put(
	\init, { |values, tag, args|
		var dom;
		var id = ~phrase.id.value;
		var group = ~phrase.group_main.value;
		var server = ~phrase.server.value;
		var fx_bus = ~phrase.fx_bus_index.value;


		Pdef((\echo_++id).asSymbol,
			( type: \on, instrument: \echo,
				server: server, group: group,
				addAction: 1, out: fx_bus)).play;

		Pdef((\verb_++id).asSymbol,
			( type: \on, instrument: \verb,
				server: server, group: group,
				addAction: 1, out: fx_bus)).play;

		Pdef((\fxMonitor_++id).asSymbol,
			( type: \on, instrument: \monitor,
				server: server, group: group,
				addAction: 1, in: fx_bus, out:0)).play;


		PbdefClean(
			{ var time=3;
				fork{
					group.release(time);
					(time+1).wait;
					group.free;
					Pdef.all.keys.do{|key,i|
						if (key.asString.contains(id.asString)) { Pdef(key).remove } };
					"cleared".postln;
				}
			},
			(\player++id).asSymbol,

			\server, server,
			\group, group,
			\addAction, 0,
			// \group, Pfunc({Group.new}),
			\dur, 2,
			\degree, Pshuf([0,2,4,5]+5,inf),
			\amp, 0.01,
			\pan, Pwhite(-1,1),
			\scale, Pfunc{topEnvironment[\phrase].scale},
			\out, ~phrase.fx_bus_index.value
			/*,
			{ var time=3;
			fork{ group.release(time);
			(time+1).wait;
			group.free}
			}*/
		).play(quant:1);

	}
))

PbdefClean.all


~phrase.id.value_(~phrase.id.value+1).changed(\init);

Pdef.modulateAll(\mtranspose, 0, \scale, Scale.phrygian.tuning_(Tuning.werckmeister))
Pdef.modulateAll(\detune, PXLine(1,200,80))
Pdef.modulateAll(\detune, PLFTri(4,0,200,0))
Pdef.modulateAll(\detune, 0)
Pdef.modulateAll(\amp, 0.001)

(50-60).midiratio
(
SynthDef(\help_PlayBuf, {| out = 0, bufnum = 0, freq=1, pos=0 , gate=1, amp=0.1 |
	var env = Linen.kr(gate, 0.0005, amp, 0.7, 2);
    OffsetOut.ar(out,
        PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*(freq.cpsmidi-60).midiratio, startPos:pos, loop: 1.0)!2 * env
    )
}).add;
)
b.free
b = Buffer.readChannel(s,"/Users/Makis/Documents/Tidal/Dirt/samples/brane2/13.wav",channels:0);
b.numFrames
(Pbindef(\bufy,
	\instrument, \help_PlayBuf,
	\bufnum, b.bufnum,
	\degree, Pseq([0,1,2],inf),
	\pos, Pwhite(0.0,b.numFrames*0.25,inf),
	\dur, 0.2,
	\amp,0.3
).play)
Pbindef(\bufy).stop

Pdef.all.keysValuesDo{|key,val| if(val.isKindOf(PbdefClean) or: {val.isKindOf(Pbindef)}){ Pbindef(key, \mtranspose, 0) }}
Pdef.all.keysValuesDo{|key,val| if(val.isKindOf(PbdefClean) or: {val.isKindOf(Pbindef)}){ Pbindef(key, \scale, Scale.phrygian) }}
Pdef.all.keysValuesDo{|key,val| if(val.isKindOf(PbdefClean) or: {val.isKindOf(Pbindef)}){ Pbindef(key, \scale, Scale.lydian) }}
Pdef.all.keysValuesDo{|key,val| [key.class, val.class].postln ++ \n  }
Pdef.all.do{|x| x.stop};
Pdef.all.do{|x| x.pause};
Pdef.all.do{\mtranspose, 2};

Pdef(\player3)
.player.isPlaying

Pdef.all.values[0].pattern
Pdef.all.values[3].pattern.type_(\off)
Pdef.all.values[3].pattern.release
Pdef.all.values[1].set(\type, \off)

Pdef.all.values[1].isPlaying
~kl = Pdef.all
~kl.scanFor(\player9)
~kl.at(Pdef(\player9))
[\player8]
Pdef.all[\player7]
Pdef.all['bufy']
Pdef.all
Pdef.clear
Pdef.gui
Pdef.browse
Pdef(\fxMonitor_14).keys
Pdef("fxMonitor_4")

[\fxMonitor_4,\fxMonitor_10,\fxMonitor_11,\fxMonitor_15,\fxMonitor_12].collect{|x,i| [x,i].postln; if(x.asString.contains("11")){i.postln}}
collect

Pfset ??????????
Pspawner

Pbindef(\t1, \server, s, \degree, Pshuf((1..7),inf), \dur, 0.5, \amp, 0.01).play(quant:1);
Pdef.modulateAll(\mtranspose, Pstep(Pseq([2,4,-2,1,0],inf),8*2), \scale, Scale.major )

u=( type: \on, instrument: \monitor,
	server: ~phrase.server.value, group: ~phrase.group_main.value,
	addAction: 1, in: ~phrase.fx_bus_index.value).play.collect({|event| ~mon = event; });

~mon.class
u.free


~lastBassEvent.class

(
~length_ctrl.remove;
~length_ctrl=SimpleController(~phrase.syll_length).put(
	\value, {|values, tag, args|
		// Here I work around the problem that ".condition_" imposes
		// on the included Pdefns. quickFix= every time place the incoming
		// list into a new List, so that the new Pdefn can register correctly
		// the List.size and use it as "wait" argument in its conditional execution.
		var newList = List.new;
		var local_env = ();
		var pos = ("pos"++~phrase.id).asSymbol; // create a new name every time

		if(~phrase.stack.value==true){// check if phrases are played throughout before new phrase begins
			// i.e. sequenced/stacked playback
			values.value.do{ |i|
				if (i.isKindOf(Integer)){
					newList.add(i)
				}{
					newList.add(Rest(1))
			}};
			local_env.put(pos, newList);// store the new list in a new local env
			local_env.postln;
			("lenghts are: "++ values.value).postln;
			Pdefn(\sylab_length, Pseq(local_env[pos].asArray, 1)).condition_({ |val,i|
				var size = local_env[pos].size;
				("New Pattern starts in ..."++ (size- i)).postln;
				i.postln%size==0;
			});
		}{ // or, switch to new Pdefn immediately
			values.value.do{ |i|
				if (i.isKindOf(Integer)){
					newList.add(i)
				}{
					newList.add(Rest(1))
			}};
			local_env.put(pos, newList);
			local_env.postln;
			("lenghts are: "++ values.value).postln;
			Pdefn(\sylab_length, Pseq(local_env[pos].asArray, 1)).reset// no conditional trigger here!
		};
	}
);

);

~length_ctrl.put(\fafa, {|a,b,c| "haha".postln})


currentEnvironment.keys

~phrase.syll_length.value_([1,2,5,3,4]).changed(\value)
~phrase.id
~checker= List.new;
~checker[2].value.class

~phrase
