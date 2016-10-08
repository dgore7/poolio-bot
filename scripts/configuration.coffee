require('../db/db');

module.exports = (robot) ->
  listOfUsers = ['augustk', 'aurykenb', 'dgore7'];
  robot.hear /I need a ride to work/i, (res) ->
    console.log res.message.user.name
    res.send "I'll see what I can do!"

    for uname in listOfUsers
      robot.messageRoom "@#{uname}", "Hey #{uname}, @#{res.message.user.name} is looking for a ride"

  robot.hear /I want in/i, (res) ->
    res.send "I'm happy to hear that!\nJust tell me your address(add, city, state), and you're in!"

  robot.hear /(d+\s+w+,\s*w+,\s*w+)/, (outerRes) ->
    robot.http("https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=#{outerRes.matches[1].replace(' ',"+")}&destinations=New+York+City,NY&key=#{process.env.GOOGLE_MAPS_TOKEN}")
      .get() (err, res, body) ->
        console.log body
        console.log err
        console.log res
        if err
          res.send "Bot malfunction. Beep. Boop."
        if res.statusCode isnt 200
          res.send "Something went wrong ):"
        else
          user.save({userName: res.message.user.name, address: res.matches[1]})
          res.send "You're in! Poolio will pool as he see's fit"



  robot.hear /pls work/i, (res) ->



    address = "5006 hermitage ave".replace(" ", "+")
    city = "chicago"
    state = "IL"
    zip = ""
    coords = {}

    destinationAddress ="615 raintree rd".replace(" ", "+")
    destinationCity = "buffalo grove"
    destinationState = "il"
    destinationZip = ""

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

            robot.http("http://route.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World/solve?f=json&token=#{process.env.ESRI_TOKEN}&stops=#{stops}")
              .header('Accept', 'application/json')
              .get() (err, res, body) ->

                if err
                  res.send "Encountered an error :( #{err}"
                  return

                returnedData = JSON.parse body
                totalMiles=returnedData["directions"][0]["summary"]["totalLength"]

                for uname in listOfUsers
                  robot.messsageroom "@#{uname} is #{totalMiles} miles away from #{res.message.user.name}"
