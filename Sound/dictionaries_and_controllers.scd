

(
~stanza = (
	id: Ref(0),
	mode: Ref('seq'),
	num_of_phrases: Ref(0),
	scale: Scale.major,
	steps_octave: Ref(12),
	phrases: Ref(List.new)
);
);

(
// initialize new Stanza
// for every new Stanza-> reset its Phrases List
// reset Phrase id counter
~stanza_init.remove;
~stanza_init = SimpleController(~stanza.id).put(
	\init, {|values, tag, args|
		~stanza.phrases.value_(List.new);
		~phrase.id.value_(0);
	};
);

// Select Pseq or Ppar as the main playback mode
~stanza_mode.remove;
~stanza_mode = SimpleController(~stanza.mode).put(
	\mode, {|values, tag, args|
		var phrases = ~stanza.phrases.value.asArray;
		case
		{~stanza.mode.value == 'seq'} {Pseq( phrases ).play(quant:1)}
		{~stanza.mode.value == 'par'} {Ppar( phrases ).play(quant:1)}
	}
);

// make sure all phrases are loaded on the Servers before the playback starts
// underlying Logic: receive the num_of_phrases and compare if the size of the
// loaded-phrases-list is the same. If yes, then start playback.
// every new phrase triggers this controller when ready.
~stanza_ready_to_play.remove;
~stanza_ready_to_play = SimpleController(~stanza.phrases).put(
	\update, {|values, tag, args|
		var phrases = ~stanza.phrases.value.asArray;
		var num_phrases = ~stanza.num_of_phrases.value;
		if (phrases.size == num_phrases){
			// if ready trigger the \mode Controller
			~stanza.mode.changed(\mode);
		}
	}
);

);



(
~phrase= (
	id: Ref(0),

	syll_length: Ref([]),
	syll_stress: Ref([]),
	syll_weight: Ref([]),
	num_words: 0,
	adjs: Ref([]),
	nouns: Ref([]),

	instr: Ref([]),
	pitch_material: Ref([]),
	pitch_offset: Ref(0),

	stack: Ref(true), // affects Pdefns // wait until the end of phrase or not
	recursion: Ref(true), // affects Pbindef players


	all_srvrs: { Server.allRunningServers },
	server: Ref(nil),
	group_main: Ref(nil),
	group_id: Ref(0),
	fx_list: Ref(()),
	fx_maker: { |id, server, group, fx_bus, fx_name|
		Pdef((fx_name++'_'++id).asSymbol,
			( type: \on, instrument: fx_name,
				server: server, group: group,
				addAction: 1, out: fx_bus)).play;
	},
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
~phrase.syll_length

Server.allRunningServers.do{|i| i.numGroups.postln}
Server.allRunningServers.do{|i| i.numUGens.postln}
Server.allRunningServers.do{|i| i.numSynths.postln}
Server.allRunningServers.do{|i| i.avgCPU.postln}
Pdef.clear

(
~phrase_init.remove;
~phrase_init = SimpleController(~phrase.id).put(
	\init, { |values, tag, args|
		var id_stanza, id_phrase, id, all_srvrs, choose, selected, group, bus;
		id_stanza = ~stanza.id.value.asSymbol;
		id_phrase = ~phrase.id.value.asSymbol;
		id = id_stanza++'_'++id_phrase;

		// select the most chilled Server :)
		all_srvrs= ~phrase.all_srvrs.value.asArray;
		// update Servers' status. It helps with choosing server when receiving very fast OSC msgs
		all_srvrs.do{|i| i.status};
		fork{
			// choose = all_srvrs.minIndex({ |item| item.avgCPU.round });
			choose = all_srvrs.minIndex({ |item| item.numGroups });
			selected = all_srvrs[choose]; // selected Server
			~phrase.server.value_(selected);
			("==============> "++selected).postln;

			// create main Group + fx_bus
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
			// selected.sync;

			// start init of selected FX
			// send [id, group, server, fxBus] as args
			~phrase.fx.changed(\init,[id, group, selected, bus]);
			{"init done!".postln}.defer(0.5);
		};

	}
));







(
~fx_init.remove;
~fx_init = SimpleController(~phrase.fx).put(
	\init, { |values, tag, args|
		var id = args[0];
		var group = args[1];
		var server = args[2];
		var fx_bus = args[3];

		args.postln;
		group.postln;

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

		~stanza.phrases.value.add(
			PbdefClean(
				//cleanup function
				{ var time=3;
					fork{
						group.release(time);
						(time+1).wait;
						fx_bus.free;
						group.free;
						Pdef.all.keys.do{ |key,i|
							if (key.asString.contains(id.asString)) { Pdef(key).remove}
						};
						"cleared".postln;
					}
				},
				// name
				(\player_++id).asSymbol,
				// Pbind
				\server, server,
				\group, group,
				\addAction, 0,
				\dur, 1,
				\degree, Pshuf([0,2,4,5]+[2,5,-2,7].choose,2),
				\amp, 0.01,
				\pan, Pwhite(-1,1),
				\scale, Pfunc{topEnvironment[\stanza].scale},
				\out, fx_bus.index
				/*,
				{ var time=3;
				fork{ group.release(time);
				(time+1).wait;
				group.free}
				}*/
		));
		~stanza.phrases.changed(\update);
	}
))

~stanza.phrases.value.asArray
Pseq(~stanza.phrases.value.asArray).play(quant:1)
~stanza.phrases.value
~stanza.id.value
~stanza.mode.value


~phrase.id.value_(~phrase.id.value+1).changed(\init);
~phrase.id.value_(~phrase.id.value+1).changed(\init);
~phrase.id.value_(~phrase.id.value+1).changed(\init);
~phrase.id.value
Pdef.clear


Pdef.modulateAll(\mtranspose, Pstep(Pseq([5,2,-2],inf),8), \scale, Scale.major.tuning_(Tuning.werckmeister))
Pdef.modulateAll(\mtranspose, -2, \scale, Scale.major.tuning_(Tuning.werckmeister))
Pdef.modulateAll(\detune, PXLine(1,200,20))
Pdef.modulateAll(\detune, PXLine(200,1,80))
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
	\dur, 0.02,
	\amp,0.1
))
Pbindef(\bufy).play
Pbindef(\bufy).stop
Pbindef(\bufy).release(4)
Pbindef(\bufy, \gtranspose, Pseq([1,4,1,2,4,7,4,3,12]*10.neg,inf))

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
~ohh = (\player++~phrase.id.value).asSymbol
Pdef.all[~ohh].pause
Pdef.all[~ohh].resume
Pdef.all[~ohh].stop
Pdef.all[~ohh].isPaused.not
Pdef.all[~ohh].isActive
Pdef.all[~ohh].hasEnded
Pdef.all[~ohh].is
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

z = '2'
y = '21'

z++'_'++y
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
		var pos = ("pos"++~phrase.id.value).asSymbol; // create a new name every time

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
