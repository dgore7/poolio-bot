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


  robot.hear /pls work/i, (res) ->

    token = ""

    address = "380 New York Street".replace(" ", "+")
    city = "Redlands"
    state = "CA"
    zip = "92373"

    coords = {}

    destinationAddress ="280 New York Street".replace(" ", "+")
    destinationCity = "Redlands"
    destinationState = "CA"
    destinationZip = "92373"

    destinationCoords = {}

    robot.http("http://sampleserver1.arcgisonline.com/ArcGIS/rest/services/Locators/ESRI_Geocode_USA/GeocodeServer/findAddressCandidates?f=json&Address=#{address}&City=#{city}&State=#{state}&Zip=#{zip}")
      .header('Accept', 'application/json')
      .get() (err, res, body) ->

        if err
          res.send "Encountered an error :( #{err}"
          return

        returnedData = JSON.parse body
        coords =  returnedData["candidates"][0]["location"]

        robot.http("http://sampleserver1.arcgisonline.com/ArcGIS/rest/services/Locators/ESRI_Geocode_USA/GeocodeServer/findAddressCandidates?f=json&Address=#{destinationAddress}&City=#{destinationCity}&State=#{destinationState}&Zip=#{destinationZip}")
          .header('Accept', 'application/json')
          .get() (err, res, body) ->

            if err
              res.send "Encountered an error :( #{err}"
              return

            returnedData = JSON.parse body
            destinationCoords = returnedData["candidates"][0]["location"]

            stops = coords.x + ',' + coords.y + ',' + ';' + destinationCoords.x + ',' + destinationCoords.y

            robot.http("http://route.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World/solve?f=json&token=#{token}&stops=#{stops}")
              .header('Accept', 'application/json')
              .get() (err, res, body) ->

                if err
                  res.send "Encountered an error :( #{err}"
                  return

                returnedData = JSON.parse body
                console.log returnedData
