###
#
#  Íàçâàíèå: etitle.tcl
#  Âåðñèÿ: 1.2
#  Àâòîð: tvrsh 
#  Îôôñàéò: http://egghelp.ru/
#
###
#
# Îïèñàíèå: Ñêðèïò "ïðîñòîãî" ïîêàçà òàéòëîâ âåáñòðàíè÷åê.
#
###
#
# Óñòàíîâêà: 
#         1. Ñêîïèðóéòå ñêðèïò etitle.tcl â ïàïêó scripts âàøåãî áîòà.
#         2. Â ôàéëå eggdrop.conf âïèøèòå ñòðîêó source scripts/etitle.tcl 
#         3. Ñäåëàéòå .rehash áîòó.
#
###
#
# Âåðñèîí õèñòîðè:
#
#              1.0(03.04.2010) Ïåðâàÿ ïàáëèê âåðñèÿ.
#              1.1(26.05.2010) + Óòî÷íåíèÿ âðåìåíè çàïðîñà (by Vertigo).
#                              + Óäàëåíèå íåæåëàòåëüíûõ ñèìâîëîâ èç óðë("({[) (by Vertigo).
#              1.2(01.11.2010) + TinyURL ñîêðàùåíèå.
#                  02.12.2010  + Ðàáîòà ñ Suzi ïàò÷åì è íåáîëüøàÿ äîðàáîòêà ñîêðàùåíèÿ óðëîâ.
#
###

namespace eval etitle {}
# Ñáðàñûâàåì çíà÷åíèÿ âñåõ ïåðåìåííûõ.
foreach p [array names etitle *] { catch {unset etitle($p) } }

# Óêàçûâàåì êàíàëüíûé ôëàã(.chanset #chan +etitle äëÿ âêëþ÷åíèÿ ñêðèïòà).
setudef flag etitle

###                            ###
# Ìåíþ íàñòðîåê íèæå ýòîé ëèíèè: #
# ______________________________ #
###                            ###
      # List of ignored url.
      set etitle(denyurls) "gfycat\.com\/|\.fbcdn\.net\/|mycdn\.me\/image|mega\.nz\/|\.jpg$|\.png$|\.gif$|\.bmp$|\.avi$|\.mp3$|\.jpeg$|\.avi$|\.mpg$|\.mkv$|\.torrent$"

      # Âðåìÿ ïåðåä ïîâòîðíûì èñïîëüçîâàíèåì êîìàíäû.
      # Seconds before next request.
      set etitle(delay) 5

      # Ñïèñîê íèêîâ ÷üè óðëû îáðàáàòûâàòüñÿ íå áóäóò.
      # List of ignored nicks.
      set etitle(denynicks) "lamestbot quiz info"

      # Ñïèñîê ñëîâ òàéòëû ñ êîòîðûìè áóäóò èãíîðèðîâàòüñÿ.
      # List of ignored words in titles.
      set etitle(denywords) "wordtoignore1 wordtoignore2"

      # Ìàêñèìàëüíîå êîëè÷åñòâî ðåäèðåêòîâ.
      # Maximum amount of redirects.
      set etitle(redirects) "5"

      # Èñïîëüçóåì TinyURL ñîêðàùåíèå. Óðëû äëèííåå ýòîãî ÷èñëà áóäóò ñîêðàùàòüñÿ.
      # script will use TinyUrl if URL is longer than this number.
      set etitle(tinyurl) "50"

      # Ñêîëüêî òðýêîâ ïîêàçûâàòü â ïëéëèñòå ðàäèîñòàíöèé? 0 äëÿ îòêëþ÷åíèÿ.
      # How many tracks show in radio playlists? 0 - off.
      set etitle(radiosongs) "3"

      ###
      # Íàñòðîéêà öâåòîâ.
      # Colours setup.

      # Öâåò 1.
      set etitle(color1) \00314
      # Öâåò 2.
      set etitle(color2) \00303
      # Öâåò 3.
      set etitle(color3) \00305
      ###

