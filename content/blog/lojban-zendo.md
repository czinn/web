---
title: Lojban and Zendo
date: "2017-06-28"
---

<style>thead { display: none; }</style>

<img src="/blog/assets/lojban_zendo.jpg" title="Zendo pyramids" class="lg">

[Zendo][zendo] is an interesting game. The full rules are on the linked page, but here's the short version:

- There are pyramids of different colours and sizes that can be arranged in various ways.
- One player has a secret rule that matches some arrangements, but not others.
- Players can guess rules, and a counterexample (which fits the secret rule but not the proposed rule) is constructed for incorrect guesses.

Examples of rules are "contains a blue pyramid", "contains two small pyramids", "all medium pyramids are touching a green pyramid", and even complicated monstrosities like "pyramids are large if they are green or yellow, and there are no blue mediums".

However, ambiguity in rules can be a problem, especially when players are guessing rules. Here are some examples of ambiguity:

- "contains two small pyramids": at least two, or exactly two?
- "all medium pyramids are touching a green pyramid": does this match an arrangement with no medium pyramids?
- "blue on top of yellow": do all blues have to be on top of a yellow? do all yellows have to be under a blue? what if there's no blue, or no yellow, or neither? directly on top or just somewhere above?

It isn't too difficult to disambiguate rules, but unambiguous rules can get pretty wordy, and asking for disambiguation can give away information. What if there were a better way?

## Enter Lojban

Lojban is a constructed language designed to be logical and avoid ambiguity. It turns out that it's quite easy to express a large variety of Zendo rules unambiguously in Lojban, and the rules are <del>often</del> sometimes more concise than their English equivalents! I also find that thinking about rules in Lojban helps me consider a different set of rules, because the rules that are easily expressed in Lojban are different from those easily expressed in English.

I'm going to briefly cover the parts of the language relevant to constructing Zendo rules. That means a lot of less relevant details are going to be omitted, and other parts will be left to be inferred from examples. If you want to pronounce the words right in your head, check out the [phonology guide](https://mw.lojban.org/papri/pronunciation_guide_in_English). For more Lojban resources, check out the [end of this post](#more-about-lojban).

## Logical Quantified Existential Variables

The most important word for Zendo rules is `da`. It means "there is *at least one* thing you can substitute here such that the sentence is true". Together with the word `xunre`, which means "x1 is red"[^places], we can write the simplest possible rule:

[^places]: Verbs[^verbs] in Lojban (and yes, red is a verb) have places (denoted `x1`, `x2`...) which are filled by nouns. Word order determines which nouns go in which places.

[^verbs]: The actual term for a Lojban "verb" is `selbri`, which means (roughly) "predicate relationship".

 | 
---|---
`da xunre` | "there is at least one red pyramid"[^pedantic] 

[^pedantic]: Technically, `da xunre` just says that somewhere, something is red. However, in the context of a game of Zendo, one can assume that the universe is confined to the arrangement under question, and that the object is a pyramid unless otherwise specified. If you want to be pedantic, you could replace `da` with `da poi pirmidi gi'e pagbu le stura`. You could also say `pirmidi gi'e pagbu le stura cei broda`, which assign that qualifier to `broda`, and then you only have to say `da poi broda` from then on, while still being just as pedantic as before. From this point forward, I'm just going to use `da`.

Notice the emphasis on "at least one". The default quantity is `su'o pa`, "at least one", but any number (or number-like word) can be stuck in front of `da`.

 | 
---|---
`pa da xunre` | "there is exactly one red pyramid"
`re da xunre` | "there are exactly two red pyramids"
`su'o re da xunre` | "there are at least two red pyramids"
`no da xunre` | "there are no red pyramids"
`ro da xunre` | "every pyramid is red"

Take special note of the last two examples. Even though these are called "existential" variables, they can also express non-existence with `no` (zero), or universality with `ro` (all).

The words `de` and `di` are the same as `da`, but represent different variables. Multiple variables can be used together.

 | 
