module.exports = (robot) ->
  #listOfUsers = ['augustk', 'aurykenb', 'dgore7'];
  robot.hear /I need a ride to work/i, (res) ->
    console.log res.message.user.name
    res.send "I'll see what I can do!"
    for uname in listOfUsers
      robot.messageRoom "@#{uname}", "Hey #{uname}, @#{res.message.user.name} is looking for a ride"

  robot.hear /I want in/i, (res) ->
    res.send "I'm happy to hear that!\nJust tell me your address(add, city, state), and you're in!"

  robot.hear /d+\s+w+,\s*w+,\s*w+/, (outerRes) ->
    robot.http()
      .post() (err, res, body) ->
        # August's code!
        if err
          outerRes.send "Bot malfunction. Beep. Boop."
        if res.statusCode isnt 200
          outerRes.send "Something went wrong ):"
        else outerRes.send "You're in! Poolio will pool as he see's fit"