###                                                                  ###
# Íèæå ýòîé ëèíèè íà÷èíàåòñÿ êîä, íå èçìåíÿéòå åãî åñëè íå çíàåòå TCL: #
# ____________________________________________________________________ #
###                                                                  ###

    # Âåðñèÿ ñêðèïòà.
    # Script version.
    set etitle(version) "etitle.tcl version 1.2"
      
    # Àâòîð ñêðèïòà.
    # Script author.
    set etitle(author) "tvrsh"

    # Îáðàáîòêà áèíäîâ.
    bind pubm -|- "*://*" ::etitle::etitle_proc
    bind pubm -|- "*://*" ::etitle::etitle_proc

# Ïðîöåäóðà îáðàáîòêè çàïðîñà.
proc ::etitle::etitle_proc {nick uhost hand chan text} {
    global etitle lastbind botnick

    if {![channel get $chan etitle] || $nick == $botnick} { 
        return 0
    }

    foreach dnick [split $etitle(denynicks)] {
        if {$nick == $dnick} {
            return 0
        }
    }
  
    set text [stripcodes bcruag $text]

    if {[info exists etitle(lasttime,$chan)] && [expr $etitle(lasttime,$chan) + $etitle(delay)] > [clock seconds]} {
        return 0
    }

    set query [lindex [split $text] [lsearch [split $text] "*://*"]]
    set query [string trim [join $query] \x20\x5B\x5D\x7B\x7D\x28\x29\x22\x27\x09]

    if {[string match "*#*" $query]} {
        regsub -nocase "http://" $query "" query
        if {[string match "*/*#*/*" $query]} {
            set query http://[join [lreplace [split $query "/"] [lsearch [split $query "/"] *#*] [lsearch [split $query "/"] *#*]] "/"]
        } else {
            set query http://[lindex [split $query "#"] 0]
        }
    }

    putlog "\[etitle\] $nick/$chan - $query"
    ::etitle::etitle_parce $nick $uhost $hand $chan $query 0 [clock clicks]
    set etitle(lasttime,$chan) [clock seconds]
}

