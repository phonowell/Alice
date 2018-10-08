$ = require 'fire-keeper'
{_} = $

# return
module.exports = ->

  j2c = require 'js2coffee'
  {code} = j2c.build 'for (var x = 0; x < width; x++)
  {
    y = height * Math.sin((twoPI * x) / width) + height;
    robot.moveMouse(x, y);
  }'

  $.i code