#!/usr/bin/env dyalogscript

⍝ make ⍺-grams of ⍵
ngrams←{
  w←⍵⊆⍨⊃∨/(⍵=⍥⎕c⊢)¨⎕a,'čšžàâæçéèêëîïôœùûüÿäöß'
  ' '(≠⊆⊢)¨⍺(⊣,' ',⊢)/w
}

⍝ good-turing smoothing of ⍵ for ⍺-grams
gt←{
  ⍝ get n-grams
  n←⍺ ngrams ⍵
  ⍝ table of frequencies of n-grams
  t←↑{(⍵⌷⍨⊢)¨⍋⌽⍵}{⍺(≢⍵)}⌸n
  all_word_freq←¯1↑[2]t
  Nr←{+⌿⍵=all_word_freq}
  max_freq←⊃⌽¯1↑t
  N←Nr¨⍳max_freq
  p0←(⊃N)÷⊃⍴t
  pr←{((⍵+1)×N[⍵+1])÷N[⍵]}
  all_freq←,/∪all_word_freq
  0=⍴¯1↓all_freq:1 2⍴((⊂2⍴⊂''),⊂⍕p0)
  p←p0,⊃¨pr¨¯1↓all_freq
  ff←1↓p
  fi←¯1↓all_freq
  ((⊂2⍴⊂''),⊂⍕p0)⍪↑⊃,/{ff[⍵],⍨¨t[⍸fi[⍵]=all_word_freq]}¨⍳≢ff
}

⍝ create csv files with good-turing smoothing of ⍺-grams for all lanugages
l←{
  ⍝ get all language file names
  lf←,⍥⊂⌿⍵∘.,⎕sh'ls ',⊃⍵
  ⍺{(⍕¨⍺gt⊃⎕nget⊃⍵)(⎕csv⍠'Overwrite'1)(⍕⍺),⍨'-gt',⍨2⊃⍵}¨lf
}

⍝ kneser-ney smoothing
kn←{
  n←⍺ngrams⍵
  one←1ngrams⍵
  d←.7
  p_cont←{(≢n)÷⍨+/(⊃⌽)¨(⍵∘≡¨⊢)¨n}
  p_prev←{+/⊃¨(⍵∘≡¨⊢)¨n}
  pkn←{
    ⍝ number of instances of ⍺ in n
    inst←⊃+/⍺∘≡¨¨one
    a←inst÷⍨0⌈d-⍨+/⍺⍵∘≡¨n
    lambda←(p_prev⍺)×d÷inst
    a×lambda×p_cont⍵
  }
  ⊃pkn/⊃n
}

⍝ create csv files with kneser-ney smoothing of ⍺-grams for all lanugages
m←{
  ⍝ get all language file names
  lf←,⍥⊂⌿⍵∘.,⎕sh'ls ',⊃⍵
  ⍺{(⍕¨⍺kn⊃⎕nget⊃⍵)(⎕csv⍠'Overwrite'1)'-kn',⍨2⊃⍵}¨lf
}

⍝ calculate the perplexity of the models on a file named ⍵
pp←{
  ⍵
}

main←{
  'g'=2⊃⍵:(⍎3⊃⍵)l'languages/' 'models/'
  'k'=2⊃⍵:(⍎3⊃⍵)m'languages/' 'models/'
  'p'=2⊃⍵:'models/'pp 3⊃⍵
}

main 2⎕nq#'getcommandlineargs'
