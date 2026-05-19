const String defaultTagId = "2754655826098840951";
const String defaultViewName = "MSDKEmbeddedLayout";
// Replace with a partner CNAME (e.g. https://rkt.partner.com) to route SDK
// traffic through a first-party domain. Default points at the standard Rokt
// host so the example works without any CNAME configured.
const String defaultCustomBaseUrl = "https://apps.rokt.com";

const String androidAttributes = """{
  "email": "j.smith@example.com",
  "firstname": "Jenny",
  "lastname": "Smith",
  "mobile": "(555)867-5309",
  "postcode": "90210",
  "country": "US",
  "sandbox": "true"
}""";

const String iOSAttributes = """{
  "email": "jenny.smith@example.com",
  "firstname": "Jenny",
  "lastname": "Smith",
  "confirmationref": "ORD-12345",
  "paymenttype": "ApplePay",
  "country": "US",
  "billingzipcode": "07762",
  "shippingaddress1": "123 Main St",
  "shippingaddress2": "Apt 4B",
  "shippingcity": "New York",
  "shippingstate": "NY",
  "shippingzipcode": "10001",
  "shippingcountry": "US",
  "sandbox": "true",
  "colormode": "LIGHT"
}""";
