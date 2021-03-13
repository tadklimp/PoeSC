
~phrase= (
	id: 0,
	syll_length: Ref([]),
	syll_stress: Ref(List.new),
	syll_weight: Ref(List.new),
	pitch_material: Ref(List.new),
	scale: Ref("Scale"),
	num_words: Ref("float"),
	adjs: Ref(List.new),
	nouns: Ref(List.new),
	serial_paral: Ref("Boolean"),
	reccursion: Ref("Boolean")
);

(
~length_ctrl.remove;
~length_ctrl=SimpleController(~phrase.syll_length).put(
	\value, {|values, tag, args|
		var newList1 = List.new;
		var newList2 = List.new;
		values.value.postln;
		if(~phrase.id % 2 == 0){
			"even".postln;
			values.value[1..].do{ |i|
				if (i.isKindOf(Integer)){
					newList1.add(i)
				}{
					newList1.add(Rest(1))
				}
			};
			("lenghts are: "++ values.value).postln;
			newList1.postln;
			Pdefn(\sylab_length, Pseq(newList1.asArray, 1)).condition_({|val,i|
				var size=newList1.size;("size is"++ size).postln; i.postln%size==0 });
		}{
			"odd".postln;
			values.value[1..].do{ |i|
				if (i.isKindOf(Integer)){
					newList2.add(i)
				}{
					newList2.add(Rest(1))
				}
			};
			("lenghts are: "++ values.value).postln;
			newList2.postln;
			Pdefn(\sylab_length, Pseq(newList2.asArray, 1)).condition_({|val,i|
				var size=newList2.size;("size is"++ size).postln; i.postln%size==0 });
		};
		~phrase.id = ~phrase.id+1;
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
