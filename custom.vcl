sub vcl_recv {
    # send all requests to our backend round-robin (brr)
    set req.backend_hint = brr.backend();

    # store requested url for returning later
    set req.http.X-Varnish-Url = req.url

    # decide if request can look in cache
    if (req.url ~ "^/(admin|users|recruiter|dashboard|consultant/|job-search)"){
        return(pass);
    } elsif (req.http.Cookie ~ "_user_logged_in") {
        return(pass);
    } else {
        # trash the cookies
        unset req.http.Cookie;
        return(hash);
    }
}

sub vcl_hit {
    set req.http.X-Varnish-Cache = "hit";
}

sub vcl_miss {
    set req.http.X-Varnish-Cache = "miss";
}

sub vcl_pass {
    set req.http.X-Varnish-Cache = "pass";
}

sub vcl_backend_response {

    if (beresp.status > 500) {
       # the failing backend is blacklisted and we try to fetch content from another server
       saintmode.blacklist(5s);
       return (retry);
    }

    if (beresp.http.X-Do-Not-Cache == "true") {
        set beresp.uncacheable = true;
    } else {
        unset beresp.http.Set-Cookie;
        unset beresp.http.Cookie;
        set beresp.http.Cache-Control = "public, no-cache";
        set beresp.ttl = 3600s; # 1h in cache 
        set beresp.grace = 864000s; # 10 days grace period
    }
    



    

    # debugging messages
    if (beresp.http.Cookie ~ "(_user_logged_in|_session)") {
        set beresp.http.X-Cacheable = "NO:Got Session";
        set beresp.uncacheable = true;
        return (deliver);

    } elsif (beresp.ttl <= 0s) {
        # Varnish determined the object was not cacheable
        set beresp.http.X-Cacheable = "NO:Not Cacheable";

    } elsif (beresp.http.set-cookie) {
        # You don't wish to cache content for logged in users
        set beresp.http.X-Cacheable = "NO:Set-Cookie";
        set beresp.uncacheable = true;
        return (deliver);

    } elsif (beresp.http.Cache-Control ~ "private") {
        # You are respecting the Cache-Control=private header from the backend
        set beresp.http.X-Cacheable = "NO:Cache-Control=private";
        set beresp.uncacheable = true;
        return (deliver);

    } else {
        # Varnish determined the object was cacheable
        set beresp.http.X-Cacheable = "YES";
    }

    
    # Compress response if not compressed
    if (beresp.http.content-type ~ "text") {
        set beresp.do_gzip = true;
    }
    
}

sub vcl_deliver {
    set resp.http.X-Varnish-Cache = req.http.X-Varnish-Cache;
    set resp.http.X-Varnish-Url = req.http.X-Varnish-Url;
}