---|---
`farsni` | "x1 points at x2"
`da farsni de` | "there is a pyramid pointing at another pyramid"
`no da farsni su'o re de` | "there is no pyramid that points at two or more pyramids"
`da farsni re de` | "there is a pyramid that points at exactly two pyramids"

The meaning can change if variables are introduced in a different order. To do this, `se farsni` is used, which means "x1 is pointed at by x2" (`se` swaps the first and second places).

 | 
---|---
`da farsni no de` | "some pyramid points at no pyramids"
`no de se farsni da` | "no pyramid is pointed at by some pyramid"

This matches how existential quantifiers work in math:

 | 
---|---
`da farsni no de` | `∃X: ¬∃Y: X points at Y`
`no de se farsni da` | `¬∃Y: ∃X: X points at Y`

To avoid reordering words in the sentence itself, you can declare the quantifiers separately in the prenex, which is separated from the main sentence by the word `zo'u`[^zohu]:

 | 
---|---
`da farsni no de` | `da no de zo'u da farsni de`
`no de se farsni da` | `no de da zo'u da farsni de`

[^zohu]: In fact, using `zo'u` is considered the "normal" way to use existential variables. I'm using the abbreviated form in this post because these are relatively simple sentences that don't need to sacrifice brevity for clarity.

## Restrictive Relative Clauses

The word `ro` (all) was mentioned in the last section, but I didn't give many examples. That's because you usually want to say "all pyramids which [condition]" rather than just "all pyramids". The word `poi` attaches a restrictive relative clause to the preceding object; you can read it as "which". The word `ku'o` is placed after the relative clause to separate it from the rest of the sentence, if the relative clause isn't at the end of the sentence.

 | 
---|---
`blanu` | "x1 is blue"
`sraji` | "x1 is upright"
`ro da poi blanu ku'o sraji` | "all blue pyramids are upright"
`ro da poi farsni de ku'o xunre` | "all pyramids which point at another pyramid are red"
`pencu` | "x1 touches x2"
`da pencu de poi farsni pa di` | "there is a pyramid touching a pyramid that points at exactly one pyramid"

## Logical Connectives

The Lojban connectives are `je` (and), `ja` (or), and `jo` (if and only if)[^ju]. You can stick `na` before or `nai` after to negate the corresponding operand.

[^ju]: There's also `ju` (whether or not), but it's not useful in this context.

 | 
---|---
`da sraji je blanu` | "there is an upright blue pyramid"
`da sraji ja blanu` | "there is a pyramid that is upright or blue (or both)"
`da sraji na ja nai blanu` | "there is a pyramid that is neither upright nor blue"
`da sraji jo blanu` | "there is an upright blue pyramid or a non-upright non-blue pyramid"
`ro da sraji jo blanu` | "pyramids are upright if and only if they are blue"
`barda` | "x1 is large"
`ro da barda na ja xunre` | "pyramids are not large or are red"<br>"if a pyramid is large, then it is also red"

Note that the last example could be expressed with a relative clause as well:

 | 
---|---
`ro da poi barda ku'o xunre` | "all large pyramids are red"

You can connect multiple phrases together using `.i` followed by the desired connective.

 | 
---|---
`da sraji .i jo no de blanu` | "there is an upright pyramid if and only if there are no blue pyramids"

If there are two or more logical connectives, they are evaluated using left-associativity (left to right).

 | 
---|---
`ro da blanu ja xunre je barda` | "all pyramids are blue or red, and are large"
`ro da blanu je barda ja xunre` | "all pyramids are blue and large, or are red"

## Comparisons

The word `zmadu` means "x1 is greater than x2 in property x3". To create a property to fill the third spot, `lo ka` (which means "the property of") is used along with a subphrase. The most common property in a comparison is `lo ka barda` (the property of bigness).

 | 
