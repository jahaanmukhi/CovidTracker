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

#### GET /map

```json
[
  { 
    "uid" : 0,
    "fips" : 0.0,
    "combined_key" : "",
    "country": "",
    "state": "",
    "county" : "",
    "latitude": 0.0,
    "longitude": 0.0,
    "confirmed_cases" : 0,
    "deaths" : 0,
    "daily_change_cases" : 0,
    "daily_change_deaths" : 0,
    "population" : 0
  }
]
```

#### GET /map/stats/{fips}

```json
[
    {
      "date": "2020-4-1",
      "confirmed": 4862,
      "deaths": 20
    },
    {
      "date": "2020-4-2",
      "confirmed": 5116,
      "deaths": 24
    },
    {
      "date": "2020-4-3",
      "confirmed": 5330,
      "deaths": 28
    }
  ]
```