# Geo50x
_It's like Where's Waldo? but for houses_

#### Video Demo:  [removed]

# Description:

Geo50x is an online carto-architectural scavenger hunt with a simple gameplay: given a photo of the exterior of a house somewhere in the world, players are tasked with locating that house within a marked search area on Google Maps. The game objective is that straightforward, although matching architectural and landscape details from the photo against possibly dozens of buildings seen on the "air" and on the "ground" might not be.

Geo50x is inspired by such childhood games as _Where's Waldo?_ and Where in the _World Is Carmen Sandiego?_. And the simple pleasures of looking out through vehicle windows and just gazing at the passing landscapes and cityscapes.

# Getting Started

### Dependencies

* cs50==9.2.5
* Flask==2.2.5
* geographiclib==2.0
* haversine==2.8.0
* Werkzeug==3.0.0

### Usage

Clone it!
```
$ git clone https://github.com/ggeerraarrdd/geo50x.git
```

Go into the project directory and run the command:
```
$ flask run
```

Open the URL after 'Running on'.

### IMPORTANT: Google Maps API Key

For the embedded maps to work, and indeed for the Flask app to even open in the first place, you need to use your own Google Maps API Key. Before you can create one, you will need to create a Google Cloud project, for which you need a Google Cloud account.
* [Set up a Google Cloud account](https://cloud.google.com)
* [Set up your Google Cloud project](https://developers.google.com/maps/documentation/javascript/cloud-setup)
* [Using API Keys](https://developers.google.com/maps/documentation/javascript/get-api-key)

In your terminal window, execute:
```
$ export MAP_API_KEY=value
```
where `value` is your API key.

Check to confirm if environmental variable is saved by executing
```
$ echo $MAP_API_KEY
```

# Gameplay

1. Players are given a photo of the exterior of a house somewhere in the world.
2. Circled on the map is the search area where they are to find that house.
3. They can zoom, pan, tilt and rotate the map. They can even go into Street View mode.
4. The photo is sourced from an Airbnb short-term rental ad. A link is provided in case the public listing has additional useful clues.
5. When players think they have located the house, they can click its doppelganger on the map and then the "Submit" button that pops up.
6. They receive points based on whether they found the correct house or not and how long it took them to do so.
6. Have fun exploring the world one house at a time!

### Scoring
1. Your total score is the combination of your base and bonus scores.
2. The max base score is 50.
      1. You get the max base score if you find the correct house.
      2. You get 0 if you submit the wrong house.
      3. You are allowed multiple attempts.
            1. On the second attempt, the max base score is lowered to 40.
            2. On the the third attempt, 30.
            3. Further attempts will not lower the max base score.
            4. If you leave the game page such as closing the window or navigating to another page within 10 seconds, the current game will not be counted as an attempt.
3. The max bonus score is 50.
      1. The bonus score is based on how long it takes you to find the correct house.
      2. A multiplier is calculated using the formula: e^−0.0054(x-1)^2, where x is the time elapsed to find the house.
      3. x is cumulative, so times in previous attempts are included.
      4. Essentially you get the full 50 bonus points if you find the house in 2 minutes or less. You get 1 point if found in 30 minutes. After 30 minutes, no bonus.
4. So if you find the house on your first attempt and in 2 minutes or less, you get 100 points.

### Notes on the game view design layout

One of the critical design issues that needed to be resolved during the early phases of the development process was how to present the two key elements of the game view: the map and the location info, most important of which is the photo of the house. How much webpage real estate does each one get?

The location info has to be presented alongside the map for continuous reference. The photo also has to be at a size dimension that enough architectural details can be easily discerned for matching purposes. But this element must take up a certain amount of space so as not to impede map navigation, which is the main actity of the entire app.

The first strategy was to create a sidebar of the location info in the form of an `iframe` which would display an Airbnb listing page. But I immediately encountered the issue of [same-origin policy](https://en.wikipedia.org/wiki/Same-origin_policy). I then entertained the idea of recreating the page but that would either have involved scraping the listings with python code or some other manual method, both too costly timewise. Writing the web scrapping code no doubt would have been a challenge worth pursuing but I would have ended up with large amount of unnecessary data, when probably the only things that matter are the photos. So I experimented with a sidebar of just photos, not scraped but embedded and sourced directly from Airbnb. But that, too, looked informationally excessive. The vast majority of photos are of interior spaces.

The final solution, then, is to present a single exterior photo in a "floating" `div` element on the upper right corner of the game view. It remains fixed as players navigate the map or go into Street View mode. It's there as an ever-present reference. If players need more clues, they can click the link to the Airbnb listing page. A future version might make the `div` element and its image resizable. But as it is in the current version, there is ample space for map exploration.

# Backend

### File Structure

Geo50 follows a typical Flask file structure.

1. Everything the app needs is in the directory `project`.
2. That main directory contains three `*.py` files:
    1. `app.py` defines and configures the Flask application. It handles the routing of different URLs or routes to their corresponding functions.
    2. `helpers.py` manages several of the application's functionalities, such as routing to an error message page and validating user login.
    3. `queries.py` contains all the application's functionalities that configure and setup for connecting to the SQLite database. All the functions that enable CRUD operations are centralized here.
3. That main directory also contains two subdirectories:
    1. The `static` directory contains assets used by the templates. The assets include:
         1. `*.js` files that initialize and add the maps on the webpage. They are also responsible for adding a key UI/UX element: Google Maps API's InfoWindows that extends interactivity (starting the game and submitting answers, for instance) and information text (scores, for instance)
         2. `styles.css` for styling the webpages.
         3. An `images` directory that stores all the images.
         4. And `favicon.ico` for branding purposes.
    2. The `template` directory contains only templates. They have an `.html` extension, although they contain more than just regular HTML. They contain Jinja templating codes for variables passed from `app.py`. They are among the various mechanisms that make Geo50x a dynamic web app and not a simple static website.
4. The app uses a SQLite database, here named `geo.db`.
    1. `sql.txt` contains the datbase schemas.
    2. `geo50data.csv` contains the dataset for the 50 game locations.
5. Lastly, `requirements.txt` contains a list of dependecies.

### Notes on Data Integrity and Routing

It became apparent during the development process that there needed to be a mechanism to maintain data integrity. Game scores depend, among other things, the number of attempts and the total time spent finding a house (or the accumulated time, if attempted more than once). Early versions of the app recorded these data points on the data when players submit an answer or click the "Quit Game" link on the map view. However, players could also click the links on the top navigation bar (the logo, "About", "How To Play", the search history links, and "Log Out). They could also close the browser tab/window or even quit the browser in mid-game. Those early versions would have left `null` values on the database table `games`. So it was possible that a players could spend hours in multiple attempts and receive the full 100 points.

The solution to this data integrity issue involves the `traffic()`, `traffic_out` and `traffic_in` functions, which essentially detect where links are clicked and route the "traffic" accordingly to the CRUD functions contained in `queries.py` or not. (Unfortunately, handling tab/window/browser closing events are not implementated, and therefore a current limitation of the app.)

# Future Work

As a way to outlive the CS50x course, Ge050x will be used as a vehicle to gain experience in several AWS services, such as Lightsail and/or Elastic Beanstalk to deploy the web application to the general public and RDS to play around with PostgreSQL. It's also my intention to use it to explore my professional interest in data engineering, such as ETL for more locations scraped from Airbnb (or a different public database) and data storage.

# Acknowledgments

* The distribution code for CS50's Finance problem served as a template for the app.
* The documentions for the Google Maps Platform were a daily, often hourly, read.
* Too many StackOverflow [Q&As](https://meta.stackoverflow.com/questions/267822/if-stack-overflow-doesnt-have-threads-what-the-heck-should-they-be-called) and Medium articles to mention but a couple proved immensely useful in developing two key functions
   * [Offset Latitude and Longitude by some meters accurately - Reverse Haversine](https://gis.stackexchange.com/questions/411859/offset-latitude-and-longitude-by-some-meters-accurately-reverse-haversine)
   * [Algorithm for offsetting a latitude/longitude by some amount of meters](https://gis.stackexchange.com/questions/2951/algorithm-for-offsetting-a-latitude-longitude-by-some-amount-of-meters)
