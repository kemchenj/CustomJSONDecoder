
import Foundation
import JSONDecoder

// The model that the JSONObject in large.json in Fixtures models.

class BaseClass: Codable {

    let _id: String
    let index: Int
    let guid: String
    let isActive: Bool
    let balance: String
    let picture: String
    let age: UInt
    let name: String
    let company: String
    let email: String
    let phone: String
    let address: String
    let about: String
    let registered: String
    let latitude: Double
    let longitude: Double
    let tags: [String]
    let greeting: String
    let favoriteFruit: String

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        _id = try container.decode(String.self, forKey: ._id)
        index = try container.decode(Int.self, forKey: .index)
        guid = try container.decode(String.self, forKey: .guid)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        balance = try container.decode(String.self, forKey: .balance)
        picture = try container.decode(String.self, forKey: .picture)
        age = try container.decode(UInt.self, forKey: .age)
        name = try container.decode(String.self, forKey: .name)
        company = try container.decode(String.self, forKey: .company)
        email = try container.decode(String.self, forKey: .email)
        phone = try container.decode(String.self, forKey: .phone)
        address = try container.decode(String.self, forKey: .address)
        about = try container.decode(String.self, forKey: .about)
        registered = try container.decode(String.self, forKey: .registered)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        tags = try container.decode([String].self, forKey: .tags)
        greeting = try container.decode(String.self, forKey: .greeting)
        favoriteFruit = try container.decode(String.self, forKey: .favoriteFruit)
    }

    init(foundationJSON json: Any) throws {
        guard
            let json              = json as? [String: Any],
            let id                = json["_id"] as? String,
            let index             = json["index"] as? Int,
            let guid              = json["guid"] as? String,
            let isActive          = json["isActive"] as? Bool,
            let balance           = json["balance"] as? String,
            let picture           = json["picture"] as? String,
            let age               = json["age"] as? UInt,
            let name              = json["name"] as? String,
            let company           = json["company"] as? String,
            let email             = json["email"] as? String,
            let phone             = json["phone"] as? String,
            let address           = json["address"] as? String,
            let about             = json["about"] as? String,
            let registered        = json["registered"] as? String,
            let latitude          = json["latitude"] as? Double,
            let longitude         = json["longitude"] as? Double,
            let tags              = json["tags"] as? [String],
            let greeting          = json["greeting"] as? String,
            let favoriteFruit     = json["favoriteFruit"] as? String
        else { throw FoundationJSONError.typeMismatch }

        self._id             = id
        self.index          = index
        self.guid           = guid
        self.isActive       = isActive
        self.balance        = balance
        self.picture        = picture
        self.age            = age
        self.name           = name
        self.company        = company
        self.email          = email
        self.phone          = phone
        self.address        = address
        self.about          = about
        self.registered     = registered
        self.latitude       = latitude
        self.longitude      = longitude
        self.tags           = tags
        self.greeting       = greeting
        self.favoriteFruit  = favoriteFruit
    }
}

class User: BaseClass, Equatable {
    let eyeColor: Color
    let gender: Gender
    let friends: [Friend]

    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs._id == rhs._id
            && lhs.index == rhs.index
            && lhs.guid == rhs.guid
            && lhs.isActive == rhs.isActive
            && lhs.balance == rhs.balance
            && lhs.picture == rhs.picture
            && lhs.age == rhs.age
            && lhs.name == rhs.name
            && lhs.company == rhs.company
            && lhs.email == rhs.email
            && lhs.phone == rhs.phone
            && lhs.address == rhs.address
            && lhs.about == rhs.about
            && lhs.registered == rhs.registered
            && lhs.latitude == rhs.latitude
            && lhs.longitude == rhs.longitude
            && lhs.tags == rhs.tags
            && lhs.greeting == rhs.greeting
            && lhs.favoriteFruit == rhs.favoriteFruit
            && lhs.eyeColor == rhs.eyeColor
            && lhs.gender == rhs.gender
            && lhs.friends == rhs.friends
    }

    enum Color: String, Codable {
        case red
        case green
        case blue
        case brown
    }

    enum Gender: String, Codable {
        case male
        case female
    }

    struct Friend: Codable, Equatable {
        let id: Int
        let name: String

        static func ==(lhs: Friend, rhs: Friend) -> Bool {
            return lhs.id == rhs.id
                && lhs.name == rhs.name
        }
    }

    private enum CodingKeys: String, CodingKey {
        case eyeColor
        case gender
        case friends
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        eyeColor = try container.decode(Color.self, forKey: .eyeColor)
        gender   = try container.decode(Gender.self, forKey: .gender)
        friends  = try container.decode([Friend].self, forKey: .friends)

        // try super.init(from: container.superDecoder())
        try super.init(from: container.superDecoder())
    }

    override init(foundationJSON json: Any) throws {
        guard
            let json              = json as? [String: Any],
            let eyeColorRawValue  = json["eyeColor"] as? String,
            let eyeColor          = Color(rawValue: eyeColorRawValue),
            let genderRawValue    = json["gender"] as? String,
            let gender            = Gender(rawValue: genderRawValue),
            let friendsObjects    = json["friends"] as? [Any]
        else { throw FoundationJSONError.typeMismatch }

        self.friends  = try friendsObjects.map(Friend.init)
        self.eyeColor = eyeColor
        self.gender   = gender

        try super.init(foundationJSON: json)
    }
}

