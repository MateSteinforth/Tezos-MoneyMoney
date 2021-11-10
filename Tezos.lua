-- Inofficial Tezos Extension for MoneyMoney
-- Fetches Tezos quantity for address via https://tzkt.io/ API
-- Fetches Tezos price in EUR via cryptocompare API
-- Returns cryptoassets as securities
--
-- Username: Tezos Adresses comma seperated
-- Password: anything

-- MIT License

-- Copyright (c) 2021 Mate Steinforth

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.


WebBanking{
  version = 0.1,
  description = "Include your Tezos as cryptoportfolio in MoneyMoney by providing a Tezos Address.",
  services= { "Tezos" }
}

local xtzAddresses
local connection = Connection()
local currency = "EUR" -- fixme: make dynamik if MM enables input field

function SupportsBank (protocol, bankCode)
  return protocol == ProtocolWebBanking and bankCode == "Tezos"
end

function InitializeSession (protocol, bankCode, username, username2, password, username3)
    xtzAddresses = username:gsub("%s+", "")
end

function ListAccounts (knownAccounts)
  local account = {
    name = "Tezos",
    accountNumber = "Crypto Asset Tezos",
    currency = currency,
    portfolio = true,
    type = "AccountTypePortfolio"
  }

  return {account}
end

function RefreshAccount (account, since)
  local s = {}
  prices = requestXTZPrice()

  for address in string.gmatch(xtzAddresses, '([^,]+)') do
    XtzQuantity = requestXtzBalance(address)
    FXtzQuantity = convertBalanceToXtz(XtzQuantity)

    s[#s+1] = {
      name = address,
      currency = nil,
      market = "cryptocompare",
      quantity = FXtzQuantity,
      price = prices["EUR"],
    }
  end

  return {securities = s}
end

function EndSession ()
end


-- Querry Functions
function requestXTZPrice()
  content = connection:request("GET", cryptocompareRequestUrl(), {})
  json = JSON(content)

  return json:dictionary()
end

function requestXtzBalance(ethAddress)
  content = connection:request("GET", etherscanRequestUrl(ethAddress), {})
  return content
end


-- Helper Functions
function convertBalanceToXtz(xtz)
  return xtz / 1000000 
end

function cryptocompareRequestUrl()
  return "https://min-api.cryptocompare.com/data/price?fsym=XTZ&tsyms=EUR,USD"
end 

function etherscanRequestUrl(ethAddress)
  apiRoot = "https://api.tzkt.io/v1/accounts/" 
  balance = ethAddress .. "/balance"

  return apiRoot .. balance
end

