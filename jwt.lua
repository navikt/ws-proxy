local opts = {
    discovery = os.getenv("AZURE_APP_WELL_KNOWN_URL"),
    token_signing_alg_values_expected = { "RS256" },
    accept_none_alg = false,
    auth_accept_token_as_header_name = "Proxy-Authorization",
    proxy_opts = {
        http_proxy  = os.getenv("HTTP_PROXY"),
        https_proxy = os.getenv("HTTPS_PROXY"),
        no_proxy = os.getenv("NO_PROXY")
    }
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

ngx.req.set_header("X-Azure-Client-Id", res.sub)
ngx.req.set_header("X-Azure-Azp-Name", res.azp_name)
