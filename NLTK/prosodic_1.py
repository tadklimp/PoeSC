import prosodic as p


# print(dir(p.Text))
print()

# text = p.Text('true in my heart like a miniscule dart out of you')
# text = p.Text('''Whoever You Are Holding Me Now in Hand''')
text = p.Text('''and then as I thought the old thought of likenesses,
These you presented to me you fish shaped island,
As I wended the shores I know,
As I walk'd with that electric self seeking types.
''')

# text.parse()
# print(dir(text))


# #syllables
# syls = [t for t in text.words()]
# print()
# print(syls)

print()
# print words larger than 1 syllables
for w in text.words():
  if len(w.syllables())>1:
    print(w)

# the same but as list comprehension 
# longies = [w for w in text.words() if len(w.syllables())>1 ]
# print(longies)

#get syllabes (IPA)
# for w in text.words():
#   for i in w.syllables():
#     print(i)


# # get Stress
# for w in text.words():
#   stress = w.getStress()
#   # for i in (w.getStress():
#   print(stress)
print()

# print lines
print(text.lines())
print()

# #legth of syllables in each word -> it can represent note length
# print([len(w.syllables()) for w in text.words()])
# print()

# #print stresses -> it can represent note amplitude
# stress = [s.getStress() for s in text.words()]    
# print(stress)

# return a list of [syllable_length, syllable_stress, syllable_weight] 
def extract_meter(text):
  new_list = []
  for w in text.words():
    new_list.append([len(w.syllables()), w.getStress(),w.weight])
  return new_list


print(extract_meter(text))