---|---
`da zmadu de lo ka barda` | "there is a pyramid bigger than another pyramid"
`da poi xunre zmadu de poi blanu ku'o lo ka barda` | "there is a red pyramid bigger than a blue pyramid"
`da poi xunre zmadu ro de poi blanu ku'o lo ka barda` | "there is a red pyramid bigger than all blue pyramids (if any)"

Another useful word that takes a property is `traji`, which means "x1 is the most x2".

 | 
---|---
`galtu` | "x1 is high up"
`da poi traji lo ka galtu ku'o xunre` | "the highest pyramid is red"

## Vocabulary

Here's a big list of Lojban words for constructing Zendo rules.

 | 
---|---
**Things** | `pirmidi`: x1 is a pyramid<br>`barna`: x1 is a spot on x2<br>`kamju`: x1 is a column/stack<br>`lo loldi`: the floor/ground
**Numbers** | `no`: 0, `pa`: 1, `re`: 2, `ci`: 3, `vo`: 4<br>`mu`: 5, `xa`: 6, `ze`: 7, `bi`: 8, `so`: 9<br>`pano`: 10, `su'o`: at least [one], `ro`: all
**Sizes** | `barda`: x1 is large<br>`norbra`: x1 is medium<br>`cmalu`: x1 is small<br>`nilbra`: x1 is the size of x2
**Comparison** | `zmadu`: x1 is greater than x2 in property x3<br>`mleca`: x1 is less than x2 in property x3<br>`traji`: x1 is the most x2
**Colours** | `blanu`: x1 is blue<br>`crino`: x1 is green<br>`pelxu`: x1 is yellow<br>`xunre`: x1 is red<br>`skari`: x1 is of colour x2
**Position** | `cpana`: x1 is on x2<br>`gapru`: x1 is above x2<br>`cnita`: x1 is beneath x2<br>`pencu`: x1 touches x2<br>`farsni`: x1 points at x2<br>`galtu`: x1 is high up<br>`dizlo`: x1 is low down
**Orientation** | `sraji`: x1 is vertical/upright<br>`pinta`: x1 is horizontal/flat
**Logic** | `je`: and, `ja`: or, `jo`: if and only if
**Other Words** | `da`, `de`, `di`: existential variables (X, Y, Z)<br>`poi`: relative clause ("which")<br>`ku'o`: terminates a relative clause<br>`se`: swaps x1 and x2

## Sample Rules

See if you can figure out the meaning of these rules! Mouse over or tap the black text for the answers.

 | 
---|---
`su'o re da pelxu` | <span class="spoiler">"there are at least two yellow pyramids"</span>
`re da blanu ja cmalu` | <span class="spoiler">"there are exactly two pyramids which are blue or small"</span>
`no da norbra je crino` | <span class="spoiler">"there are no medium green pyramids"</span>
`da se skari su'o re de` | <span class="spoiler">"there are at least two pyramids of the same colour"</span>
`ci da barna de poi xunre` | <span class="spoiler">"there are exactly three spots on red pyramids"</span>
`pa da nilbra ro de poi sraji` | <span class="spoiler">"all upright pieces are the same size"</span>
`da poi blanu ku'o pencu lo loldi` | <span class="spoiler">"there is a blue pyramid touching the table"</span>
`da farsni de poi mleca da lo ka barda` | <span class="spoiler">"there is a pyramid pointing at a smaller pyramid"</span>
`ro da poi pinta ku'o farsni de poi sraji` | <span class="spoiler">"all flat pyramids point at standing pyramids"</span>

## More About Lojban

For a broader introduction to Lojban, check out [lojbo.org][lojbo]. For more detailed information about the language and learning resources, go to [lojban.org]. If you decide to try learning Lojban, I recommend reading [la&nbsp;karda][karda] first.

[zendo]: http://www.koryheath.com/zendo/
[lojbo]: http://lojbo.org
[lojban.org]: https://mw.lojban.org/papri/Lojban
[karda]: https://mw.lojban.org/papri/la_karda
