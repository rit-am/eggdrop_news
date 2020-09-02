#---------------------------------------------
# TCL for NEWS API
# url - https://newsapi.org/
# Date - 2020/September/02
#---------------------------------------------

package require http
package require tls
package require json


bind pub - !news newsapi

proc newsapi {nick host hand chan arg} {
    set varListGeoCode [list ae ar at au be bg br ca ch cn co cu cz de eg fr gb gr hk hu id ie il in it jp kr lt lv ma mx my ng nl no nz ph pl pt ro rs ru sa se sg si sk th tr tw ua us ve za]
    set varStr "Please use !news <The 2-letter ISO 3166-1 code of the country you want to get headlines for>"
    set NewsAPIkey b-API-Key-35
    if {$arg == ""} {
        putserv "PRIVMSG $chan : HOST- $host HAND- $hand CHAN- $chan ARG- n/a"
        putserv "PRIVMSG $chan : $varStr"
        putserv "PRIVMSG $chan : Possible options: $varListGeoCode"
    } else {
        putserv "PRIVMSG $chan : HOST- $host HAND- $hand CHAN- $chan ARG- $arg"
        if {$arg == "  " } {
            putserv "PRIVMSG $chan : $varStr"
            putserv "PRIVMSG $chan : Possible options: $varListGeoCode"
        } else {
            if {$arg in $varListGeoCode} {
                set valtxt ""
                set intX 0
                set url "http://newsapi.org/v2/top-headlines";append url "?country=";append url $arg;append url "&apiKey=";append url $NewsAPIkey;
                ::http::config -useragent "Mozilla/4.75 (X11; U; Linux 2.2.17; i586; Nav)"
                ::http::register https 443 [list ::tls::socket -tls1 1]   ;# "-tls1 1" is required since [POODLE]
                if {[catch "::http::geturl $url" http] == 0} {
                    set html  [::http::data $http]
                    ::http::cleanup $http
                    ::http::unregister https
                    set data_set [::json::json2dict $html]
                    foreach item [dict keys $data_set] {
                        set value [dict get $data_set $item]
                        if {$item == "articles"} {
                            foreach article [dict keys $value] {
                                set obj [dict get $value $article]
                                append valtxt [lindex $obj 5];append valtxt [lindex $obj 7];append valtxt [lindex $obj 9]
                                putserv "PRIVMSG $chan : $valtxt"
                                set valtxt " "
                                }
                            }
                        }
                    }
                } else {
                    putserv "PRIVMSG $chan : $varStr"
                    putserv "PRIVMSG $chan : Possible options: $varListGeoCode"
                }
            }
        }
}

putlog "News API Loaded"