# Ïðîåäóðà ïàðñèíãà.
proc ::etitle::etitle_parce {nick uhost hand chan query redirect start} {
global etitle lastbind

    set etitle_tok [::http::config -urlencoding utf-8 -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:45.5) Gecko/20100101 Firefox/45.5"]
    set etitle_tok [::http::geturl "$query" -binary 1 -timeout 20000 -headers [list Range "bytes=0-16384"]]  
    set data [::http::data $etitle_tok]
    set title "No title"
    upvar #0 $etitle_tok state

    foreach {name value} $state(meta) {
#    putlog "$name $value"
       if {[regexp -nocase ^location$ $name]} {
           set newurl $value
       } 
    }

    if {$redirect < $etitle(redirects)} {
        if {[info exists newurl] && $newurl != ""} {
            if {[string first "/" $newurl] == "0"} { 
                regexp -- {://(.*?)/} $query -> baseurl
                regexp -- {www.(.*?)/} $query -> baseurl
                if {[info exists baseurl] && $baseurl != ""} {
                    set newurl http://$baseurl$newurl
                    ::etitle::etitle_parce $nick $uhost $hand $chan $newurl [incr redirect] $start
                    return 0
                } else {
                    set newurl $query$newurl
                    ::etitle::etitle_parce $nick $uhost $hand $chan $newurl [incr redirect] $start
                    return 0
                }
            } else {
                if {![string match "*http://*" $newurl] && ![string match "*www*" $newurl]} {
                    set newurl $query$newurl
                    ::etitle::etitle_parce $nick $uhost $hand $chan $newurl [incr redirect] $start
                    return 0
                } else {
                    ::etitle::etitle_parce $nick $uhost $hand $chan $newurl [incr redirect] $start
                    return 0
                }
            }  
        }
    } else {
        set title "No title."
        lappend title "$etitle(color1)Maximum redirects reached: $etitle(color2)$etitle(redirects)$etitle(color1)!"
    }

    upvar #0 $etitle_tok state
    foreach {name value} $state(meta) {
#putlog "$name $value"
        if {[string match -nocase "*Content-Type*" $name] && [string match "*audio*" $value]} {set title "$etitle(color1)Audio ($etitle(color2)$value$etitle(color1))."}
        if {[string match -nocase "*Content-Type*" $name] && [string match "*video*" $value]} {set title "$etitle(color1)Video ($etitle(color2)$value$etitle(color1))."}
        if {[string match -nocase "*Content-Type*" $name] && [string match "*image*" $value]} {set title "$etitle(color1)Image ($etitle(color2)$value$etitle(color1))."}
        if {[string match -nocase "*Content-Type*" $name] && [string match "*application*" $value]} {set title "$etitle(color1)Application ($etitle(color2)$value$etitle(color1))."}
        if {[string match -nocase "*Content-Disposition*" $name] && [string match "*filename=*" $value]} {lappend title "$etitle(color2)[lindex [split $value "="] 1]$etitle(color1)."}
        if {[string match -nocase "*Content-Length*" $name]} {
           if {[string length $value] >= 20} {
                set size "Size: $etitle(color2)> [::etitle::etitle_bytify [string range $value 0 19]]$etitle(color1).\003"
            } else {
                set size "Size: $etitle(color2)[::etitle::etitle_bytify $value]$etitle(color1).\003"
            }
        }
        if {[string match -nocase "*Content-Range*" $name]} {
            set value [lindex [split $value "/"] 1]
            set size "Size: $etitle(color2)[::etitle::etitle_bytify $value]$etitle(color1).\003"
        }
    } 
    if {[info exists size]} {lappend title $size}

    set charset [string map -nocase {"UTF-" "utf-" "iso-" "iso" "windows-" "cp" "shift_jis" "shiftjis"} $state(charset)]

    ::http::cleanup $etitle_tok

    regsub -all -nocase -- {^</title>.*?<title>} $data " | " data
    regsub -all -nocase -- {<!--.*?-->} $data "" data
    regexp -nocase -- {charset[=\"|='|=](.+?)[\ |\"|']} $data "" charset
    regexp -nocase -- {charset','(.+?)'} $data "" charset

    if {$charset == "Unknown"} {
        set data [encoding convertto cp1251 [encoding convertfrom utf-8 $data]]
    }

    if {[string match -nocase "*utf-8*" $charset]} {
        set data [encoding convertto cp1251 [encoding convertfrom utf-8 $data]]
    }

    if {[string match -nocase "*iso8859-1*" $charset]} {
        set data [encoding convertto cp1251 [encoding convertfrom iso8859-1 $data]]
    }

    if {[string match -nocase "*koi8-r*" $charset]} {
        set data [encoding convertto cp1251 [encoding convertfrom koi8-r $data]]
    }

    regexp -nocase -- {<title.*?>(.*?)</title>} $data "" title

    foreach denyword [split $etitle(denywords)] {
        if {[string match -nocase *$denyword* $title]} {
            putserv "PRIVMSG $chan \002$nick\002, title of this page contein forbidden words."
            set etitle(lasttime,$chan) [clock seconds]
            return 0
        }
    }

    if {[regexp -nocase $etitle(denyurls) $query]} { return 0}

    if {[string match "*vkontakte.ru/u*" $query] && ![string match "*404 Not Found*" $title]} {
        regexp -nocase -- {.*?/u(\d+)/.*?} $query "" vkid
        lappend title " $etitle(color1)\037http://vkontakte.ru/id$vkid/\037"
    }

    if {[string match "*kinopoisk.ru*" $query]} {
        regexp -nocase -- {<meta name=\"mrc__share_title\" content=\"(.*?)\" \/>} $data "" kptitle
        if {[info exists kptitle] && $kptitle != ""} {
            lappend title " $etitle(color1)$kptitle"
        }
    }

    if {[string match "*cars.auto.ru/cars/used/sale/*" $query]} {
        regexp -nocase -- {<h2 class="auto-model">(.*?)</a>} $data "" title
        regexp -nocase -- {<dl class="sale-info">(.*?)</dl>} $data "" autodata
        regexp -nocase -- {<p class="cost"><big><strong>(.*?)</strong></big>} $data "" autoprice

        regsub -all -- {</dd>|</dt>} $autodata "|" autodata
        regsub -all -- {\<[^\>]*\>|\n|&sup3;} $autodata "" autodata
        if {[info exists autodata] && $autodata != ""} {
            lappend title " $etitle(color3)\[ $etitle(color2)[lindex [split $autodata "|"] 1] $etitle(color1)/ $etitle(color2)[lindex [split $autodata "|"] 3] $etitle(color1)/ $etitle(color2)[lindex [split $autodata "|"] 5] $etitle(color1)/ $etitle(color2)[lindex [split $autodata "|"] 7] $etitle(color1)/ $etitle(color2)[lindex [split $autodata "|"] 9] $etitle(color1)/ $etitle(color2)[lindex [split $autodata "|"] 11] $etitle(color1)/ $etitle(color2)[lindex [split $autodata "|"] 13]$etitle(color1): $etitle(color3)\002$autoprice\002 $etitle(color3)\]\003"
        }
    }

    if {[string match "*http://loveplanet.ru/page/*" $query]} {
        regexp -nocase -- {class="username girl">(.*?)</a>} $data "" title
        regexp -nocase -- {<div class="mess_menu">.*?<div class="in">(.*?)</td>} $data "" lovedata

        regsub -all -- {<div .*?>} $lovedata "$etitle(color1)\/ $etitle(color2)" lovedata
        regsub -all -- {\<[^\>]*\>|\n} $lovedata "" lovedata

        if {[info exists lovedata] && $lovedata != ""} {
            lappend title " $etitle(color3)\[ $etitle(color2)[join $lovedata] $etitle(color3)\]\003"
        }
    }

    if {[string match "*SHOUTcast Administrator*" $title]} {
        set title [::etitle::etitle_m3u $query]
    }

    if {[string match "*.m3u*" $query] || [string match "*.pls*" $query]} {
        regexp -nocase -- {^(http://.*?)$} $data "" m3url
        regexp -nocase -- {File1=(.*?)\n} $data "" m3url
        if {[info exists m3url] && $m3url != ""} {
            set title [lindex [::etitle::etitle_m3u $m3url] 0]
            set songs [lindex [::etitle::etitle_m3u $m3url] 1]
        }
    }

    set title [join $title]

    if {[expr [clock clicks] - $start] > 1000000} {
        set time "[expr ([clock clicks] - $start) / 1000 / 1000.]sec."
    } else {
        set time "[expr ([clock clicks] - $start) / 1000.]ms."
    }

    if {[info exists ::sp_version]} {
        set title [encoding convertfrom cp1251 $title]
    }

    if {[string length [join $query]] >= $etitle(tinyurl)} {
        putserv "PRIVMSG $chan :$etitle(color1)\002Title\002($etitle(color2)$charset $etitle(color1)/ $etitle(color2)$time $etitle(color1)/ \037\00312[::etitle::etitle_tinyurl $query]\037\00314 )\[$redirect\]: $etitle(color2)[::etitle::strip.html $title]"
        set etitle(lasttime,$chan) [clock seconds]
    } else {
        putserv "PRIVMSG $chan :$etitle(color1)\002Title\002($etitle(color2)$charset $etitle(color1)/ $etitle(color2)$time$etitle(color1))\[$redirect\]: $etitle(color2)[::etitle::strip.html $title]"
        set etitle(lasttime,$chan) [clock seconds]
    }
    if {[info exists songs] && $songs != ""} {
        set i 0
        foreach song [split $songs "|"] {
            if {$i > 1 && $i <= [expr $etitle(radiosongs) + 1] && $song != ""} {
                putserv "PRIVMSG $chan :$song"
            }
            incr i
        }
    } 

}

proc ::etitle::etitle_m3u {query} {
global etitle
    set etitle_tok [::http::config -urlencoding utf-8 -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:45.5) Gecko/20100101 Firefox/45.5"]
    set etitle_tok [::http::geturl "$query" -binary 1 -timeout 20000]  
    set data [::http::data $etitle_tok]
    ::http::cleanup $etitle_tok
    regexp -nocase -- {Stream Title: (.*?)</b>} $data "" title
    regexp -nocase -- {Stream is up at (.*?) kbps} $data "" status
    regexp -nocase -- {Content Type: (.*?)</b>} $data "" type
    regexp -nocase -- {Stream Genre: (.*?)</b>} $data "" genre
    regexp -nocase -- {Current Song: (.*?)</b>} $data "" song

    if {$etitle(radiosongs) > "0"} {
    set etitle_tok [::http::config -urlencoding utf-8 -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:45.5) Gecko/20100101 Firefox/45.5"]
    set etitle_tok [::http::geturl "${query}played.html" -binary 1 -timeout 20000]  
    set data [::http::data $etitle_tok]
    ::http::cleanup $etitle_tok
    regexp -nocase -- {Song Title</b></td></tr>(.*?)</tr></table>} $data "" songs
    regsub -all -nocase -- {<td><b>|</b>} $songs " \002" songs
    regsub -all -nocase -- {<tr><td>} $songs "|$etitle(color1)" songs
    regsub -all -nocase -- {</td><td>} $songs " - $etitle(color2)" songs
    regsub -all -- {\<[^\>]*\>|\n} $songs "" songs
    } else {
        set songs ""
    }

    return [list "$etitle(color2)$title$etitle(color1), Type: $etitle(color2)$type @ $status kbps$etitle(color1), Genre: $etitle(color2)$genre$etitle(color1), Current song: $etitle(color2)$song" "$songs"]
}



# TinyURL shortening.
proc ::etitle::etitle_tinyurl {url} {
global etitle lastbind

    set ua "Mozilla/5.0 (X11; Linux x86_64; rv:45.5) Gecko/20100101 Firefox/45.5"
    set http [::http::config -useragent $ua]
    set token [http::geturl "http://tinyurl.com/api-create.php?[http::formatQuery url $url]" -timeout 3000]
    upvar #0 $token state
    if {[string length $state(body)]} { 
        return $state(body) 
    }
    return $url
}

    # (c) feed.tcl by Vertigo
    proc ::etitle::strip.html {t} {
        regsub -all -nocase -- {<.*?>(.*?)</.*?>} $t {\1} t
        regsub -all -nocase -- {<.*?>} $t {} t
        set t [string map {{&amp;} {&}} $t]
        set t [string map -nocase {{&mdash;} {-} {&raquo;} {»} {&laquo;} {«} {&quot;} {"}  \
		{&lt;} {<} {&gt;} {>} {&nbsp;} { } {&amp;} {&} {&copy;} {©} {&#169;} {©} {&bull;} {} {&#183;} {-} {&sect;} {§} {&reg;} {®} \
		  &#8214; || \
		&#38;      &     &#91;      (     &#92;      /     &#93;      )      &#123;     (     &#125;     ) \
		&#163;     £     &#168;     ¨     &#169;     ©     &#171;     «      &#173;     ­     &#174;     ® \
		&#161;     ¡     &#191;     ¿     &#180;     ´     &#183;     ·      &#185;     ¹     &#187;     » \
		&#188;     ¼     &#189;     ½     &#190;     ¾     &#192;     À      &#193;     Á     &#194;     Â \
		&#195;     Ã     &#196;     Ä     &#197;     Å     &#198;     Æ      &#199;     Ç     &#200;     È \
		&#201;     É     &#202;     Ê     &#203;     Ë     &#204;     Ì      &#205;     Í     &#206;     Î \
		&#207;     Ï     &#208;     Ð     &#209;     Ñ     &#210;     Ò      &#211;     Ó     &#212;     Ô \
		&#213;     Õ     &#214;     Ö     &#215;     ×     &#216;     Ø      &#217;     Ù     &#218;     Ú \
		&#219;     Û     &#220;     Ü     &#221;     Ý     &#222;     Þ      &#223;     ß     &#224;     à \
		&#225;     á     &#226;     â     &#227;     ã     &#228;     ä      &#229;     å     &#230;     æ \
		&#231;     ç     &#232;     è     &#233;     é     &#234;     ê      &#235;     ë     &#236;     ì \
		&#237;     í     &#238;     î     &#239;     ï     &#240;     ð      &#241;     ñ     &#242;     ò \
		&#243;     ó     &#244;     ô     &#245;     õ     &#246;     ö      &#247;     ÷     &#248;     ø \
		&#249;     ù     &#250;     ú     &#251;     û     &#252;     ü      &#253;     ý     &#254;     þ \
		&#176;     °     &#8231;    ·     &#716;     .     &#363;     u      &#299;     i     &#712;     ' \
		&#596;     o     &#618;     i     &apos;     ' } $t]
	set t [string map -nocase {&iexcl;    \xA1  &curren;   \xA4  &cent;     \xA2  &pound;    \xA3   &yen;      \xA5  &brvbar;   \xA6 \
		&sect;     \xA7  &uml;      \xA8  &copy;     \xA9  &ordf;     \xAA   &laquo;    \xAB  &not;      \xAC \
		&shy;      \xAD  &reg;      \xAE  &macr;     \xAF  &deg;      \xB0   &plusmn;   \xB1  &sup2;     \xB2 \
		&sup3;     \xB3  &acute;    \xB4  &micro;    \xB5  &para;     \xB6   &middot;   \xB7  &cedil;    \xB8 \
		&sup1;     \xB9  &ordm;     \xBA  &raquo;    \xBB  &frac14;   \xBC   &frac12;   \xBD  &frac34;   \xBE \
		&iquest;   \xBF  &times;    \xD7  &divide;   \xF7  &Agrave;   \xC0   &Aacute;   \xC1  &Acirc;    \xC2 \
		&Atilde;   \xC3  &Auml;     \xC4  &Aring;    \xC5  &AElig;    \xC6   &Ccedil;   \xC7  &Egrave;   \xC8 \
		&Eacute;   \xC9  &Ecirc;    \xCA  &Euml;     \xCB  &Igrave;   \xCC   &Iacute;   \xCD  &Icirc;    \xCE \
		&Iuml;     \xCF  &ETH;      \xD0  &Ntilde;   \xD1  &Ograve;   \xD2   &Oacute;   \xD3  &Ocirc;    \xD4 \
		&Otilde;   \xD5  &Ouml;     \xD6  &Oslash;   \xD8  &Ugrave;   \xD9   &Uacute;   \xDA  &Ucirc;    \xDB \
		&Uuml;     \xDC  &Yacute;   \xDD  &THORN;    \xDE  &szlig;    \xDF   &agrave;   \xE0  &aacute;   \xE1 \
		&acirc;    \xE2  &atilde;   \xE3  &auml;     \xE4  &aring;    \xE5   &aelig;    \xE6  &ccedil;   \xE7 \
		&egrave;   \xE8  &eacute;   \xE9  &ecirc;    \xEA  &euml;     \xEB   &igrave;   \xEC  &iacute;   \xED \
		&icirc;    \xEE  &iuml;     \xEF  &eth;      \xF0  &ntilde;   \xF1   &ograve;   \xF2  &oacute;   \xF3 \
		&ocirc;    \xF4  &otilde;   \xF5  &ouml;     \xF6  &oslash;   \xF8   &ugrave;   \xF9  &uacute;   \xFA \
		&ucirc;    \xFB  &uuml;     \xFC  &yacute;   \xFD  &thorn;    \xFE   &yuml;     \xFF} $t]
        set t [[namespace current]::regsub-eval {&#([0-9]{1,5});} $t {string trimleft \1 "0"}]
        regsub -all {[\x20\x09]+} $t " " t
        regsub -all -nocase -- {<.*?>} $t {} t
        return $t
    }

    proc ::etitle::regsub-eval {re string cmd} {
        return [subst [regsub -all $re [string map {\[ \\[ \] \\] \$ \\$ \\ \\\\} $string] "\[format %c \[$cmd\]\]"]]
    }

proc ::etitle::etitle_bytify {bytes} {
    for {set pos 0; set bytes [expr double($bytes)]} { $bytes >= 1024.0} {set bytes [expr $bytes/1024.0]} {incr pos}
    set a [lindex {"b" "Kb" "Mb" "Gb" "Tb" "Pb"} $pos]
    format "%.3f%s" $bytes $a
}

# Âûâîäèì ñîîáùåíèå î òîì, ÷òî ñêðèïò óäà÷íî çàãðóæåí.
putlog "\[etitle\] $etitle(version) by $etitle(author) loaded"
