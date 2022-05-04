#!/usr/bin/env dyalogscript

⍝ make ⍺-grams of ⍵
ngrams←{
  w←⍵⊆⍨⊃∨/(⍵=⍥⎕c⊢)¨⎕a,'čšžàâæçéèêëîïôœùûüÿäöß'
  ' '(≠⊆⊢)¨⍺(⊣,' ',⊢)/w
}

⍝ good-turing smoothing of ⍵ for ⍺-grams
gt←{
  ⍝ get n-grams
  n←⍺ngrams⍵
  ⍝ table of frequencies of n-grams
  t←↑{(⍵⌷⍨⊢)¨⍋⌽⍵}{⍺(≢⍵)}⌸n
  all_word_freq←¯1↑[2]t
  Nr←{+⌿⍵=all_word_freq}
  max_freq←⊃⌽¯1↑t
  N←Nr¨⍳max_freq
  p0←(⊃N)÷⊃⍴t
  pr←{((⍵+1)×N[⍵+1])÷N[⍵]}
  all_freq←,/∪all_word_freq
  p←p0,⊃¨pr¨¯1↓all_freq
  p,⍨⍪0,¯1↓all_freq
}

⍝ create csv files with good-turing smoothing of ⍺-grams for all lanugages
l←{
  ⍝ get all language file names
  lf←,⍥⊂⌿(⊃⍵)(2⊃⍵)∘.,⎕sh'ls ',⊃⍵
  ⍺{(⍕¨⍺ gt⊃⎕nget⊃⍵)(⎕csv⍠'Overwrite'1)'-gt',⍨2⊃⍵}¨lf
}

⍝ calculate the perplexity of the models on a file named ⍵
pp←{
  ⍵
}

main←{
  'g'=2⊃⍵:(⍎3⊃⍵)l'languages/' 'models/'
  'p'=2⊃⍵:'models/'pp 3⊃⍵
}

main 2⎕nq#'getcommandlineargs'
