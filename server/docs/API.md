## Nash Server API

This server provides authentication of users, access to user information about
friends, map data, and news.

### Authentication

#### GET /account/login/{username}?password={!STRING}

```json
{
  "authKey" : "2e4b9cc2428beb7bff6a56c14d7304e472a23e890e91ef0a6b0b0380e89f9734"
}
```

#### GET /account/signup?username={!STRING}&password={!STRING}

```json
{
  "authKey" : "2e4b9cc2428beb7bff6a56c14d7304e472a23e890e91ef0a6b0b0380e89f9734"
}
```

#### POST /account/logout

```json
{
  "success" : true
}
```

### User information

#### GET /user/{username}?authKey={!STRING}

```json
{
  "username" : "jderry",
  "safe"     : true,
  "status"   : "Even though my town has corona, I am healthy and staying at home.",
  "friends"  : [
    "sderry", "pnickles", "maddieee12"
  ]
}
```

#### POST /user/{username}/mark?safe={!STRING}&authKey={!STRING}

```json
{
  "success" : true
}
```

#### POST /user/{username}/status?text={!STRING}&authKey={!STRING}

```json
{
  "success" : true
}
```

### Friend information

#### POST /friend/{friend_username}/add?authKey={!STRING}

```json
{
  "success" : true
}
```

#### POST /friend/{friend_username}/remove?authKey={!STRING}

```json
{
  "success" : true
}
```

### Map information

#### GET /map/layers?authKey={!STRING}

```json
{
  "COVID-19" : {
    "description" : "Cases of COVID-19 by county",
    "fields" : {
      "confirmedCases" : "int",
      "deaths" : "int"
    },
    "locations" : [
      {
        "longitude" : 33.466200,
        "latitude" : -82.502570,
        "confirmedCases" : 400,
        "deaths" : 20
      }
    ]
  },
  "FEMA" : {
    "description" : "Emergencies reported to FEMA including statements of emergency and natural disasters",
    "fields" : {
      "text" : "string"
    },
    "locations" : [
      {
        "longitude" : 35.996948,
        "latitude" : -78.899017,
        "text" : "Flood warning"
      }
    ]
  },
  "COVID-19 Hospitals" : {
    "description" : "Hospitals where COVID-19 testing is available",
    "fields" : {},
    // example of no locations
  }
}
```

#### GET /map/layer/{layername}?authKey={?STRING}

```json
{
  "COVID-19" : {
    "description" : "Cases of COVID-19 by county",
    "fields" : {
      "confirmedCases" : "int",
      "deaths" : "int"
    },
    "locations" : [
      {
        "longitude" : 33.466200,
        "latitude" : -82.502570,
        "confirmedCases" : 400,
        "deaths" : 20
      }
    ]
  }
}
```

### News

#### GET /news/feed?authKey={!STRING}

#### GET /news/country/{country_name}/feed?authKey={!STRING}

#### GET /news/country/{country_name}/state/{state_name}/feed?authKey={!STRING}

#### GET /news/country/{country_name}/state/{state_name}/county/{county_name}/feed?authKey={!STRING}
