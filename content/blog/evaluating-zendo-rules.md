---
title: Evaluating Zendo Rules
date: "2018-05-06"
---

Lojban is a constructed machine-parsable spoken language. It is syntactically unambiguous and its grammar is based on predicate logic.

Zendo is a game in which one player has a secret rule that describes some arrangements of pyramids (the arrangements are called "koans" in Zendo) but not others. For example, a rule could be "there are at least two pyramids of the same colour", which would be satisfied by the koan on the left but not the one on the right.

<img src="/blog/assets/sample_pyramids.svg" title="Two koans (arrangements of pyramids). The left koan has a large yellow pyramid with a medium red pyramid on top and a small red pyramid pointing at its side. The right koan has a large blue pyramid with a small green pyramid on top and a medium yellow pyramid standing at its side." class="md">

Other players attempt to determine the rule by constructing new koans and guessing plausible rules.

Last summer, I wrote a [post](http://charleszinn.ca/blog/lojban-zendo/) about how Lojban is a good fit for describing Zendo rules. Since computers can parse Lojban, I reasoned that it should be possible to write a program that can play Zendo.

When I first had this idea, I was stymied by the number of different ways to say the same rule. As a concrete example, the following Lojban sentences all describe the rule "there is a large blue pyramid"[^literal]:

    .i da barda gi'e blanu
    .i da zo'u da barda .i je da blanu
    .i da ge barda gi blanu
    .i da zo'u barda gi'e blanu vau fa da
    .i da se se barda gi'e blanu

[^literal]: Technically, it says "there exists something that is large and blue". I wrote more about this distinction in my previous post. There are only a few cases (usually involving universal quantification or negation) where it is important to specify that the thing is a pyramid.

Even though these sentences all have the same meaning, their parse trees are totally different. It would be nice if there were a way to take all these different parse trees and convert them to a semantic form that shows their interchangeability, in the same way that compilers produce the same machine code for `++i` and `i += 1`.

Thankfully, I am not the first person to have this wish. Several years ago, Martin Bays wrote [*tersmu*](https://gitlab.com/zugz/tersmu) (from a Lojban word meaning "to understand the meaning of something"), which takes Lojban text as input, parses it, and then converts the parse tree into predicate logic. For all of the sentences above, *tersmu* produces the same output:

    EX x1. (barda(x1) /\ blanu(x1))

    su'o da zo'u ge da barda gi da blanu

The first line is the predicate logic form: "there exists x<sub>1</sub> such that x<sub>1</sub> is large and x<sub>1</sub> is blue". The second line is the predicate logic converted back into Lojban in prefix form (all the quantified variables given at the start of the sentence).

Thanks to *tersmu*, the problem of interpreting Zendo rules is reduced from "determine whether this sequence of characters is a true statement about a koan" to "determine whether a proposition is true given a koan", which is far more tractable.

## Defining Types

*tersmu* is written in Haskell, so I wrote my rule evaluator in Haskell as well. Since Haskell is a strictly-typed functional programming language, I thought it would be a good opportunity to do some type-driven development, in which all types are defined before starting the implementation.

There are various points where rule evaluation can fail if the user provides an ill-formed rule. To handle these cases, I defined the following type:

    type OrError a = Either String a

A function returning an `OrError a` can either succeed and return an `a`, or it can fail with a `String` containing an error message.

For rule evaluation, I wanted a single function which takes Lojban text and a koan as input and produces a boolean value as output: whether the koan satisfies the rule represented by the Lojban text.

    satisfiesRule :: String -> Koan -> OrError Bool

*tersmu* does the hard work of turning Lojban text into predicate logic, so the responsibilities of `satisfiesRule` can be reduced:

    type Rule = [JboProp]
    tersmu :: String -> OrError Rule
    satisfiesRule :: Rule -> Koan -> OrError Bool

`JboProp` is one of *tersmu*'s types: it represents a Lojban predicate logic proposition. I'll return to its details later.

The remaining undefined type is `Koan`. In real-life Zendo, there are a myriad of ways to arrange the pyramids; they can be stacked, nested, laid on their side, rotated, and positioned in two dimensions on the table. However, this complexity doesn't really enable more interesting rules. By reducing the table to a single dimension, we can write much simpler (but still quite expressive) types for `Koan` and its components:

    data Colour = Blue | Green | Red | Yellow
    data Size = Small | Medium | Large
    data Pyramid = Pyramid Size Colour
    data Direction = Lft | Rgt
    data KoanPart
        = Stack [Pyramid]
        | Pointing Direction Pyramid 
        | Empty
    type Koan = [KoanPart]

Adjacent `KoanPart`s are assumed to be touching, unless there is an `Empty` between them to signify a space.

There are no further undefined types referenced by our current types, but there are two more types that will be useful for evaluating propositions: `Selbri` (a relation), and `Sumti` (a term which can be used in a relation). I define them as follows:

    type Selbri = Koan -> [Sumti] -> Bool
    data Sumti
        = Pyramid Int Int
        | Spot Int Int
        | Column Int 
        | SumtiColour Colour
        | SumtiSize Size
        | Ground
        | Property (Sumti -> Int)

Some explanation is due for `Sumti`. First, note that a pyramid is defined by two integers: the index of its `KoanPart`, and its index within that stack (or just 0 if it is `Pointing`). If the type for `Sumti.Pyramid` was `Pyramid Koan.Pyramid`, it would be impossible to distinguish between identical pyramids in different places, because of referential transparency. Consider the koan below; the proposition "there exists a blue pyramid which all red pyramids touch" is false, but if pyramids were referred to only by their colour and size, then the proposition would be mistakenly considered true, since all red pyramids do touch a small blue pyramid.

<img src="/blog/assets/rt_pyramids.svg" title="Two stacks, each with a small blue pyramid on top of a medium red pyramid." class="md">

`SumtiColour` and `SumtiSize` are used for the relations `skari` ("x<sub>1</sub> is coloured x<sub>2</sub>") and `nilbra` ("x<sub>1</sub> is the size of x<sub>2</sub>"), which are, in turn, used for propositions such as "there are at most two sizes" or "there are two pyramids of the same colour". `Ground` is used for propositions like "at least two pyramids touch the ground". Finally, the `Property` variant is used in relations involving comparisons, which require a function to transform their arguments into something comparable.

With all the types defined, it's now possible to start evaluating propositions.

## Traversing Propositions

A `Rule` is a list of `JboProp`s, each of which is a specialization of an abstract `Prop` type defined as:

    data Prop r t c o q
        = Not    (Prop r t c o q)
        | Connected Connective
            (Prop r t c o q) (Prop r t c o q)
        | NonLogConnected c
            (Prop r t c o q) (Prop r t c o q)
        | Quantified q
            (Maybe (Int -> Prop r t c o q))
            (Int -> Prop r t c o q)
        | Modal o (Prop r t c o q)
        | Rel    r [t]
        | Eet
        deriving (Typeable,Data)

Several of these are trivial to handle. `Eet` signifies an error in *tersmu*, and `Modal` and `NonLogConnected` (non-logical connectives) are not useful for describing Zendo rules, so they can be converted into errors. `Connected` and `Not` are simple logical functions with obvious implementations.

The constructor for `Quantified` is less clear. `q` is specialized to `JboQuantifier`, which specifies whether the quantification is existential or universal or some sort of mathematical expression (e.g. "exactly two" or "at most three"). The next argument of the constructor is the domain (which can be unspecified) and the final argument is the proposition which is being quantified. Both the domain and the quantified proposition are actually functions of an `Int`, which necessitates a diversion.

## The Bindful Monad

Quantified propositions take an integer, which is then substituted into nested expressions. As a concrete example, the sentence `da blanu` ("there is a blue pyramid") is parsed to this `JboProp`:

    Quantified (LojQuantifier Exists) Nothing
        (\x -> (Rel (Brivla "blanu") [BoundVar x]))

The nested `BoundVar` is filled at runtime with the integer given to the function. When traversing the nested propositions, you can choose a number to represent the object you're substituting into the quantified proposition, and then when you see a `BoundVar` later during traversal, you know it refers to the substituted object.

*tersmu* needs to traverse `JboProp`s in order to print them and includes a monad to facilitate the process of substituting bound variables. The `Bindful` monad is based on the `State` monad, which contains a state that can be queried and updated by computations in the monad. The `Bindful` monad provides several useful functions that we can use for traversal[^bindful]:

    type Bindful s = State (Map Int s)
    withBinding :: s -> (Int -> Bindful r) -> Bindful r
    binding :: Int -> Bindful s
    evalBindful :: Bindful a -> a

[^bindful]: The actual definition of `Bindful` is given as an instance of an typeclass and has additional functions that *tersmu* uses for traversal, but those details aren't relevant here.

`withBinding` finds the next free `Int`, binds the given value, executes the given function (supplying the `Int` to which the value was bound), unbinds the value, and returns the result. This is a very useful pattern, and in my first implementation I was able to use `Bindful` to evaluate almost all types of propositions.

However, there is a problem related to constant terms. The following example shows *tersmu*'s output for the sentence `da pencu lo loldi` ("something touches the ground"):

    loldi(c0)
    EX x1. pencu(x1,c0)

There is one proposition that identifies the constant `c0` as the ground, and then a second proposition which includes that constant as the thing being touched. I considered several possible solutions for this problem. One solution is to replace each constant with an existentially quantified variable. That would work for this example (since the ground can be included in the list of things in the universe to try substituting into a variable), but it would not work for properties. How can you iterate over all properties to find one that satisfies the propositions? How can you determine whether a function is described by `JboNPred`, which is what *tersmu* produces when the input text contains a predicate?

Instead, some mechanism is needed to assign a value to the constant when parsing the first proposition, and then to use that value in the second proposition. Essentially, I wanted the `Bindful` monad, but with a map from `JboTerm` to `Sumti` rather than `Int` to `Sumti`. I rewrote the `Bindful` monad to permit this more general mapping.

    type BindfulTerm s = State (Map JboTerm s)
    bind :: JboTerm -> s -> BindfulTerm ()
    withBoundVarBinding ::
        s -> (Int -> BindfulTerm r) -> BindfulTerm r
    binding :: JboTerm -> BindfulTerm s
    evalBindful :: BindfulTerm a -> a

This solution was able to solve the problem; it is much easier to convert a `JboNPred` into a function and bind it to a value, than to compare it with a function that has already been constructed.

## Implementation

With all the types defined and the `BindfulTerm` monad managing variables, the implementation is relatively simple. Handling `Not` and logical connectives is trivial, as previously mentioned. Relations are handled by looking up the `Selbri`, looking up the bindings for the terms using the `BindfulTerm` monad, and applying the function[^special]. Quantified propositions are handled by iterating over all `Sumti` in the `Koan` and then counting the number of true results; this method would be too inefficient if the proposition were being evaluated in a larger universe, but luckily the universe here is relatively small. 

[^special]: There is also a special case for relations that binds values to constant terms, as mentioned above.

There is a bit of complexity in the relationship functions for touching and pointing because those semantics are complicated. The arrangement below demonstrates several edge cases for touching pyramids; no two pyramids of the same colour are touching in this arrangement, but determining that algorithmically is tedious.

<img src="/blog/assets/pencu_pyramids.svg" title="Edge cases for touching pyramids." class="lg">

In parallel with the implementations, I wrote unit tests to verify that rules were being evaluated as I expected, as well as tests for each of the rules I described in my previous blog post about Lojban and Zendo. Some rules required modification, since I omitted several domain specifications that really should have been included[^domains]. Other than those changes, all the rules worked as expected.

[^domains]: For example, "all things are blue" is never true because the ground is not blue, but "all pyramids are blue" is sometimes true.

## Rule and Koan Generation

To turn the proposition evaluator into a playable game, two additional components were needed: a rule generator (to generate a rule which the player will try to guess) and a counterexample finder (when players guess an incorrect rule, they are presented with a counterexample). To generate counterexamples, I loop through a sequence of about 10 000 random koans of gradually increasing size. If no counterexample is found, I assume the rules are logically equivalent. There are ways to trick this system ("there is a blue pyramid OR there are 100 yellow pyramids" is hard to distinguish from "there is a blue pyramid"), but if a counterexample requires an extremely large number of pyramids, the rules are essentially equivalent anyway.

For rule generation, it was less important to rigorously explore the possible rule space, since the computer only needs to generate a single rule each game. I first tried to generate `JboProp`s directly, but this proved inferior to generating rules as Lojban strings for a couple reasons. First, Lojban was designed to be spoken by humans, which means its sentences are pretty easy to construct. The components of `JboProp`s were much more complicated for me to reason about when thinking about rule generation. Second, and perhaps more importantly, generating the rules as strings gave me something to print when the user gives up and asks to see the rule; *tersmu*'s conversion from a `JboProp` back into Lojban somewhat obfuscates sentences involving properties. After settling on producing strings, I came up with the following process:

1. Choose a random predicate (`Selbri`) and fill its arguments with existential variables.
2. Randomly order the quantifiers and apply random quantifiers and/or domain restrictions to each.
3. Generate 100 random koans using the koan generation process and evaluate them. Reject the rule if there aren't at least 5 satisfying and 5 nonsatisfying koans.

The final step filters out rules that are contradictions and tautologies, as well as rules that are too specific (e.g. "contains a large green pyramid and a small blue pyramid"). I fiddled with the weights for the random choices until it seemed to be generating rules of appropriate complexity. Occasionally it produces odd rules such as "for all sizes, there are no blue pyramids of that size" (which is particularly inefficient to evaluate), but determining whether a rule can be reduced to a simpler, logically equivalent rule is a project for another time.

## Conclusion

I think the success of this project well demonstrates the ability of machine-parsable constructed languages such as Lojban and other conlangs to enable human-computer interaction. The unique[^unique] features of Lojban enabled the existence of *tersmu*, which in turn made this project feasible. Writing a Zendo-playing program that uses English for rule input may have been possible, but it would have been far more difficult and far less robust to different users with different ideas about how to phrase their rules. A user would also have less certainty that their rule had been interpreted correctly.

Perhaps in several years, advances in natural-language processing will allow the creation of tools like *tersmu* that parse English sentences into predicate logic with a high degree of accuracy. In the meantime, I'll cut the "natural" out of "natural-language processing" and just use Lojban.

You can find all the code for this project (including a playable version of Zendo!) on [GitHub](https://github.com/czinn/zendoeval).

[^unique]: There are other machine-parsable constructed languages based on predicate logic (many inspired by Lojban or its predecessor, Loglan), but Lojban remains the most widely known and used.
