---
date: "2018-04-01"
---

# Projects

A small selection of projects I've done over the years. You can see a more complete listing on my [GitHub] page.

In addition to working on various projects, I solve problems on [Project Euler][pe]. At the time of writing, I am 11th in Canada and 1064th worldwide.

## Tableflip

Tableflip is a platform for playing board games (or any other sort of turn-based game) online. The client is Vue.js and the server is a Flask app using SQLAlchemy and Postgres. Games are implemented as state machines with the rules specified in JavaScript, which allows more games to be easily added. Tableflip currently supports six games: Connect 4, Quarto, Hanabi, Euchre, Love Letter, and Homeworlds.

Play a game using [Tableflip][playtableflip] and check out the source code in the [Tableflip GitHub repo][tableflip].

## Liar's Dice

Liar's Dice is a fun dice game. I read some papers about mental poker and realized that Liar's Dice would be a really easy game to test out some of the ideas about cryptographic trust. I devised a commitment protocol that allows players to play the game and trust the results, without a trusted authority.

View the source code in the [Liar's Dice GitHub repo][dice].

## Fortuit

I made Fortuit with [neynt](http://neynt.ca/) at PennApps Winter 2015. Fortuit was inspired by something called overconfidence bias: when we make predictions about the future, we tend to be really optimistic. Fortuit aims to improve prediction-making by letting you track your predictions. This allows you calibrate your predictions and form a more accurate mental model of your mental model of the world.

Try using [Fortuit][tryfortuit]! You can test out the friends feature by adding **charles**. You can also view the source code in the [Fortuit GitHub repo][fortuit].

## Mafia

Mafia is a popular party game. A small number of players are the mafia, and their goal is to eliminate all villagers. The villagers can vote to lynch people, but they risk lynching one of their own number. Some villagers have special powers. When played in real life, a game master is required to faciliate interactions, and they can't play in the game themselves.

I created a simple, minimalistic web app that takes the place of a game master. There are existing websites that do this, but they overcomplicate things with variations and accounts. Plus, it was a fun way to play with AngularJS and Socket.io.

You can view the source code in the [Mafia GitHub repo][mafia].

## Depnunkei

The computer science club at my high school ran a two-week long idle game challenge. An idle game is a game in which most of your time is spent waiting; a perfect example is Cookie Clicker.

My project was Depnunkei, a stock-trading game written in HTML5 and JavaScript. The stocks are unique and randomly generated each game, and more enter the market as companies go bankrupt.

Try playing [Depnunkei][playdepnunkei] and see how much money you can make. You can also view the source code in the [Depnunkei GitHub repo][depnunkei].

## Condi

Condi was my entry to a casual 7DRL (7-day roguelike) among some friends. Condi features random dungeon generation, randomly generated items with special effects, and absolutely no balance. The dungeons gradually get harder as your character gains levels.

You can view the source code in the [Condi GitHub repo][condi].

[pe]: https://projecteuler.net/progress=semicolon7
[playtableflip]: https://tableflip.semicolon.ca
[tableflip]: https://github.com/neynt/tableflip
[dice]: https://github.com/czinn/liars-dice
[tryfortuit]: http://fortuit.semicolon.ca
[fortuit]: https://github.com/czinn/fortuit
[mafia]: https://github.com/czinn/mafia
[playdepnunkei]: /depnunkei
[depnunkei]: https://github.com/czinn/depnunkei
[condi]: https://github.com/czinn/condi
[github]: https://github.com/czinn
