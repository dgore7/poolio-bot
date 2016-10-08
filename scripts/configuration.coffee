module.exports = (robot) ->
  robot.hear /I need a ride to work/i, (res) ->
    res.send "I'll see what I can do!"
