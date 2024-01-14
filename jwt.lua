local opts = {
    discovery = os.getenv("WELL_KNOWN_URI"),
    token_signing_alg_values_expected = { "RS256" },
    accept_none_alg = false
}

local res, err = require("resty.openidc").bearer_jwt_verify(opts)

if err or not res then
    ngx.status = 403
    ngx.say(err and err or "no access_token provided")
    ngx.exit(ngx.HTTP_FORBIDDEN)
end

ngx.log(ngx.NOTICE, "tilkobling fra " .. res.sub)

if res.aud ~= os.getenv("AZURE_APP_CLIENT_ID") then
    ngx.status = 403
    ngx.say("token has wrong aud ", res.aud)
    ngx.exit(ngx.HTTP_FORBIDDEN)
end