// MARK: - Foundation

enum FoundationJSONError: Error {
  case typeMismatch
}

extension User.Friend {

  init(foundationJSON json: Any) throws {
    guard
      let json  = json as? [String: Any],
      let id    = json["id"] as? Int,
      let name  = json["name"] as? String
      else { throw FoundationJSONError.typeMismatch }
    self.id   = id
    self.name = name
  }
}

class TUser: BaseClass, Equatable {
    let eyeColor: Color
    let gender: Gender
    let friends: [Friend]

    static func ==(lhs: TUser, rhs: TUser) -> Bool {
        return lhs._id == rhs._id
            && lhs.index == rhs.index
            && lhs.guid == rhs.guid
            && lhs.isActive == rhs.isActive
            && lhs.balance == rhs.balance
            && lhs.picture == rhs.picture
            && lhs.age == rhs.age
            && lhs.name == rhs.name
            && lhs.company == rhs.company
            && lhs.email == rhs.email
            && lhs.phone == rhs.phone
            && lhs.address == rhs.address
            && lhs.about == rhs.about
            && lhs.registered == rhs.registered
            && lhs.latitude == rhs.latitude
            && lhs.longitude == rhs.longitude
            && lhs.tags == rhs.tags
            && lhs.greeting == rhs.greeting
            && lhs.favoriteFruit == rhs.favoriteFruit
            && lhs.eyeColor == rhs.eyeColor
            && lhs.gender == rhs.gender
            && lhs.friends == rhs.friends
    }

    enum Color: String, Codable {
        case red
        case green
        case blue
        case brown
    }

    enum Gender: String, Codable {
        case male
        case female
    }

    struct Friend: Codable, Equatable {
        let id: Int
        let name: String

        static func ==(lhs: Friend, rhs: Friend) -> Bool {
            return lhs.id == rhs.id
                && lhs.name == rhs.name
        }

        init(foundationJSON json: Any) throws {
            guard
                let json  = json as? [String: Any],
                let id    = json["id"] as? Int,
                let name  = json["name"] as? String
            else { throw FoundationJSONError.typeMismatch }
            self.id   = id
            self.name = name
        }
    }

    private enum CodingKeys: String, CodingKey {
        case eyeColor
        case gender
        case friends
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        eyeColor = try container.decode(Color.self, forKey: .eyeColor)
        gender   = try container.decode(Gender.self, forKey: .gender)
        friends  = try container.decode([Friend].self, forKey: .friends)

        // try super.init(from: container.superDecoder())
        try super.init(from: decoder)
    }

    override init(foundationJSON json: Any) throws {
        guard
            let json              = json as? [String: Any],
            let eyeColorRawValue  = json["eyeColor"] as? String,
            let eyeColor          = Color(rawValue: eyeColorRawValue),
            let genderRawValue    = json["gender"] as? String,
            let gender            = Gender(rawValue: genderRawValue),
            let friendsObjects    = json["friends"] as? [Any]
            else { throw FoundationJSONError.typeMismatch }

        self.friends  = try friendsObjects.map(Friend.init)
        self.eyeColor = eyeColor
        self.gender   = gender

        try super.init(foundationJSON: json)
    }
}
