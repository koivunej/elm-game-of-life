Simple and probably buggy Game Of Life in Elm
=============================================

> "It compiles"

Code I started writing at [Elmsinki meetup #2 at 2016-05-04](http://www.meetup.com/Elmsinki/events/230661980/) and got it working the next day.
I tried to do most of obvious cleanup but not sure what kind of refactorings should be done.
Any feedback is very welcome.

Runnable using `elm package install -y && elm reactor` from the working directory and going to <http://127.0.0.1:8000/index.html> or [directly in your browser](http://koivunej.github.io/elm-game-of-life/).

After writing this I remembered to google on the topic and there is at least one blog post/tutorial related to elm and game of life: <http://sonnym.github.io/2014/05/05/writing-game-of-life-in-elm/>.
I did not however follow it at all.
There are also other github repositories named `elm-game-of-life`.

I started working from [elm-tutorial.org's StartApp.Simple phase](http://www.elm-tutorial.org/030_elm_arch/startapp.html) by first doing the rendering, then the wrapping offset location function, then the game rules.
I moved on to plain `StartApp` to get `Effects.tick` once I had single steppable game view via button clicks.

Things I couldn't figure out
----------------------------

I wanted to utilize `Time.fpsWhen` with controllable fps but couldn't realize how to control it with the current state.
I ended up stepping and rendering everything on each tick after user has pressed the "Start" button.
Building a controllable delay while operating on `requestAnimationFrame` or `Effects.tick` seemed too wasteful.
