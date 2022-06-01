#!/usr/bin/env dyalogscript

⍝ make ⍺-grams of ⍵
ngrams←{
  w←⍵⊆⍨⊃∨/(⍵=⍥⎕c⊢)¨⎕a,'čšžàâæçéèêëîïôœùûüÿäöß'
  ng←(⊢,/(' '⍴⍨¯1+⊢),⍨' ',⊣)
  ~∘' '¨~∘' '⊃,/,w∘.ng⍺
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
  p0←(⊃N)÷≢n
  pr←{((⍵+1)×N[⍵+1])÷N[⍵]}
  all_freq←,/∪all_word_freq
  0=⍴¯1↓all_freq:1 2⍴((⊂2⍴⊂''),⊂⍕p0)
  ⍝ probabilities of seen n-grams
  po←⊃¨(≢n)÷⍨pr¯1↓all_freq
  avg_diff←(+/÷≢)|{⍵/⍨0>⍵}2-/po
  ⍝ interpolate where the values are 0
  p_inter←(⊃po){0=≢⍵:⍵⋄0=⊃⍵:(⍺+avg_diff),(⍺+avg_diff)∇1↓⍵⋄⍺,(⊃⍵)∇1↓⍵}po
  p←p0,p_inter
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
  input_file←⊃⎕nget⍵
  model_files←⎕sh'ls ',⍺,'*'
  output←{
    model_file←⎕csv⍵
    ngram_size←⌈/,≢¨1 0/model_file
    input_ngrams←ngram_size ngrams input_file
    unseen_probability←⊃⌽1⌷model_file
    seen_ngrams←,1 0/1↓model_file
    ind←1+(≢model_file)|seen_ngrams⍳input_ngrams
    perplexity←1÷×/(1÷≢input_ngrams)*⍨{⍵/⍨~0=⍵}⍎¨(,0 1/model_file)[ind]
    ⍵,⍥⊂perplexity
  }¨model_files
  ⎕←↑output
}

main←{
  'g'=2⊃⍵:(⍎3⊃⍵)l'languages/' 'models/'
  'k'=2⊃⍵:(⍎3⊃⍵)m'languages/' 'models/'
  'p'=2⊃⍵:'models/'pp 3⊃⍵
}

main 2⎕nq#'getcommandlineargs'
