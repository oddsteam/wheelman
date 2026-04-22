module Line
  class MockLineProfile
    def self.data
      {
        "sub" => "U55f73e76e998a79906ec232bb9b3e18e",
        "name" => "Mock User",
        "picture" => "https://profile.line-scdn.net/0hHu063PeIF1odTwAxtDtpJW0fFDA-Pk5IZCwKaXhMQGMoLFMIMX1dbC1HSGIlfFYEN3lfa3tNHj4RXGA8Axnrbhp_SmshdlQKOC9btQ",
        "exp" => Time.now.to_i + 3600
      }
    end
  end
end